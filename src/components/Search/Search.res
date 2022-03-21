@send external contains: (Dom.element, {..}) => bool = "contains"
@val @scope("window") external addEventListener: (string, 'a => unit) => unit = "addEventListener"
@send external focus: Dom.element => unit = "focus"
@val external value: unit = "value"

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
let make = (~onItemSelect: TheMovieDB.searchResult => unit, ~disabled: bool=false, ()) => {
  let (showList, toggleList) = React.useState(_ => false)
  let (results, setResults) = React.useState(() => TheMovieDB.NoResultsInit)
  let (text, setText) = React.useState(_ => "")

  let wrapperRef = React.useRef(Js.Nullable.null)
  let inputRef = React.useRef(Js.Nullable.null)

  let handleNewFilm = film => {
    setText(_ => "")
    inputRef.current->Js.Nullable.toOption->Belt.Option.map(dom => focus(dom))->ignore
    toggleList(_ => false)
    onItemSelect(film)
  }

  let searchDebounced = ReactThrottle.useThrottled(~wait=100, text => {
    switch text {
    | "" => setResults(_ => TheMovieDB.NoResultsInit)
    | searchText => TheMovieDBAdapter.search(searchText, res => setResults(_ => res))->ignore
    }
  })

  let onFocus = _ => {
    switch results {
    | Results(_) => toggleList(_ => true)
    | _ => ignore()
    }
  }

  let onChange = e => {
    let currentText = ReactEvent.Form.target(e)["value"]
    setText(currentText)
    searchDebounced(text)
    toggleList(_ => true)
  }

  React.useEffect0(() => {
    let handleClick = (event: ReactEvent.Mouse.t) =>
      switch wrapperRef.current->Js.Nullable.toOption {
      | Some(dom) if dom->contains(ReactEvent.Mouse.target(event)) => ()
      | _ => toggleList(_ => false)
      }

    addEventListener("mousedown", handleClick)

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
      onFocus
      onChange
      borderRadiusBottom={!showList}
      disabled
      icon=#Search
      inputRef={ReactDOM.Ref.domRef(inputRef)}
      value=text
    />
    <SearchListResults showList results handleNewFilm />
  </div>
}
