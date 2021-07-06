open Todoist
type state =
  | LoadingFilms
  | ErrorFetchingFilms
  | LoadedFilms(array<Todoist.film>, string)
  | NotLoggedin

type url = {
  /* path takes window.location.pathname, like "/book/title/edit" and turns it into `["book", "title", "edit"]` */
  path: list<string>,
  /* the url's hash, if any. The # symbol is stripped out for you */
  hash: string,
  /* the url's query params, if any. The ? symbol is stripped out for you */
  search: string,
}

let selectFilm = (setState, filmId) =>
  setState(prevState =>
    switch prevState {
    | LoadedFilms(list, _selected) => LoadedFilms(list, filmId)
    }
  )

@react.component
let make = () => {
  let (state, setState) = React.useState(() => LoadingFilms)
  let selectFilmWithSetState = selectFilm(setState)

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
          setState(_preState => LoadedFilms(films, ""))
          Js.Promise.resolve()
        })
        |> ignore
      }
    | Some(token) =>
      Todoist.getFilms(token)
      |> Js.Promise.then_(films => {
        setState(_prevState => LoadedFilms(films, ""))
        Js.Promise.resolve()
      })
      |> ignore
    }
    None
  })
  switch state {
  | ErrorFetchingFilms => React.string("An error occurred!")
  | LoadingFilms => React.string("Loading...")
  | NotLoggedin => <a href=todoistLoginLink> {React.string("Log into Todoist")} </a>
  | LoadedFilms(films, selected) =>
    <div style={ReactDOMStyle.make(~width="100%", ())}>
      <Title />
      <div className="film-list">
        {films
        ->Belt.Array.mapWithIndex((id, film) => {
          let lastElement = id === Js.Array.length(films) - 1
          let selected = selected == film.name
          <FilmlistItem film id lastElement selected />
        })
        ->React.array}
      </div>
      <RandomBtn films selectFilmWithSetState />
    </div>
  }
}
