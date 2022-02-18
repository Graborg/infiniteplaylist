@val @scope(("process", "env")) external loginCallbackUrl: string = "FIREBASE_URL_LOGIN_CALLBACK"
open Firebase
open Firestore
open Firebase.Auth.User

let collectionName = "userFilmLists"
let filmListField = "filmList"

let acos: Firebase_Auth.actionCodeSettings = {
  url: loginCallbackUrl,
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
type userFilmListResult = {filmList: option<array<firebaseFilm>>}

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

let useUser: unit => option<Auth.User.t> = () => {
  let (user, setUser) = React.useState(() => None)

  firebase
  ->auth
  ->Auth.onAuthStateChanged((user: Js.Nullable.t<Auth.User.t>) =>
    switch Js.Nullable.toOption(user) {
    | Some(user) => {
        Js.log("user is logged in")
        LocalStorage.setUserId(user->Auth.User.uid)->ignore
        setUser(_ => Some(user))
      }
    | None => ()
    }
  )
  user
}

let setPartner: (~userId: string, ~partnerEmail: string) => Promise.t<unit> = (
  ~userId,
  ~partnerEmail,
) => {
  firebase
  ->firestore
  ->collection(collectionName)
  ->Collection.doc(userId)
  ->Collection.DocRef.set(
    {
      "partnerEmail": partnerEmail,
    },
    ~options=Collection.DocRef.setOptions(~merge=true),
    (),
  )
}
let addFilmToList: (string, firebaseFilm) => Promise.t<unit> = (userId, film) =>
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

let sendSignInLink: (~email: string) => Promise.t<'a> = (~email) =>
  firebase
  ->auth
  ->Auth.sendSignInLinkToEmail(~email, ~actionCodeSettings=acos)
  ->Promise.thenResolve(_ => email)

let handleAuthCallback: (~link: string) => Promise.t<'a> = (~link) => {
  let maybeEmail = LocalStorage.getEmail()
  let linkIsValid = firebase->auth->Auth.isSignInWithEmailLink(~link)
  switch (maybeEmail, linkIsValid) {
  | (Some(email), true) =>
    firebase
    ->auth
    ->Auth.signInWithEmailLink(~email, ~link)
    ->Promise.catch(_error => Promise.reject(InvalidLink))
  | (None, _) => Promise.reject(EmailNotFound)
  | (Some(_email), false) => Promise.reject(InvalidLink)
  }
}
