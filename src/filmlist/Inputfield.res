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
      onChange={e => {
        let currentValue = ReactEvent.Form.target(e)["value"]
        setText(((_searchString, suggestedFilmsState, _, _)) => (
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
          ->Belt.Array.map(film =>
            Belt.Option.mapWithDefault(film, React.string(""), someFilm =>
              <li
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
