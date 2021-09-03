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
    switch Dom.Storage.getItem(localStorageNamespace, Dom.Storage.localStorage) {
    | None =>
      switch url.search {
      | "" => setState(_preState => NotLoggedin)
      | search =>
        Todoist.searchStringToCode(search)
        |> Todoist.setToken
        |> Js.Promise.then_(Todoist.getFilms)
        |> Js.Promise.then_(films => {
          setState(_preState => LoadedFilms(films, "", []))
          Js.Promise.resolve()
        })
        |> ignore
      }
    | Some(token) =>
      Todoist.getFilms(token)
      |> Js.Promise.then_((films: array<Todoist.film>) => {
        let unseen = films->Js.Array2.filter(film => !film.seen)
        let seen = films->Js.Array2.filter(film => film.seen)
        setState(_prevState => LoadedFilms(unseen, "", seen))
        Js.Promise.resolve()
      })
      |> ignore
    }
    None
  })
  let seenFilm = (film: Todoist.film) => {
    let _k = Todoist.setFilmAsSeen(film)
    Js.Global.setTimeout(() => {
      setState((LoadedFilms(films, selected, seenFilms)) => {
        let newUnseen = Js.Array2.filter(films, f => f.name !== film.name)
        let newSeenFilms = Js.Array.concat(seenFilms, [film])
        LoadedFilms(newUnseen, selected, newSeenFilms)
      })
    }, 500) |> ignore
  }

  let unDooSeenFilm = (film: Todoist.film) => {
    let _k = Todoist.setFilmAsUnseen(film)
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
  let addFilmToList = (filmName: string) => {
    Todoist.addFilm(filmName) |> Js.Promise.then_(((creator, filmId)) => {
      let film: Todoist.film = {
        name: filmName,
        seen: false,
        id: filmId,
        creator: creator,
      }
      setState((LoadedFilms(films, selected, seenFilms)) => {
        let newUnseen = Js.Array.concat([film], films)
        LoadedFilms(newUnseen, selected, seenFilms)
      })
      Js.Promise.resolve()
    })
  }
  switch state {
  | ErrorFetchingFilms => React.string("An error occurred!")
  | LoadingFilms => React.string("Loading...")
  | NotLoggedin => <a href=todoistLoginLink> {React.string("Log into Todoist")} </a>
  | LoadedFilms(films, selected, seenFilms) =>
    <div key="filmlist" style={ReactDOMStyle.make(~width="100%", ())}>
      <Title />
      <div className="film-list">
        {films
        ->Belt.Array.mapWithIndex((i, film) => {
          let lastElement = i === Js.Array.length(films) - 1
          let selected = selected == film.name
          <FilmlistItem
            key={Belt.Float.toString(film.id) ++ "h"} film lastElement selected click=seenFilm
          />
        })
        ->React.array}
      </div>
      {Js.Array.length(seenFilms) > 0
        ? <div>
            <p style={ReactDOMStyle.make(~margin="10px 0 10px 10px", ())}>
              {React.string("Peliculas vistas")}
            </p>
            <div className="film-list">
              {seenFilms
              ->Belt.Array.mapWithIndex((i, film) => {
                let lastElement = i === Js.Array.length(films) - 1
                let selected = selected == film.name
                <FilmlistItem
                  key={Belt.Float.toString(film.id) ++ "h"}
                  film
                  lastElement
                  selected
                  click=unDooSeenFilm
                />
              })
              ->React.array}
            </div>
          </div>
        : <div />}
      <div id="underfilmlist-items">
        <Inputfield addFilmToList />
        <RandomBtn films doSelectFilm nextElector={getNextElector(seenFilms)} />
      </div>
    </div>
  }
}
