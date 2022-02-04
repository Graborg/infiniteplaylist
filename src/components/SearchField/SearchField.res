@send external contains: (Dom.element, {..}) => bool = "contains"
@val external window: {..} = "window"

open TheMovieDB
open Emotion

let wrapper = css(`
  position: relative;
  border: 1px solid var(--color-primary);
  border-radius: 4px;
`)

let inputField = css(`
  background-color: transparent;
  width: 100%;
  padding: 10px;
  padding-left: 34px;
  border: 0;
  font-family: var(--font-bread);
`)

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

let handleNewFilm = (film: filmResult) => Js.log(film["title"])

@react.component
let make = (~disabled: bool=false, ()) => {
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
    window["addEventListener"]("mousedown", handleClickOutside)
    None
  })

  <div className=wrapper ref={ReactDOM.Ref.domRef(wrapperRef)}>
    <label htmlFor="searchbox" className=label> {React.string(`Add new movie to list`)} </label>
    <ReactFeather.Search className=searchIcon size=24 />
    <input
      className={inputField}
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
    <SearchResults showList results handleNewFilm />
  </div>
}
