@react.component
let make = (~films: array<FilmType.film>, ~selected, ~markFilmAsSeen) =>
  <div className="film-list">
    {films
    ->Belt.Array.map(film => {
      let selected = selected == film.title
      <FilmListItem key={Belt.Int.toString(film.id) ++ "h"} film selected click=markFilmAsSeen />
    })
    ->React.array}
  </div>
