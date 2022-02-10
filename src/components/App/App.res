open Todoist
type state =
  | LoadingFilms
  | ErrorFetchingFilms
  | LoadedFilms(array<Todoist.film>, string, array<Todoist.film>)
  | NotLoggedin

type url = {
  /* path takes window.location.pathname, like "/book/title/edit" and turns it into `["book", "title", "edit"]` */
  path: list<string>,
  /* the url's hash, if any. The # symbol is stripped out for you */
  hash: string,
  /* the url's query params, if any. The ? symbol is stripped out for you */
  search: string,
}

@react.component
let make = () => {
  let (state, setState) = React.useState(() => LoadingFilms)

  let doSelectFilm = filmId =>
    setState(prevState =>
      switch prevState {
      | LoadedFilms(list, _selected, seenFilms) => LoadedFilms(list, filmId, seenFilms)
      }
    )
  let url = RescriptReactRouter.useUrl()

  React.useEffect0(() => {
    open Js.Promise
    switch LocalStorage.getToken() {
    | None =>
      switch url.search {
      | "" => setState(_preState => NotLoggedin)
      | search =>
        Todoist.searchStringToCode(search)
        ->Belt.Option.map(e =>
          Todoist.setToken(e)
          |> then_(Todoist.getFilms)
          |> then_(films => {
            setState(_preState => LoadedFilms(films, "", []))
            resolve()
          })
        )
        ->ignore
      }
    | Some(token) =>
      Todoist.getFilms(token)
      |> then_((films: array<Todoist.film>) => {
        let unseen = films->Js.Array2.filter(film => !film.seen)
        let seen = films->Js.Array2.filter(film => film.seen)
        setState(_prevState => LoadedFilms(unseen, "", seen))
        resolve()
      })
      |> ignore
    }
    None
  })
  let markFilmAsSeen = (film: Todoist.film) => {
    // let _k = Todoist.setFilmAsSeen(film)
    Js.Global.setTimeout(() => {
      setState((LoadedFilms(films, selected, seenFilms)) => {
        let newUnseen = Js.Array2.filter(films, f => f.name !== film.name)
        let newSeenFilms = Js.Array.concat(seenFilms, [film])
        LoadedFilms(newUnseen, selected, newSeenFilms)
      })
    }, 500) |> ignore
  }

  let unDooSeenFilm = (film: Todoist.film) => {
    //let _k = Todoist.setFilmAsUnseen(film)
    Js.Global.setTimeout(() => {
      setState((LoadedFilms(films, selected, seenFilms)) => {
        let newSeenFilms = Js.Array2.filter(seenFilms, f => f.name !== film.name)
        let newUnseen = Js.Array.concat(films, [film])
        LoadedFilms(newUnseen, selected, newSeenFilms)
      })
    }, 500) |> ignore
  }

  let getNextElector = (seenFilms: array<Todoist.film>) => {
    open Todoist
    let selectedByKarmi =
      Js.Array2.filter(seenFilms, film => film.creator === Karmi)->Js.Array.length
    let selectedByFerma =
      Js.Array2.filter(seenFilms, film => film.creator === Ferma)->Js.Array.length

    selectedByKarmi > selectedByFerma ? Ferma : Karmi
  }
  let addFilmToList = (filmName: TheMovieDB.filmResult) => {
    filmName |> Todoist.addFilm
    /* |> Js.Promise.then_(((creator, filmId)) => { */
    /* let film: Todoist.film = { */
    /* name: filmName, */
    /* seen: false, */
    /* id: filmId, */
    /* creator: creator, */
    /* } */
    /* setState((LoadedFilms(films, selected, seenFilms)) => { */
    /* let newUnseen = Js.Array.concat([film], films) */
    /* LoadedFilms(newUnseen, selected, seenFilms) */
    /* }) */
    /* Js.Promise.resolve() */
    /* }) */
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

  {
    switch state {
    | ErrorFetchingFilms => React.string("An error occurred!")
    | LoadingFilms => <Spinner />
    | NotLoggedin =>
      <div className=wrapper>
        <MaxWidthWrapper> <Header /> </MaxWidthWrapper> <LoginButton /> <Footer />
      </div>
    | LoadedFilms(films, selected, seenFilms) =>
      <MaxWidthWrapper>
        <Header />
        <SearchField addFilmHandler=addFilmToList />
        <h3 className=listTitle> {React.string("Not seen")} </h3>
        <FilmList films selected markFilmAsSeen />
        <h3> {React.string("Seen")} </h3>
        <SeenFilmList films=seenFilms />
      </MaxWidthWrapper>
    }
  }
}
