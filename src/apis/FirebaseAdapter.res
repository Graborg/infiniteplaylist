open Firebase
open Firestore

let collectionName = "userFilmLists"
let filmListField = "filmList"

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
type userFilmListResult = {filmList: array<firebaseFilm>}

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

let useUserId: unit => option<string> = () => {
  let (userId, setUserId) = React.useState(() => None)

  firebase
  ->auth
  ->Auth.onAuthStateChanged((user: Js.Nullable.t<Auth.User.t>) =>
    switch Js.Nullable.toOption(user) {
    | Some(user) => {
        Js.log("user is logged in")
        setUserId(_ => Some(user->Auth.User.uid))
      }
    | None => ()
    }
  )

  userId
}

let addFilmToList: (string, firebaseFilm) => Js.Promise.t<unit> = (userId, film) =>
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

let getUserMovieList: string => Js.Promise.t<array<FilmType.film>> = userId => {
  open Js.Promise
  firebase->firestore->collection(collectionName)->Collection.doc(userId)->Collection.DocRef.get()
    |> then_(docRef => {
      let movieList: userFilmListResult = docRef->DocSnapshot.data()

      Belt.Array.map(movieList.filmList, (film: firebaseFilm): FilmType.film => {
        convertToFilm(film)
      }) |> resolve
    })
}
let handleAuthCallback: (~link: string) => Js.Promise.t<Firebase.Auth.User.t> = (~link) => {
  open Js.Promise
  if firebase->auth->Firebase.Auth.isSignInWithEmailLink(~link) {
    firebase->auth->Firebase.Auth.signInWithEmailLink(~email="mgraborg@gmail.com", ~link)
  } else {
    reject(Not_found)
  }
}
