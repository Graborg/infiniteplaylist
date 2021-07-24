let trimQuotes = str => str->Js.String2.replace("\"", "")->Js.String2.replace("\"", "")

@react.component
let make = () => {
  open IMDB
  let ((searchText, suggestedFilms, showOptions, activeOption), setText) = React.useState(_ => (
    "",
    [],
    false,
    -1,
  ))

  let searchDebounced = ReactDebounce.useDebounced(text => IMDBService.search(text, setText))

  <div>
    <input
      value={searchText}
      onKeyDown={e => {
        let keyCode = ReactEvent.Keyboard.keyCode(e)
        // Enter
        if keyCode === 13 {
          setText(((_searchString, suggestedFilmsState, _, activeOptionState)) => (
            Js.Array2.unsafe_get(suggestedFilms, activeOptionState)
            ->Belt.Option.map(e =>
              e["title"]->Belt.Option.getWithDefault(Js.Json.string(""))->Js.Json.stringify
            )
            ->Belt.Option.getWithDefault("")
            ->trimQuotes,
            suggestedFilmsState,
            false,
            activeOptionState,
          ))
        } else if (
          // Up arrow
          keyCode === 38
        ) {
          setText(((searchString, suggestedFilmsState, showOptionsState, activeOptionState)) => (
            searchString,
            suggestedFilmsState,
            showOptionsState,
            activeOptionState === 0 ? 0 : activeOptionState - 1,
          ))
        } else if (
          // Down arrow
          keyCode === 40
        ) {
          setText(((searchString, suggestedFilmsState, showOptionsState, activeOptionState)) => (
            searchString,
            suggestedFilmsState,
            showOptionsState,
            activeOptionState === Belt.Array.length(suggestedFilmsState) - 1
              ? activeOptionState
              : activeOptionState + 1,
          ))
        }
      }}
      onChange={e => {
        let currentValue = ReactEvent.Form.target(e)["value"]
        setText(((_searchString, suggestedFilmsState, _, activeOptionState)) => (
          currentValue,
          suggestedFilmsState,
          true,
          -1,
        ))
        searchDebounced(currentValue)
      }}
    />
    <ul id="suggested-films">
      {showOptions
        ? Belt.Array.slice(suggestedFilms, ~offset=0, ~len=5)
          ->Belt.Array.mapWithIndex((i, film) =>
            Belt.Option.mapWithDefault(film, React.string(""), someFilm =>
              <li
                className={i === activeOption ? "highlight" : ""}
                onClick={item => {
                  let currentValue = ReactEvent.Mouse.target(item)["innerText"]
                  setText(((_searchString, suggestedFilmsState, _, -1)) => (
                    currentValue,
                    suggestedFilmsState,
                    false,
                    -1,
                  ))
                }}>
                <p>
                  {
                    let title =
                      Js.Json.stringify(
                        Belt.Option.getWithDefault(someFilm["title"], Js.Json.string("")),
                      )->trimQuotes
                    let year =
                      Js.Json.stringify(
                        Belt.Option.getWithDefault(someFilm["year"], Js.Json.string("")),
                      )->trimQuotes
                    React.string(`${title} (${year})`)
                  }
                </p>
              </li>
            )
          )
          ->React.array
        : React.string("")}
    </ul>
  </div>
}
