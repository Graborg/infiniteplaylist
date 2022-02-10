type user =
  | Ferma
  | Karmi

type film = {
  id: int,
  title: string,
  creator: user,
  releaseDate: option<string>,
  posterPath: option<string>,
  plot: option<string>,
  language: option<string>,
  genres: option<array<string>>,
  seen: bool,
}

let getUserVariant = (userId: int) => userId === 13612164 ? Karmi : Ferma
