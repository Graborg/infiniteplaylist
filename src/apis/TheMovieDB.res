let api_key = "6457e32b10837b9f9a7bbdf1e6aa0aa0"
let base_uri = "https://api.themoviedb.org/3/"
let poster_uri = "https://www.themoviedb.org/t/p/original/"

type filmResult = {
  "title": option<Js.String2.t>,
  "year": option<Js.String2.t>,
  "poster_path": option<Js.String2.t>,
  "plot": option<string>,
  "id": option<string>,
  "genres": option<array<Js.String2.t>>,
}

type results =
  | NoResultsInit
  | NoResultsFound
  | Results(array<filmResult>)
let trimQuotes = str => str->Js.String2.replace("\"", "")->Js.String2.replace("\"", "")
module TheMovieDBAdapter = {
  open Js.Promise

  let search = (str: string, callback: results => unit) =>
    Fetch.fetch(base_uri ++ "search/movie?api_key=" ++ api_key ++ "&query=" ++ str)
    |> then_(Fetch.Response.json)
    |> then_(res => {
      let decodedOptionArray =
        res
        ->Js.Json.decodeObject
        ->Belt.Option.flatMap(results =>
          Js.Dict.get(results, "results")->Belt.Option.flatMap(Js.Json.decodeArray)
        )
      switch decodedOptionArray {
      | None => resolve()
      | Some([]) => {
          callback(NoResultsFound)
          resolve()
        }
      | Some(decodedArray) =>
        decodedArray
        ->Js.Array2.map(Js.Json.decodeObject)
        ->Js.Array2.map(decodedObject =>
          Belt.Option.map(decodedObject, filmObj =>
            {
              "title": Js.Dict.get(filmObj, "title")
              ->Belt.Option.map(Js.Json.stringify)
              ->Belt.Option.map(trimQuotes),
              "year": Js.Dict.get(filmObj, "release_date")
              ->Belt.Option.map(Js.Json.stringify)
              ->Belt.Option.map(trimQuotes)
              ->Belt.Option.flatMap(date => Js.String2.split(date, "-")->Belt.Array.get(0)),
              "genres": Js.Dict.get(filmObj, "genre_ids")
              ->Belt.Option.flatMap(Js.Json.decodeArray)
              ->Belt.Option.map(genres =>
                Js.Array2.map(genres, g =>
                  Belt.Map.String.getWithDefault(TheMovieDBGenres.genres, Js.Json.stringify(g), "")
                )
              ),
              "id": Js.Dict.get(filmObj, "id")
              ->Belt.Option.map(Js.Json.stringify)
              ->Belt.Option.map(trimQuotes),
              "plot": Js.Dict.get(filmObj, "overview")
              ->Belt.Option.map(Js.Json.stringify)
              ->Belt.Option.map(trimQuotes),
              "poster_path": Js.Dict.get(filmObj, "poster_path")
              ->Belt.Option.map(Js.Json.stringify)
              ->Belt.Option.map(trimQuotes),
            }
          )
        )
        ->Js.Array2.filter(Belt.Option.isSome)
        ->Js.Array2.map(Belt.Option.getExn)
        ->Results
        ->callback
        ->resolve
      }
    })
}
