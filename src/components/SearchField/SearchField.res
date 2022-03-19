@send external contains: (Dom.element, {..}) => bool = "contains"
@val @scope("window") external addEventListener: (string, 'a => unit) => unit = "addEventListener"

open TheMovieDB
open Emotion

let wrapper = css(`
  @keyframes fadeDown {
    from {
      transform: translateY(-50%);
      filter: opacity(0);
    }
    to {
      transform: translateY(0);
      filter: opacity(1);
    }
  }
  position: relative;
  animation: fadeDown 1200ms 500ms both ease;
  z-index: 1;
`)

@react.component
let make = (~addFilmHandler: TheMovieDB.searchResult => unit, ~disabled: bool=false, ()) => {
  let (showList, toggleList) = React.useState(_ => false)
  let (results, setResults) = React.useState(() => TheMovieDB.NoResultsInit)

  let handleNewFilm = film => {
    toggleList(_ => false)
    addFilmHandler(film)
  }

  let searchDebounced = ReactThrottle.useThrottled(~wait=100, text => {
    switch text {
    | "" => setResults(_ => TheMovieDB.NoResultsInit)
    | searchText => TheMovieDBAdapter.search(searchText, res => setResults(_ => res))->ignore
    }
  })

  let onFocusHandler = _ => {
    switch results {
    | Results(_) => toggleList(_ => true)
    | _ => ignore()
    }
  }
  let onChangeHandler = (text: string) => {
    searchDebounced(text)
    toggleList(_ => true)
  }
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

  <div
    onKeyDown={key => {
      if ReactEvent.Keyboard.key(key) === "Escape" {
        toggleList(_ => false)
      }
    }}
    className=wrapper
    ref={ReactDOM.Ref.domRef(wrapperRef)}>
    <InputField
      id="searchbox"
      placeholder="Star wars: The empire str.."
      labelName="Add new movie to list"
      onFocusHandler
      onChangeHandler
      borderRadiusBottom={!showList}
      disabled
      icon=#Search
    />
    <SearchResults showList results handleNewFilm />
  </div>
}
