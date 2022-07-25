@val @scope("process") external env: {..} = "env"
open Firebase
open Firestore
open Firebase.Auth.User

let conf: firebaseConfig = {
  apiKey: env["FIREBASE_API_KEY"],
  authDomain: env["FIREBASE_AUTH_DOMAIN"],
  projectId: env["FIREBASE_PROJECT_ID"],
  storageBucket: env["FIREBASE_STORAGE_BUCKET"],
  messagingSenderId: env["FIREBASE_MESSAGING_SENDER_ID"],
  appId: env["FIREBASE_APP_ID"],
}
firebase->initializeApp(conf)
let usersFilmsCollection = "userFilmLists"
let usersCollection = "users"
let filmListField = "filmList"

let acos: Firebase_Auth.actionCodeSettings = {
  url: env["FIREBASE_URL_LOGIN_CALLBACK"],
  handleCodeInApp: true,
}

exception InvalidLink
exception EmailNotFound
exception PartnerDataCorrupted
exception DisplayNameNotSet

type firebaseFilm = {
  id: int,
  title: string,
  creatorId: string,
  releaseDate: option<string>,
  posterPath: option<string>,
  plot: option<string>,
  language: option<string>,
  genres: option<array<string>>,
  mutable seen: bool,
}
type userFilmListResult = {
  filmList: option<array<firebaseFilm>>,
  partnerEmail: option<string>,
}

type usersResult = {
  displayName: option<string>,
  partnerEmail: option<string>,
  userId: option<string>,
}

let convertToFilm: (
  ~creatorName: string,
  ~creatorIsCurrentUser: bool,
  ~firebaseFilm: firebaseFilm,
) => FilmType.film = (~creatorName, ~creatorIsCurrentUser, ~firebaseFilm) => {
  id: firebaseFilm.id,
  creatorName: creatorName,
  creatorIsCurrentUser: creatorIsCurrentUser,
  creatorId: firebaseFilm.creatorId,
  title: firebaseFilm.title,
  releaseDate: firebaseFilm.releaseDate,
  plot: firebaseFilm.plot,
  posterPath: firebaseFilm.posterPath,
  language: firebaseFilm.language,
  genres: firebaseFilm.genres,
  seen: firebaseFilm.seen,
}

let convertFromFilm: FilmType.film => firebaseFilm = film => {
  id: film.id,
  creatorId: film.creatorId,
  title: film.title,
  releaseDate: film.releaseDate,
  plot: film.plot,
  posterPath: film.posterPath,
  language: film.language,
  genres: film.genres,
  seen: film.seen,
}

type optionalFirebaseUser =
  | SomeUser(Auth.User.t)
  | LoadingUser
  | NoUser

let useUser: unit => optionalFirebaseUser = () => {
  let (user, setUser) = React.useState(() => LoadingUser)

  React.useEffect0(() => {
    firebase
    ->auth
    ->Auth.onAuthStateChanged((user: Js.Nullable.t<Auth.User.t>) =>
      switch Js.Nullable.toOption(user) {
      | Some(user) => {
          Js.log("user is logged in")
          LocalStorage.setUserId(user->Auth.User.uid)->ignore
          setUser(_ => SomeUser(user))
        }
      | None => {
          Js.log("no longer signed in!")
          LocalStorage.clearLocalStorage()->ignore
          setUser(_ => NoUser)
        }
      }
    )
    None
  })
  user
}

let setPartnerAccessToFilmList: (~userId: string, ~partnerEmail: string) => Promise.t<unit> = (
  ~userId,
  ~partnerEmail,
) => {
  firebase
  ->firestore
  ->collection(usersFilmsCollection)
  ->Collection.doc(userId)
  ->Collection.DocRef.set(
    {
      "partnerEmail": partnerEmail,
    },
    ~options=Collection.DocRef.setOptions(~merge=true),
    (),
  )
}

let addUser: (~userId: string, ~displayName: string, ~partnerEmail: string) => Promise.t<unit> = (
  ~userId,
  ~displayName,
  ~partnerEmail,
) => {
  firebase
  ->firestore
  ->collection(usersCollection)
  ->Collection.doc(userId)
  ->Collection.DocRef.set(
    {
      "userId": userId,
      "displayName": displayName,
      "partnerEmail": partnerEmail,
    },
    ~options=Collection.DocRef.setOptions(~merge=true),
    (),
  )
}

