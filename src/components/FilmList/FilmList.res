open Todoist

@react.component
let make = (~films: array<Todoist.film>, ~selected, ~markFilmAsSeen) =>
  <div className="film-list">
    {films
    ->Belt.Array.mapWithIndex((i, film) => {
      let lastElement = i === Js.Array.length(films) - 1
      let selected = selected == film.name
      <FilmListItem
        key={Belt.Float.toString(film.id) ++ "h"} film lastElement selected click=markFilmAsSeen
      />
    })
    ->React.array}
  </div>
