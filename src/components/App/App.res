@val external window: 'a = "window"
type state =
  | LoadingFilms
  | ErrorFetchingFilms
  | LoadedFilms(array<FilmType.film>, array<FilmType.film>)
  | NotLoggedin

type url = {
  path: list<string>,
  hash: string,
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

@react.component
let make = () => {
  let (state, setState) = React.useState(() => LoadingFilms)
  //let (filmRandomlySelected, randomlySelectFilm) = React.useState(() => "")
  let userId = FirebaseAdapter.useUserId()

  /* let doSelectFilm = filmId => */
  /* setState(prevState => */
  /* switch prevState { */
  /* | LoadedFilms(list, seenFilms) => LoadedFilms(list, seenFilms) */
  /* | _ => prevState */
  /* } */
  /* ) */
  React.useEffect1(() => {
    open Promise
    switch userId {
    | Some(id) =>
      id
      ->FirebaseAdapter.getUserMovieList
      ->then((movieList: array<FilmType.film>) => {
        let unseen = movieList->Js.Array2.filter(film => !film.seen)
        let seen = movieList->Js.Array2.filter(film => film.seen)
        setState(_prevState => LoadedFilms(unseen, seen))

        resolve()
      })
    | None => resolve()
    }->ignore

    None
  }, [userId])

  let addFilmHandler: TheMovieDB.searchResult => unit = item => {
    open Promise
    open FirebaseAdapter
    switch userId {
    | None => Js.Console.error("Can't add movie if not logged in")
    | Some(id) => {
        let firebaseFilm: firebaseFilm = {
          id: item.id,
          title: item.title,
          creatorId: id,
          releaseDate: item.releaseDate,
          posterPath: item.posterPath,
          plot: item.plot,
          language: item.language,
          genres: item.genres,
          seen: false,
        }
        FirebaseAdapter.addFilmToList(id, firebaseFilm)
        ->then(_ =>
          setState(state =>
            switch state {
            | LoadedFilms(films, seenFilms) => {
                let film = convertToFilm(firebaseFilm)
                let newUnseen = Js.Array.concat([film], films)
                LoadedFilms(newUnseen, seenFilms)
              }
            | _ => {
                Js.Console.error("Can't add movie to filmlist state if not loaded")
                state
              }
            }
          )->resolve
        )
        ->ignore
      }
    }
  }

  let urlParts = RescriptReactRouter.useUrl()
  React.useEffect0(() => {
    open Promise
    let url: string = window["location"]["href"]

    switch urlParts.path {
    | list{"authCallback"} =>
      FirebaseAdapter.handleAuthCallback(~link=url)
      ->then(_ => RescriptReactRouter.push("/")->resolve)
      ->ignore
    | list{} => setState(_preState => NotLoggedin)
    | _ => setState(_preState => NotLoggedin)
    }
    None
  })

  let markFilmAsSeen = (film: FilmType.film) => {
    Js.Global.setTimeout(() => {
      setState(pastState => {
        switch pastState {
        | LoadedFilms(films, seenFilms) =>
          let newUnseen = Js.Array2.filter(films, f => f.title !== film.title)
          let newSeenFilms = Js.Array.concat(seenFilms, [film])
          LoadedFilms(newUnseen, newSeenFilms)
        | _ => pastState
        }
      })
    }, 500)->ignore
  }

  /* let unDooSeenFilm = (film: FilmType.film) => { */
  /* //let _k = Todoist.setFilmAsUnseen(film) */
  /* Js.Global.setTimeout(() => { */
  /* setState((LoadedFilms(films, seenFilms)) => { */
  /* let newSeenFilms = Js.Array2.filter(seenFilms, f => f.title !== film.title) */
  /* let newUnseen = Js.Array.concat(films, [film]) */
  /* LoadedFilms(newUnseen, newSeenFilms) */
  /* }) */
  /* }, 500) -> ignore */
  /* } */

  /* let getNextElector = (seenFilms: array<FilmType.film>) => { */
  /* let selectedByKarmi = */
  /* Js.Array2.filter(seenFilms, film => film.creator === FilmType.Karmi)->Js.Array.length */
  /* let selectedByFerma = */
  /* Js.Array2.filter(seenFilms, film => film.creator === Ferma)->Js.Array.length */

  /* selectedByKarmi > selectedByFerma ? FilmType.Ferma : FilmType.Karmi */
  /* } */

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
      <FilmList films selected="" markFilmAsSeen />
      <h3> {React.string("Seen")} </h3>
      <SeenFilmList films=seenFilms />
    </MaxWidthWrapper>
  }
}
