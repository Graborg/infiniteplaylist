@send external contains: (Dom.element, {..}) => bool = "contains"
@val external window: {..} = "window"
@react.component
let make = (~addFilmToList=?, ~disabled=false) => {
  open TheMovieDB
  open Belt
  let (showList, toggleList) = React.useState(_ => true)

  let ((searchText, suggestedFilms, activeOption), setText) = React.useState(_ => (
    "",
    NoResultsInit,
    -1,
  ))
  let wrapperRef = React.useRef(Js.Nullable.null)
  React.useEffect0(() => {
    let handleClickOutside = (event: ReactEvent.Mouse.t) =>
      switch wrapperRef.current->Js.Nullable.toOption {
      | Some(dom) if dom->contains(ReactEvent.Mouse.target(event)) => ()
      | _ => toggleList(_ => false)
      }
    window["addEventListener"]("mousedown", handleClickOutside)
    None
  })
  let selectItemFromList = film => {
    Option.map(addFilmToList, func => func(film))->ignore
    setText(((_, _, _)) => ("", NoResultsInit, -1))
  }
  let searchDebounced = ReactDebounce.useDebounced(text =>
    TheMovieDBAdapter.search(text, res =>
      setText(((searchString, _prevRes, activeOptionState)) => (
        searchString,
        res,
        activeOptionState,
      ))
    ) |> ignore
  )
  <div ref={ReactDOM.Ref.domRef(wrapperRef)} id="searchbox-wrapper">
    <ul id="suggested-films">
      {showList
        ? switch suggestedFilms {
          | NoResultsInit => React.string("")
          | NoResultsFound => <li> {React.string("No results found")} </li>
          | Results(suggestedFilmList) =>
            Belt.Array.slice(suggestedFilmList, ~offset=0, ~len=5)
            ->Belt.Array.mapWithIndex((i, film) =>
              <li
                className={i === activeOption ? "highlight" : ""}
                onClick={item => {
                  ReactEvent.Mouse.target(item)["innerText"]->selectItemFromList->ignore
                }}>
                <p>
                  {switch (film["title"], film["year"]) {
                  | (Some(title), Some("")) => React.string(title)
                  | (Some(title), None) => React.string(title)
                  | (Some(title), Some(year)) => React.string(`${title} (${year})`)
                  | (_, _) => React.string("<error no title>")
                  }}
                </p>
              </li>
            )
            ->React.array
          }
        : React.string("")}
    </ul>
    <input
      placeholder="Añada pelicula"
      id="searchbox"
      value={searchText}
      onFocus={e => toggleList(_ => true)}
      onKeyDown={e => {
        let keyCode = ReactEvent.Keyboard.keyCode(e)
        // Enter
        if keyCode === 13 {
          switch suggestedFilms {
          | NoResultsInit => ignore()
          | NoResultsFound => ignore()
          | Results(suggestedFilms) =>
            suggestedFilms[activeOption]
            ->Option.flatMap(e =>
              Option.map(e["title"], title => {
                let year = Option.mapWithDefault(e["year"], "", year => " (" ++ year ++ ")")
                title ++ year
              })
            )
            ->Option.map(selectItemFromList)
            ->ignore
          }
        } else if (
          // Up arrow
          keyCode === 38
        ) {
          setText(((searchString, suggestedFilmsState, activeOptionState)) => {
            switch suggestedFilmsState {
            | NoResultsInit => (searchString, suggestedFilmsState, activeOptionState)
            | NoResultsFound => (searchString, suggestedFilmsState, activeOptionState)
            | Results(filmList) =>
              let optionsLength = Belt.Array.length(filmList)
              let newActiveOptionState =
                activeOptionState === optionsLength ? optionsLength : activeOptionState + 1
              let selectedFromDropdown =
                Belt.Array.get(filmList, newActiveOptionState)
                ->Belt.Option.flatMap(filmItem => filmItem["title"])
                ->Belt.Option.getWithDefault("")
              (selectedFromDropdown, suggestedFilmsState, newActiveOptionState)
            }
          })
        } else if (
          // Down arrow
          keyCode === 40
        ) {
          setText(((searchString, suggestedFilmsState, activeOptionState)) => {
            switch suggestedFilmsState {
            | NoResultsInit => (searchString, suggestedFilmsState, activeOptionState)
            | NoResultsFound => (searchString, suggestedFilmsState, activeOptionState)
            | Results(filmList) =>
              let newActiveOptionState = activeOptionState === 0 ? 0 : activeOptionState - 1
              let selectedFromDropdown =
                Belt.Array.get(filmList, newActiveOptionState)
                ->Belt.Option.flatMap(filmItem => filmItem["title"])
                ->Belt.Option.getWithDefault("")

              (selectedFromDropdown, suggestedFilmsState, newActiveOptionState)
            }
          })
        }
      }}
      onChange={e => {
        let currentValue = ReactEvent.Form.target(e)["value"]
        setText(((_searchString, suggestedFilmsState, _activeOptionState)) => (
          currentValue,
          suggestedFilmsState,
          -1,
        ))
        searchDebounced(currentValue)
      }}
    />
    <label htmlFor="searchbox" className="searchbox__label">
      {React.string(`Añada pelicula`)}
    </label>
  </div>
}
