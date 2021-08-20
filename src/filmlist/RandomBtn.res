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

let horn = %raw(`
    function () {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      const audioCtx = new AudioContext();
      const audioElement = document.querySelector('audio');
      const track = audioCtx.createMediaElementSource(audioElement);
      const playButton = document.querySelector('.tape-controls-play');
      if (audioCtx.state === 'suspended') {
          audioCtx.resume();
      }
      const gainNode = audioCtx.createGain();

      const volumeControl = document.querySelector('[data-action="volume"]');
      // connect our graph
      track.connect(gainNode).connect(audioCtx.destination);
      audioElement.play();
    }
`)
let creatorToString = (creator: Todoist.creator) =>
  switch creator {
  | Karmi => j`🐘 ` ++ "Karmi!" ++ j` 🐘`
  | Ferma => j`🐄 ` ++ "Ferma!" ++ j` 🐄`
  }

let electFilm = (
  setState,
  films: array<Todoist.film>,
  selectFilm,
  nextElector: Todoist.creator,
) => {
  let _h = confetti()
  let _l = horn()
  let filmsOfCreator = films->Js.Array2.filter((film: Todoist.film) => film.creator === nextElector)
  let randomIndex = filmsOfCreator->Belt.Array.length->Random.int
  switch Belt.Array.get(filmsOfCreator, randomIndex) {
  | Some(film) =>
    selectFilm(film.name)
    setState(_prevState => FilmElected(film.name))
  | None => ()
  }
  ()
}

@react.component
let make = (~films, ~doSelectFilm, ~nextElector: Todoist.creator) => {
  let (state, setState) = React.useState(() => NoElection)
  <div>
    {switch state {
    | LoadingElection => React.string("")
    | NoElection => React.string("")
    | FilmElected(film) => <h2 className="gradient-text result"> {React.string(film)} </h2>
    }}
    <p
      style={ReactDOMStyle.make(
        ~marginBottom="5px",
        ~textAlign="center",
        ~color={nextElector === Ferma ? "#476098" : "#8b9862"},
        (),
      )}>
      {React.string(creatorToString(nextElector))}
    </p>
    <div
      style={ReactDOMStyle.make(
        ~display="flex",
        ~flexDirection="row",
        ~justifyContent="space-between",
        ~alignItems="baseline",
        (),
      )}>
      <button
        style={ReactDOMStyle.make(
          ~boxShadow="0 0 0 1px" ++ {nextElector === Ferma ? "#476098" : "#8b9862"},
          ~color={nextElector === Ferma ? "#476098" : "#8b9862"},
          (),
        )}
        onClick={_event => electFilm(setState, films, doSelectFilm, nextElector)}>
        {React.string("Hace un volado")}
      </button>
    </div>
  </div>
}
