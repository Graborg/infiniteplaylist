@val external window: 'a = "window"
let _ = {
  open Firebase.Auth
  require
}
let _ = {
  open Firebase.Firestore
  require
}
type state =
  | LoadingFilms
  | ErrorFetchingFilms
  | LoadedFilms(array<FilmType.film>, array<FilmType.film>)
  | NotLoggedin

type url = {
  /* path takes window.location.pathname, like "/book/title/edit" and turns it into `["book", "title", "edit"]` */
  path: list<string>,
  /* the url's hash, if any. The # symbol is stripped out for you */
  hash: string,
  /* the url's query params, if any. The ? symbol is stripped out for you */
  search: string,
}

let wrapper = Emotion.css(`
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
`)

let listTitle = Emotion.css(`
  font-size: calc(20rem/16);
  width: fit-content;
  padding-bottom: 4px;
  padding-top: 24px;
  border-bottom: 1px solid var(--color-black);
`)

type conf = {
  apiKey: string,
  authDomain: string,
  projectId: string,
  storageBucket: string,
  messagingSenderId: string,
  appId: string,
}

let getUserMovieList: string => Js.Promise.t<array<FilmType.film>> = userId => {
  open Firebase
  open Js.Promise
  firebase
  ->firestore
  ->Firestore.collection("userFilmLists")
  ->Firestore.Collection.doc(userId)
  ->Firestore.Collection.DocRef.get()
    |> then_(docRef => {
      let movieList = docRef->Firestore.DocSnapshot.data()

      Belt.Array.map(movieList["filmList"], (film): FilmType.film => {
        {
          id: film["id"],
          creator: userId->FilmType.getUserVariant,
          title: film["title"],
          releaseDate: film["releaseDate"],
          plot: film["plot"],
          posterPath: film["posterPath"],
          language: film["language"],
          genres: film["genres"],
          seen: film["seen"],
        }
      }) |> resolve
    })
}

