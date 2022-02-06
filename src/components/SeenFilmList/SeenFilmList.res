open Todoist
@react.component
let make = (~films: array<Todoist.film>) =>
  <div className="film-list">
    {films
    ->Belt.Array.map(film => <FilmListItem key={Belt.Int.toString(film.id) ++ "h"} film />)
    ->React.array}
  </div>
