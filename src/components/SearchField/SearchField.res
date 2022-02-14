@send external contains: (Dom.element, {..}) => bool = "contains"
@val @scope("window") external addEventListener: (string, 'a => unit) => unit = "addEventListener"

open TheMovieDB
open Emotion

let wrapper = css(`
  position: relative;
`)

let inputField = showList =>
  css(
    `
  background-color: transparent;
  width: 100%;
  padding: 10px;
  padding-left: 34px;
  border: 0;
  font-family: var(--font-bread);
  border: 1px solid var(--color-primary);
  border-radius: ${showList ? "4px 4px 0 0" : "4px"};
`,
  )

let label = css(`
  position: absolute;
  top: -12px;
  left: 8px;
  padding-right: 5px;
  background-color: var(--color-background);
  color: var(--color-primary);
  font-weight: 700;
`)
let searchIcon = css(`
  position: absolute;
  left: 5px;
  top: 7px;
  color: var(--color-primary);
`)

@react.component
let make = (~addFilmHandler: TheMovieDB.searchResult => unit, ~disabled: bool=false, ()) => {
  let (showList, toggleList) = React.useState(_ => false)
  let (searchText, setText) = React.useState(_ => "")
  let (results, setResults) = React.useState(() => TheMovieDB.NoResultsInit)

  let searchDebounced = ReactThrottle.useThrottled(~wait=100, text => {
    TheMovieDBAdapter.search(text, res => {
      setResults(_ => res)
    }) |> ignore
  })

  let wrapperRef = React.useRef(Js.Nullable.null)

  React.useEffect0(() => {
    let handleClickOutside = (event: ReactEvent.Mouse.t) =>
      switch wrapperRef.current->Js.Nullable.toOption {
      | Some(dom) if dom->contains(ReactEvent.Mouse.target(event)) => ()
      | _ => toggleList(_ => false)
      }
    addEventListener("mousedown", handleClickOutside)

    None
  })

  <div className=wrapper ref={ReactDOM.Ref.domRef(wrapperRef)}>
    <label htmlFor="searchbox" className=label> {React.string(`Add new movie to list`)} </label>
    <ReactFeather.Search className=searchIcon size=24 />
    <input
      className={inputField(showList)}
      disabled
      placeholder="Star wars: The empire str.."
      id="searchbox"
      value={searchText}
      onFocus={e => {
        switch results {
        | Results(_) => toggleList(_ => true)
        | _ => ignore()
        }
      }}
      onChange={e => {
        let currentText = ReactEvent.Form.target(e)["value"]
        setText(currentText)
        searchDebounced(currentText)
        toggleList(_ => true)
      }}
    />
    <SearchResults showList results handleNewFilm=addFilmHandler />
  </div>
}
