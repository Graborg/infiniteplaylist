@val external window: {..} = "window"
open TheMovieDB

type keyCode =
  | Enter
  | UpArrow
  | DownArrow

let keyCodesToVariant = Belt.Map.Int.fromArray([(13, Enter), (38, UpArrow), (40, DownArrow)])

let wrapper = Emotion.css(`
  background-color: var(--color-background);
  position: absolute;
  width: 100%;
  border: 1px solid var(--color-primary);
`)
let highlightedItem = Emotion.css(`
  background-color: var(--color-primary);
`)

let moveDownInList = (~length, ~maxResultLength, ~changeOption) => {
  let lastIndex = min(length, maxResultLength) - 1
  changeOption(oldActiveOption => {
    let newActiveOption = oldActiveOption + 1
    newActiveOption >= min(lastIndex, maxResultLength)
      ? min(lastIndex, maxResultLength)
      : newActiveOption
  })
}

let moveUpInList = (~changeOption) =>
  changeOption(oldActiveOption => oldActiveOption === 0 ? 0 : oldActiveOption - 1)

@react.component
let make = (
  ~showList: bool,
  ~results: TheMovieDB.results,
  ~handleNewFilm: TheMovieDB.filmResult => unit,
) => {
  let (activeOption, changeOption) = React.useState(() => -1)
  let maxResultLength = 5
  let keyHandler = e =>
    switch results {
    | NoResultsInit => ignore()
    | NoResultsFound => ignore()
    | Results(films) => {
        let length = Array.length(films)
        let key = Belt.Map.Int.get(keyCodesToVariant, ReactEvent.Keyboard.keyCode(e))
        switch key {
        | Some(Enter) => Js.log("enter")
        | Some(UpArrow) => moveUpInList(~changeOption)
        | Some(DownArrow) => moveDownInList(~length, ~maxResultLength, ~changeOption)
        | None => ignore()
        }
      }
    }
  React.useEffect(() => {
    window["addEventListener"]("keydown", keyHandler)

    Some(() => window["removeEventListener"]("keydown", keyHandler))
  })

  showList
    ? <ul className=wrapper>
        {switch results {
        | NoResultsInit => React.string("")
        | NoResultsFound => <li> {React.string("No results found")} </li>
        | Results(suggestedFilmList) =>
          suggestedFilmList
          ->Belt.Array.slice(~offset=0, ~len=maxResultLength)
          ->Belt.Array.mapWithIndex((_i, film) =>
            switch film["id"] {
            | Some(id) => <SearchListItem film clickHandler=handleNewFilm key=id />
            | _ => <p> {React.string("Can't render item")} </p>
            }
          )
          ->React.array
        }}
      </ul>
    : React.string("")
}
