type film = {
  id: int,
  title: string,
  creatorName: string,
  creatorIsCurrentUser: bool,
  creatorId: string,
  releaseDate: option<string>,
  posterPath: option<string>,
  plot: option<string>,
  language: option<string>,
  genres: option<array<string>>,
  seen: bool,
}
let creatorToString = creator =>
  switch creator {
  | "Karmi" => j`🐘 ` ++ "Karmi!" ++ j` 🐘`
  | "Ferma" => j`🐄 ` ++ "Ferma!" ++ j` 🐄`
  | _ => creator
  }
