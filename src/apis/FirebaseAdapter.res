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
let collectionName = "userFilmLists"
let filmListField = "filmList"

let acos: Firebase_Auth.actionCodeSettings = {
  url: env["FIREBASE_URL_LOGIN_CALLBACK"],
  handleCodeInApp: true,
}

exception InvalidLink
exception EmailNotFound

type firebaseFilm = {
  id: int,
  title: string,
  creatorId: string,
  releaseDate: option<string>,
  posterPath: option<string>,
  plot: option<string>,
  language: option<string>,
  genres: option<array<string>>,
  seen: bool,
}
type userFilmListResult = {
  filmList: option<array<firebaseFilm>>,
  partnerEmail: option<string>,
  partnerNick: option<string>,
}

let convertToFilm: firebaseFilm => FilmType.film = firebaseFilm => {
  id: firebaseFilm.id,
  creator: firebaseFilm.creatorId->FilmType.getUserVariant,
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
  creatorId: film.creator->FilmType.getUserId,
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
      | None => setUser(_ => NoUser)
      }
    )
    None
  })
  user
}

let setPartner: (
  ~userId: string,
  ~partnerEmail: string,
  ~partnerNick: string,
) => Promise.t<unit> = (~userId, ~partnerEmail, ~partnerNick) => {
  firebase
  ->firestore
  ->collection(collectionName)
  ->Collection.doc(userId)
  ->Collection.DocRef.set(
    {
      "partnerEmail": partnerEmail,
      "partnerNick": partnerNick,
    },
    ~options=Collection.DocRef.setOptions(~merge=true),
    (),
  )
}

let partnerIsSet: string => Promise.t<bool> = userId => {
  firebase
  ->firestore
  ->collection(collectionName)
  ->Collection.doc(userId)
  ->Collection.DocRef.get()
  ->Promise.thenResolve(collection => {
    let res: userFilmListResult = collection->Firestore.DocSnapshot.data()

    Belt.Option.isSome(res.partnerNick) && Belt.Option.isSome(res.partnerEmail)
  })
}
let addFilmToList: (string, firebaseFilm) => Promise.t<'a> = (userId, film) =>
  firebase
  ->firestore
  ->collection(collectionName)
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
  ->collection(collectionName)
  ->Firestore.Collection.where("partnerEmail", #equal, email)
  ->Firestore.Collection.get()
  ->Promise.thenResolve(collections =>
    collections
    ->Firestore.QuerySnapshot.docs
    ->Belt.Array.map(collection => {
      let movieList: userFilmListResult = collection->Firestore.DocSnapshot.data()

      switch movieList.filmList {
      | Some(filmList) => Belt.Array.map(filmList, convertToFilm)
      | None => []
      }
    })
    ->Belt.Array.concatMany
  )
}

let getUserFilmList: string => Promise.t<array<FilmType.film>> = userId =>
  firebase
  ->firestore
  ->collection(collectionName)
  ->Collection.doc(userId)
  ->Collection.DocRef.get()
  ->Promise.thenResolve(docRef => {
    let movieList: userFilmListResult = docRef->DocSnapshot.data()
    switch movieList.filmList {
    | Some(filmList) => Belt.Array.map(filmList, convertToFilm)
    | None => []
    }
  })

let getFilmLists: Firebase.Auth.User.t => Promise.t<array<FilmType.film>> = user =>
  Promise.all2((
    getPartnerFilmList(user->email),
    getUserFilmList(user->uid),
  ))->Promise.thenResolve(((f1, f2)) => Belt.Array.concat(f1, f2))

let sendSignInLink: (~email: string, ~nickname: string=?, unit) => Promise.t<'a> = (
  ~email: string,
  ~nickname: option<string>=?,
  (),
) =>
  firebase
  ->auth
  ->Auth.sendSignInLinkToEmail(~email, ~actionCodeSettings=acos)
  ->Promise.thenResolve(_ => email)

let handleAuthCallback: (~link: string) => Promise.t<'a> = (~link) => {
  open Promise
  let maybeEmail = LocalStorage.getEmail()
  let maybeNickname = LocalStorage.getUserNick()
  let linkIsValid = firebase->auth->Auth.isSignInWithEmailLink(~link)
  switch (maybeEmail, maybeNickname, linkIsValid) {
  | (Some(email), Some(nickname), true) =>
    firebase
    ->auth
    ->Auth.signInWithEmailLink(~email, ~link)
    ->then(user => firebase->auth->Auth.updateProfile(user, ~displayName=nickname))
    ->catch(_error => Promise.reject(InvalidLink))
  | (None, _, _) => Promise.reject(EmailNotFound)
  | (Some(_email), _, false) => Promise.reject(InvalidLink)
  | (_, _, _) => Promise.reject(InvalidLink)
  }
}