let getUserName: string => Promise.t<option<string>> = userId => {
  firebase
  ->firestore
  ->collection(usersCollection)
  ->Collection.doc(userId)
  ->Collection.DocRef.get()
  ->Promise.then(collection => {
    collection
    ->Firestore.DocSnapshot.data()
    ->Belt.Option.flatMap(usersResult => usersResult.displayName)
    ->Promise.resolve
  })
}
let getPartnerName: string => Promise.t<option<string>> = email => {
  firebase
  ->firestore
  ->collection(usersCollection)
  ->Firestore.Collection.where("partnerEmail", #equal, email)
  ->Firestore.Collection.get()
  ->Promise.thenResolve(collections => {
    collections
    ->Firestore.QuerySnapshot.docs
    ->Belt.Array.map(collection => {
      let res: usersResult = collection->Firestore.DocSnapshot.data()
      res.displayName
    })
    ->Belt.Array.get(0)
    ->Belt.Option.flatMap(e => e)
  })
}
let getUserNames: (
  ~userId: string,
  ~email: string,
) => Promise.t<(option<string>, option<string>)> = (~userId, ~email) => {
  Promise.all2((getUserName(userId), getPartnerName(email)))
}

let addFilmToList: (string, firebaseFilm) => Promise.t<'a> = (userId, film) =>
  firebase
  ->firestore
  ->collection(usersFilmsCollection)
  ->Collection.doc(userId)
  ->Collection.DocRef.update(
    {
      "filmList": firebase->firestoreObj->fieldValue->FieldValue.arrayUnion(film),
    },
    (),
  )

let getPartnerFilmList: string => Promise.t<array<FilmType.film>> = email => {
  firebase
  ->firestore
  ->collection(usersFilmsCollection)
  ->Firestore.Collection.where("partnerEmail", #equal, email)
  ->Firestore.Collection.get()
  ->Promise.thenResolve(collections =>
    collections
    ->Firestore.QuerySnapshot.docs
    ->Belt.Array.map(collection => {
      let movieList: userFilmListResult = collection->Firestore.DocSnapshot.data()
      let partnerName = LocalStorage.getPartnerDisplayName()

      switch (movieList.filmList, partnerName) {
      | (Some(filmList), Some(creatorName)) =>
        Belt.Array.map(filmList, firebaseFilm =>
          convertToFilm(~creatorName, ~creatorIsCurrentUser=false, ~firebaseFilm)
        )
      | (_, _) => []
      }
    })
    ->Belt.Array.concatMany
  )
}

let getUserFilmList: string => Promise.t<array<FilmType.film>> = userId =>
  firebase
  ->firestore
  ->collection(usersFilmsCollection)
  ->Collection.doc(userId)
  ->Collection.DocRef.get()
  ->Promise.thenResolve(docRef => {
    let movieList: option<userFilmListResult> = docRef->DocSnapshot.data()
    let displayName = LocalStorage.getUserDisplayName()
    switch (Belt.Option.flatMap(movieList, l => l.filmList), displayName) {
    | (Some(filmList), Some(creatorName)) =>
      Belt.Array.map(filmList, firebaseFilm =>
        convertToFilm(~creatorName, ~creatorIsCurrentUser=true, ~firebaseFilm)
      )
    | (_, _) => []
    }
  })

let getFilmLists: Firebase.Auth.User.t => Promise.t<array<FilmType.film>> = user =>
  Promise.all2((
    getPartnerFilmList(user->email),
    getUserFilmList(user->uid),
  ))->Promise.thenResolve(((f1, f2)) => Belt.Array.concat(f1, f2))

let setFilmAsSeen: firebaseFilm => Promise.t<bool> = film => {
  open Belt
  firebase
  ->firestore
  ->collection(usersFilmsCollection)
  ->Collection.doc(film.creatorId)
  ->Collection.DocRef.get()
  ->Promise.thenResolve(docRef => {
    film.seen = true
    let res: userFilmListResult = docRef->DocSnapshot.data()
    let updatedList =
      res.filmList
      ->Option.map(fList => Array.keep(fList, f => f.id !== film.id)->Array.concat([film]))
      ->Option.getWithDefault([film])

    firebase
    ->firestore
    ->collection(usersFilmsCollection)
    ->Collection.doc(film.creatorId)
    ->Collection.DocRef.update(
      {
        "filmList": updatedList,
      },
      ~options=Collection.DocRef.setOptions(~merge=true),
      (),
    )
  })
  ->Promise.thenResolve(_ => true)
}

let setFilmAsUnSeen: firebaseFilm => Promise.t<bool> = film => {
  open Belt
  firebase
  ->firestore
  ->collection(usersFilmsCollection)
  ->Collection.doc(film.creatorId)
  ->Collection.DocRef.get()
  ->Promise.thenResolve(docRef => {
    film.seen = false
    let res: userFilmListResult = docRef->DocSnapshot.data()
    let updatedList =
      res.filmList
      ->Option.map(fList => Array.keep(fList, f => f.id !== film.id)->Array.concat([film]))
      ->Option.getWithDefault([film])

    firebase
    ->firestore
    ->collection(usersFilmsCollection)
    ->Collection.doc(film.creatorId)
    ->Collection.DocRef.update(
      {
        "filmList": updatedList,
      },
      ~options=Collection.DocRef.setOptions(~merge=true),
      (),
    )
  })
  ->Promise.thenResolve(_ => true)
}

let sendSignInLink: (~email: string, unit) => Promise.t<'a> = (~email: string, ()) =>
  firebase
  ->auth
  ->Auth.sendSignInLinkToEmail(~email, ~actionCodeSettings=acos)
  ->Promise.thenResolve(_ => email)

let handleAuthCallback: (~link: string) => Promise.t<unit> = (~link) => {
  open Promise
  let maybeEmail = LocalStorage.getEmail()
  let linkIsValid = firebase->auth->Auth.isSignInWithEmailLink(~link)
  switch (maybeEmail, linkIsValid) {
  | (Some(email), true) =>
    firebase
    ->auth
    ->Auth.signInWithEmailLink(~email, ~link)
    ->ignore
    ->Promise.resolve
    ->catch(_error => Promise.reject(InvalidLink))
  | (None, _) => Promise.reject(EmailNotFound)
  | (_, false) => Promise.reject(InvalidLink)
  }
}
