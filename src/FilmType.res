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

let getUserVariant = (userId: string) => userId === "zRruowROmFRMBIxbOQ9OGbGQJHF3" ? Karmi : Ferma
let getUserId = (user: user) =>
  switch user {
  | Karmi => "zRruowROmFRMBIxbOQ9OGbGQJHF3"
  | Ferma => ""
  }