@val @scope("window") external addEventListener: (string, 'a => unit) => unit = "addEventListener"
@val @scope("window")
external removeEventListener: (string, 'a => unit) => unit = "removeEventListener"

let wrapper = Emotion.css(`
  background-color: var(--color-background);
  position: absolute;
  width: 100%;
  border: 1px solid var(--color-primary);
  border-top: 0;
  border-radius: 0 0 4px 4px;
  max-width: 600px;
  right: 0;
`)
let opacityWrapper = Emotion.css(`
  @keyframes fadeOutAlittle {
    from {
      filter: opacity(0);
    }
    to {
      filter: opacity(0.5);
    }
  }
  position: absolute;
  width: 100%;
  height: 100vh;
  background-color: var(--color-background);
  animation: fadeOutAlittle 700ms ease both;
`)

@react.component
let make = (
  ~showList: bool,
  ~results: TheMovieDB.results,
  ~handleNewFilm: TheMovieDB.searchResult => unit,
) => {
  let maxResultLength = 5

  showList
    ? <div>
        <div className=opacityWrapper />
        <ul className=wrapper>
          {switch results {
          | NoResultsInit => React.string("")
          | NoResultsFound => <li> {React.string("No results found")} </li>
          | Results(suggestedFilmList) =>
            suggestedFilmList
            ->Belt.Array.slice(~offset=0, ~len=maxResultLength)
            ->Belt.Array.mapWithIndex((_i, film) =>
              <SearchListItem film clickHandler=handleNewFilm key={Belt.Int.toString(film.id)} />
            )
            ->React.array
          }}
        </ul>
      </div>
    : React.string("")
}
