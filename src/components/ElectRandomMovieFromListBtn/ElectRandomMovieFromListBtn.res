type state =
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

let electFilm = (~setState, ~doSelectFilm, ~nextElectorId, ~films: array<FilmType.film>=[], ()) => {
  confetti()->ignore
  horn()->ignore

  switch doSelectFilm {
  | Some(selectFilmFunc) =>
    {
      let filmsOfCreator =
        films->Js.Array2.filter((film: FilmType.film) => film.creatorId === nextElectorId)
      let randomIndex = filmsOfCreator->Belt.Array.length->Random.int
      Belt.Array.get(filmsOfCreator, randomIndex)->Belt.Option.map(film => {
        selectFilmFunc(film.title)
        setState(_prevState => FilmElected(film.title))
      })
    }->ignore
  | None => Js.log("Something went wrong when electing next film in randomBtn")
  }
  ()
}

@react.component
let make = (~films=[], ~doSelectFilm=?, ~nextElectorId: string, ~disabled=false) => {
  let (state, setState) = React.useState(() => NoElection)
  <div>
    {switch state {
    | NoElection => React.string("")
    | FilmElected(film) => <h2 className="gradient-text result"> {React.string(film)} </h2>
    }}
    <p
      style={ReactDOMStyle.make(
        ~marginBottom="5px",
        ~textAlign="center",
        //~color={getCreatorColor(nextElector)},
        (),
      )}>
      {React.string(FilmType.creatorToString(nextElectorId))}
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
        disabled
        onClick={_event => electFilm(~setState, ~doSelectFilm, ~nextElectorId, ~films, ())}>
        {React.string("Haz un volado")}
      </button>
    </div>
  </div>
}
