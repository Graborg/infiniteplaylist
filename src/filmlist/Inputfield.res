let trimQuotes = str => str->Js.String2.replace("\"", "")->Js.String2.replace("\"", "")
@send external contains: (Dom.element, {..}) => bool = "contains"
@val external window: {..} = "window"
@react.component
let make = (~addFilmToList: string => Js.Promise.t<unit>) => {
  open TheMovieDB
  let (showList, toggleList) = React.useState(_ => true)

  let ((searchText, suggestedFilms, activeOption), setText) = React.useState(_ => ("", [], -1))
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
  let searchDebounced = ReactDebounce.useDebounced(text =>
    TheMovieDBAdapter.search(text, searchRes => {
      setText(((searchString, _prevSearchResults, activeOptionState)) => (
        searchString,
        searchRes,
        activeOptionState,
      ))
    })
  )
  <div ref={ReactDOM.Ref.domRef(wrapperRef)} id="searchbox-wrapper">
    <ul id="suggested-films">
      {showList
        ? Belt.Array.slice(suggestedFilms, ~offset=0, ~len=5)
          ->Belt.Array.mapWithIndex((i, film) =>
            <li
              className={i === activeOption ? "highlight" : ""}
              onClick={item => {
                let currentValue = ReactEvent.Mouse.target(item)["innerText"]
                addFilmToList(currentValue)->ignore
                toggleList(_ => false)
              }}>
              <p>
                {switch (film["title"], film["year"]) {
                | (Some(title), Some(year)) => React.string(`${title} (${year})`)
                | (Some(title), None) => React.string(title)
                | (None, _) => React.string("<error no title>")
                }}
              </p>
            </li>
          )
          ->React.array
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
          addFilmToList(searchText)->ignore
          toggleList(_ => false)
        } else if (
          // Up arrow
          keyCode === 38
        ) {
          setText(((_searchString, suggestedFilmsState, activeOptionState)) => {
            let optionsLength = Belt.Array.length(suggestedFilmsState)
            let newActiveOptionState =
              activeOptionState === optionsLength ? optionsLength : activeOptionState + 1
            Js.log(Js.Array2.unsafe_get(suggestedFilms, newActiveOptionState))
            let selectedFromDropdown =
              Belt.Array.get(suggestedFilms, newActiveOptionState)
              ->Belt.Option.flatMap(filmItem => filmItem["title"])
              ->Belt.Option.getWithDefault("")
            (selectedFromDropdown, suggestedFilmsState, newActiveOptionState)
          })
        } else if (
          // Down arrow
          keyCode === 40
        ) {
          setText(((_searchString, suggestedFilmsState, activeOptionState)) => {
            let newActiveOptionState = activeOptionState === 0 ? 0 : activeOptionState - 1
            let selectedFromDropdown =
              Belt.Array.get(suggestedFilmsState, newActiveOptionState)
              ->Belt.Option.flatMap(filmItem => filmItem["title"])
              ->Belt.Option.getWithDefault("")

            (selectedFromDropdown, suggestedFilmsState, newActiveOptionState)
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
