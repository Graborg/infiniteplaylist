open Todoist

type state =
  | LoadingElection
  | NoElection
  | FilmElected(string)

let confetti = %raw(`
    function () {
        window.confetti({
        angle: 125,
        particleCount: 100,
        spread: 70,
        origin: {x:0.7}
        });
    }
`)

let electFilm = (setState, films: array<Todoist.film>, selectFilm) => {
  let _h = confetti()
  let r = Random.int(Belt.Array.length(films))
  switch Belt.Array.get(films, r) {
  | Some(film) =>
    selectFilm(film.name)
    setState(_prevState => FilmElected(film.name))
  | None => ()
  }
  ()
}

@react.component
let make = (~films, ~selectFilmWithSetState) => {
  let (state, setState) = React.useState(() => NoElection)

  <div
    style={ReactDOMStyle.make(
      ~display="flex",
      ~flexDirection="row",
      ~margin="0 2px 0 15px",
      ~justifyContent="space-between",
      ~alignItems="baseline",
      (),
    )}>
    {switch state {
    | LoadingElection => <p />
    | NoElection => <p />
    | FilmElected(film) => <h2 className="gradient-text"> {React.string(film)} </h2>
    }}
    <button onClick={_event => electFilm(setState, films, selectFilmWithSetState)}>
      {React.string("Hace un volado")}
    </button>
  </div>
}
