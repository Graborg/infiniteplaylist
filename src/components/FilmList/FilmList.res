@react.component
let make = (~films: array<Todoist.film>, ~selected, ~markFilmAsSeen) =>
  <div className="film-list">
    {films
    ->Belt.Array.map(film => {
      let selected = selected == film.name
      <FilmListItem key={Belt.Int.toString(film.id) ++ "h"} film selected click=markFilmAsSeen />
    })
    ->React.array}
  </div>
