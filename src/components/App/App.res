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

@react.component
let make = () => {
  let (state, setState) = React.useState(() => LoadingFilms)
  let (filmRandomlySelected, randomlySelectFilm) = React.useState(() => "")
  //let (user, setUser) = React.useState(() => None)

  let doSelectFilm = filmId =>
    setState(prevState =>
      switch prevState {
      | LoadedFilms(list, seenFilms) => LoadedFilms(list, seenFilms)
      | _ => prevState
      }
    )

  let url = RescriptReactRouter.useUrl()

  /* React.useEffect0(() => { */
  /* open FilmType */
  /* let user = LocalStorage.getUser() */
  /* setUser(_ => FilmType.getCreator(user)->Some(Ferma)) */
  /* None */
  /* }) */
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
            setState(_preState => LoadedFilms(films, []))
            resolve()
          })
        )
        ->ignore
      }
    | Some(token) =>
      Todoist.getFilms(token)
      |> then_((films: array<FilmType.film>) => {
        let unseen = films->Js.Array2.filter(film => !film.seen)
        let seen = films->Js.Array2.filter(film => film.seen)
        setState(_prevState => LoadedFilms(unseen, seen))
        resolve()
      })
      |> ignore
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

  let addFilmToList: TheMovieDB.searchResult => unit = searchItem => {
    open Js.Promise
    let film: FilmType.film = {
      id: searchItem.id,
      title: searchItem.title,
      creator: Karmi, //TODO: Make dynamic from login
      releaseDate: searchItem.releaseDate,
      posterPath: searchItem.posterPath,
      plot: searchItem.plot,
      language: searchItem.language,
      genres: searchItem.genres,
      seen: false,
    }
    film
    |> Todoist.addFilm
    |> then_(_ => {
      let _u = setState(state =>
        switch state {
        | LoadedFilms(films, seenFilms) => {
            let newUnseen = Js.Array.concat([film], films)
            LoadedFilms(newUnseen, seenFilms)
          }
        }
      )
      resolve("")
    })
    |> ignore
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
      <SearchField addFilmHandler=addFilmToList />
      <h3 className=listTitle> {React.string("Not seen")} </h3>
      <FilmList films selected=filmRandomlySelected markFilmAsSeen />
      <h3> {React.string("Seen")} </h3>
      <SeenFilmList films=seenFilms />
    </MaxWidthWrapper>
  }
}
