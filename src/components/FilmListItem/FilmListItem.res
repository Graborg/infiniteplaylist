type mouseOver =
  | MouseIsOver
  | MouseNotOver

let item = Emotion.css(`
  display: flex;
  gap: 5px;
  flex-direction: column;
  padding-bottom: 10px;
  border-bottom: 1px solid black;
  position: relative;
  
`)

let creatorBanner = userColor =>
  Emotion.css(
    `
  position: absolute;
  top: 5px;
  left: -5px;
  background-color: var(${userColor});
  border-radius: 2px;
  font-family: var(--font-fancy);
  padding: 4px 4px;
  color: var(--color-background);
  font-weight: 700;
`,
  )

let poster = Emotion.css(`
  max-width:100%;
  height: 100%;
  grid-area: poster;
  border-radius: 10px;
  border: 1px solid var(--color-lightest-gray);
`)

let filmTitle = Emotion.css(`
  text-overflow: ellipsis;
  white-space: nowrap;
  overflow: hidden;
`)

@react.component
let make = (
  ~film: FilmType.film,
  ~click: FilmType.film => unit=_ => Js.log("You forgot to set a onClick handler"),
  ~selected: bool=false,
  (),
) => {
  open TheMovieDB
  let (checked, setCheck) = React.useState(_ => false)

  switch (film.title, film.genres, film.releaseDate, film.posterPath, film.plot) {
  | (title, Some(genres), Some(year), Some(posterPath), Some(plot)) => {
      let userColor = film.creatorIsCurrentUser ? "--color-user" : "--color-partner"
      <li
        key={Belt.Int.toString(film.id)}
        className=item
        onClick={_ => {
          setCheck(prevState => !prevState)
          click(film)
        }}>
        <p className={creatorBanner(userColor)}>
          {React.string(FilmType.creatorToString(film.creatorName))}
        </p>
        <img className=poster src={getPosterPath(posterPath)} />
        <p className=filmTitle> {React.string(title)} </p>
      </li>
    }
  | (title, _, _, _, _) => React.string(title)
  }
}
