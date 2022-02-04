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

let itemWrapper = Emotion.css(`
  display: grid; 
  grid-template-columns: 2fr 1fr; 
  grid-template-rows:  1fr auto;
  grid-template-areas:
    'header poster'
    'plot poster';
  padding: 12px 8px;
  column-gap: 12px;
  row-gap: 12px;
  border-bottom: 1px solid var(--color-primary);
  font-size: 1rem;
`)

let itemHeader = Emotion.css(`
  grid-area: header;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  gap: 4px;
  color: var(--color-lightest-gray);
  font-family: var(--font-fancy);
`)

let titleWrapper = Emotion.css(`
  display: flex;
  overflow: hidden;
  white-space: nowrap;
  gap: 4px;
  font-weight: bold;
  font-size: 1.125rem;
  color: var(--color-black);
`)

let itemTitle = Emotion.css(`
  text-overflow: ellipsis;
  overflow:hidden;
  white-space: nowrap;
  font-style: oblique 12deg;
`)

let itemPlot = Emotion.css(`
  grid-area: plot;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 5;
  overflow: hidden;
  height: fit-content;
  color: var(--color-black);
`)

let poster = Emotion.css(`
  max-width:100%;
  height: 100%;
  grid-area: poster;
  border-radius: 4px;
`)

let resultItem = (film: TheMovieDB.filmResult, active: bool, clickHandler, i) =>
  <li key={Belt.Int.toString(i)} onClick={item => clickHandler(film)}>
    {switch (film["title"], film["genres"], film["year"], film["poster_path"], film["plot"]) {
    | (Some(title), Some(genres), Some(year), Some(poster_path), Some(plot)) =>
      <div className=itemWrapper>
        <div className=itemHeader>
          <p className=titleWrapper>
            <span className=itemTitle> {React.string(title)} </span>
            <span> {React.string(`(${year})`)} </span>
            <span> {React.string(`•`)} </span>
            <span> {React.string(`2h 35m`)} </span>
          </p>
          <span>
            {React.string(genres->Belt.Array.slice(~offset=0, ~len=2)->Js.Array2.joinWith("/"))}
          </span>
        </div>
        <p className=itemPlot> {React.string(plot)} </p>
        <img className=poster src={poster_uri ++ poster_path} />
      </div>
    | (Some(title), _, _, _, _) => React.string(title)
    | (_, _, _, _, _) => React.string("<error no title>")
    }}
  </li>

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
          Belt.Array.slice(suggestedFilmList, ~offset=0, ~len=maxResultLength)
          ->Belt.Array.mapWithIndex((i, film) =>
            resultItem(film, i === activeOption, handleNewFilm, i)
          )
          ->React.array
        }}
      </ul>
    : React.string("")
}
