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
let creatorToString = creator => {
  open FilmType

  switch creator {
  | Some(Karmi) => j`🐘 ` ++ "Karmi!" ++ j` 🐘`
  | Some(Ferma) => j`🐄 ` ++ "Ferma!" ++ j` 🐄`
  | None => ""
  }
}

let getCreatorColor = creator => {
  open FilmType
  switch creator {
  | Some(Ferma) => "#476098"
  | Some(Karmi) => "#8b9862"
  | None => ""
  }
}
let electFilm = (~setState, ~doSelectFilm, ~nextElector, ~films: array<FilmType.film>=[], ()) => {
  confetti()->ignore
  horn()->ignore

  switch (doSelectFilm, nextElector) {
  | (Some(selectFilmFunc), Some(elector)) =>
    {
      let filmsOfCreator =
        films->Js.Array2.filter((film: FilmType.film) => film.creator === elector)
      let randomIndex = filmsOfCreator->Belt.Array.length->Random.int
      Belt.Array.get(filmsOfCreator, randomIndex)->Belt.Option.map(film => {
        selectFilmFunc(film.title)
        setState(_prevState => FilmElected(film.title))
      })
    }->ignore
  | (Some(_), None) => Js.log("no function passed to RandomBtn")
  | (None, _) => Js.log("Something went wrong when electing next film in randomBtn")
  }
  ()
}

@react.component
let make = (~films=[], ~doSelectFilm=?, ~nextElector: option<FilmType.user>=?, ~disabled=false) => {
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
        ~color={getCreatorColor(nextElector)},
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
        disabled
        style={ReactDOMStyle.make(
          ~boxShadow="0 0 0 1px" ++ getCreatorColor(nextElector),
          ~color={getCreatorColor(nextElector)},
          (),
        )}
        onClick={_event => electFilm(~setState, ~doSelectFilm, ~nextElector, ~films, ())}>
        {React.string("Haz un volado")}
      </button>
    </div>
  </div>
}
