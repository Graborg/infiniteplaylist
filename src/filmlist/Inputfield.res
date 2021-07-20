let trimQuotes = str => str->Js.String2.replace("\"", "")->Js.String2.replace("\"", "")

@react.component
let make = () => {
  open IMDB
  let ((searchText, suggestedFilms, showOptions), setText) = React.useState(_ => ("", [], false))

  let searchDebounced = ReactDebounce.useDebounced(text => IMDBService.search(text, setText))

  <div>
    <input
      value={searchText}
      onChange={e => {
        let currentValue = ReactEvent.Form.target(e)["value"]
        setText(((_searchString, suggestedFilmsState, _)) => (
          currentValue,
          suggestedFilmsState,
          true,
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
                  setText(((_searchString, suggestedFilmsState, _)) => (
                    currentValue,
                    suggestedFilmsState,
                    false,
                  ))
                }}>
                <p> {React.string(Js.Json.stringify(someFilm)->trimQuotes)} </p>
              </li>
            )
          )
          ->React.array
        : React.string("")}
    </ul>
  </div>
}
