@react.component
let make = (~films: array<FilmType.film>) =>
  <div className="film-list">
    {films
    ->Belt.Array.map(film => <FilmListItem key={Belt.Int.toString(film.id) ++ "h"} film />)
    ->React.array}
  </div>