let addFilmToList: (string, FilmType.film) => Js.Promise.t<unit> = (userId, film) => {
  open Firebase
  firebase
  ->firestore
  ->Firestore.collection("userFilmLists")
  ->Firestore.Collection.doc(userId)
  ->Firestore.Collection.DocRef.set(film, ())
  /* let i = */
  /* firebase->firestore->Firestore.collection("movies")->Firestore.Collection.get() */
  /* |> then_(querySnapshot => */
  /* querySnapshot */
  /* ->Firestore.QuerySnapshot.docs */
  /* ->Belt.Array.map(snapshot => { */
  /* let data = snapshot->Firestore.DocSnapshot.data() */
  /* /1* Js.log(snapshot->Firestore.DocRef.id) *1/ */
  /* Js.log(data["title"]) */

  /* data */
  /* }) |> resolve */
  /* ) */
}
@react.component
let make = () => {
  let (state, setState) = React.useState(() => LoadingFilms)
  let (filmRandomlySelected, randomlySelectFilm) = React.useState(() => "")
  let (userId, setUserId) = React.useState(() => None)

  let doSelectFilm = filmId =>
    setState(prevState =>
      switch prevState {
      | LoadedFilms(list, seenFilms) => LoadedFilms(list, seenFilms)
      | _ => prevState
      }
    )

  React.useEffect0(() => {
    open Firebase
    let conf: conf = {
      apiKey: "AIzaSyCTc74dSk1h1ImyBHcYyHx4X0E2kJloe9I",
      authDomain: "fermaandkarmisinfiniteplaylist.firebaseapp.com",
      projectId: "fermaandkarmisinfiniteplaylist",
      storageBucket: "fermaandkarmisinfiniteplaylist.appspot.com",
      messagingSenderId: "491628845187",
      appId: "1:491628845187:web:4067c45aee702242bfa3b6",
    }
    firebase->initializeApp(conf)

    None
  })

  let addFilmHandler: TheMovieDB.searchResult => unit = item => {
    let film: FilmType.film = {
      id: item.id,
      title: item.title,
      creator: Karmi, //TODO: Make dynamic from login
      releaseDate: item.releaseDate,
      posterPath: item.posterPath,
      plot: item.plot,
      language: item.language,
      genres: item.genres,
      seen: false,
    }
    open Js.Promise
    switch userId {
    | None => Js.Console.error("Can't add movie if not logged in")
    | Some(id) =>
      addFilmToList(id, film)
      |> then_(_ =>
        setState(state =>
          switch state {
          | LoadedFilms(films, seenFilms) => {
              let newUnseen = Js.Array.concat([film], films)
              LoadedFilms(newUnseen, seenFilms)
            }
          }
        ) |> resolve
      )
      |> ignore
    }
  }

  let url = RescriptReactRouter.useUrl()

  /* React.useEffect0(() => { */
  /* open FilmType */
  /* let user = LocalStorage.getUser() */
  /* setUser(_ => FilmType.getCreator(user)->Some(Ferma)) */
  /* None */
  /* }) */
  React.useEffect0(() => {
    open Firebase
    open Js.Promise
    firebase
    ->auth
    ->Auth.onAuthStateChanged((user: Auth.User.t) => {
      let userId = user->Auth.User.uid
      setUserId(_ => Some(userId))
      getUserMovieList(userId)
      |> then_((movieList: array<FilmType.film>) => {
        let unseen = movieList->Js.Array2.filter(film => !film.seen)
        let seen = movieList->Js.Array2.filter(film => film.seen)
        setState(_prevState => LoadedFilms(unseen, seen))

        resolve()
      })
      |> ignore
    })
    switch LocalStorage.getToken() {
    | None =>
      switch url.search {
      | "" => setState(_preState => NotLoggedin)
      | search =>
        if firebase->auth->Auth.isSignInWithEmailLink(~link=window["location"]["href"]) {
          firebase
          ->auth
          ->Auth.signInWithEmailLink(~email="mgraborg@gmail.com", ~link=window["location"]["href"])
          |> then_(res => {
            let i =
              firebase
              ->firestore
              ->Firestore.collection("movies")
              ->Firestore.Collection.add({
                "listId": 2,
                "title": "LOL",
                "description": "DESC",
              }) |> then_(res => Js.log(res) |> resolve)
            Js.log(res)
            resolve(res)
          })
          |> ignore
        }
      }
    | Some(token) => ignore()
    }
    None
  })

  let markFilmAsSeen = (film: FilmType.film) => {
    // let _k = Todoist.setFilmAsSeen(film)
    Js.Global.setTimeout(() => {
      setState((LoadedFilms(films, seenFilms)) => {
        let newUnseen = Js.Array2.filter(films, f => f.title !== film.title)
        let newSeenFilms = Js.Array.concat(seenFilms, [film])
        LoadedFilms(newUnseen, newSeenFilms)
      })
    }, 500) |> ignore
  }

  let unDooSeenFilm = (film: FilmType.film) => {
    //let _k = Todoist.setFilmAsUnseen(film)
    Js.Global.setTimeout(() => {
      setState((LoadedFilms(films, seenFilms)) => {
        let newSeenFilms = Js.Array2.filter(seenFilms, f => f.title !== film.title)
        let newUnseen = Js.Array.concat(films, [film])
        LoadedFilms(newUnseen, newSeenFilms)
      })
    }, 500) |> ignore
  }

  let getNextElector = (seenFilms: array<FilmType.film>) => {
    let selectedByKarmi =
      Js.Array2.filter(seenFilms, film => film.creator === FilmType.Karmi)->Js.Array.length
    let selectedByFerma =
      Js.Array2.filter(seenFilms, film => film.creator === Ferma)->Js.Array.length

    selectedByKarmi > selectedByFerma ? FilmType.Ferma : FilmType.Karmi
  }

  switch state {
  | ErrorFetchingFilms => React.string("An error occurred!")
  | LoadingFilms => <Spinner />
  | NotLoggedin =>
    <div className=wrapper>
      <MaxWidthWrapper> <Header /> </MaxWidthWrapper> <LoginButton /> <Footer />
    </div>
  | LoadedFilms(films, seenFilms) =>
    <MaxWidthWrapper>
      <Header />
      <SearchField addFilmHandler />
      <h3 className=listTitle> {React.string("Not seen")} </h3>
      <FilmList films selected=filmRandomlySelected markFilmAsSeen />
      <h3> {React.string("Seen")} </h3>
      <SeenFilmList films=seenFilms />
    </MaxWidthWrapper>
  }
}
