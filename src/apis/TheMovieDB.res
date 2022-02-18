@val @scope(("process", "env")) external api_key: string = "THE_MOVIE_DB_API_KEY"

let api_key = api_key
let base_uri = "https://api.themoviedb.org/3/"
let poster_uri = "https://www.themoviedb.org/t/p/original/"

type searchResult = {
  id: int,
  title: string,
  releaseDate: option<string>,
  posterPath: option<string>,
  plot: option<string>,
  language: option<string>,
  genres: option<array<string>>,
}

type decodedResult = {
  id: int,
  title: string,
  release_date: option<string>,
  poster_path: option<string>,
  overview: option<string>,
  genre_ids: option<array<int>>,
  original_language: option<string>,
}

type results =
  | NoResultsInit
  | NoResultsFound
  | Results(array<searchResult>)

let decodeSearchResult = json => {
  open Json.Decode
  {
    id: json |> field("id", int),
    title: json |> field("title", string),
    release_date: json |> field("release_date", optional(string)),
    poster_path: json |> field("poster_path", optional(string)),
    overview: json |> field("overview", optional(string)),
    original_language: json |> field("original_language", optional(string)),
    genre_ids: json |> field("genre_ids", optional(array(int))),
  }
}

let decodeSearchResults = json =>
  json |> Json.Decode.field("results", Json.Decode.array(decodeSearchResult))

module TheMovieDBAdapter = {
  open Promise
  open Belt

  let search = (str: string, callback: results => unit) =>
    Fetch.fetch(base_uri ++ "search/movie?api_key=" ++ api_key ++ "&query=" ++ str)
    ->then(Fetch.Response.json)
    ->then(res =>
      res
      ->decodeSearchResults
      ->Belt.Array.map((decodedFilm): searchResult => {
        id: decodedFilm.id,
        title: decodedFilm.title,
        releaseDate: decodedFilm.release_date,
        posterPath: decodedFilm.poster_path,
        plot: decodedFilm.overview,
        language: decodedFilm.original_language,
        genres: decodedFilm.genre_ids->Option.map(genreIds =>
          Array.map(genreIds, genreId =>
            Map.String.getWithDefault(TheMovieDBGenres.genres, Int.toString(genreId), "")
          )
        ),
      })
      ->Results
      ->callback
      ->resolve
    )
}
