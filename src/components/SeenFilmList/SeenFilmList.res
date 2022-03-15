let listClass = Emotion.css(`
  margin-top: 10px;
  --min-column-width: min(170px, 100%);
  display: grid;
  gap: 16px;
  grid-template-columns:
  repeat(auto-fill, minmax(var(--min-column-width), 1fr));
`)
@react.component
let make = (~films: array<FilmType.film>) =>
  <div className=listClass>
    {films
    ->Belt.Array.map(film => <FilmListItem key={Belt.Int.toString(film.id) ++ "h"} film />)
    ->React.array}
  </div>
