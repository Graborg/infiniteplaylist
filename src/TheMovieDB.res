let api_key = "6457e32b10837b9f9a7bbdf1e6aa0aa0"
let base_uri = "https://api.themoviedb.org/3/"
let timeout = 5000

let trimQuotes = str => str->Js.String2.replace("\"", "")->Js.String2.replace("\"", "")
module TheMovieDBAdapter = {
  open Js.Promise

  let search = (str: string, callback: array<'a> => unit) =>
    Fetch.fetch(base_uri ++ "search/movie?api_key=" ++ api_key ++ "&query=" ++ str)
    |> then_(Fetch.Response.json)
    |> then_(res =>
      switch Js.Json.decodeObject(res) {
      | None => None
      | Some(results) =>
        Js.Dict.get(results, "results")
        ->Belt.Option.flatMap(Js.Json.decodeArray)
        ->Belt.Option.map(resArray =>
          Js.Array2.map(resArray, film =>
            Js.Json.decodeObject(film)->Belt.Option.map(filmObj =>
              {
                "title": Js.Dict.get(filmObj, "title")
                ->Belt.Option.map(Js.Json.stringify)
                ->Belt.Option.map(trimQuotes),
                "year": Js.Dict.get(filmObj, "release_date")
                ->Belt.Option.map(e => e->Js.Json.stringify)
                ->Belt.Option.map(e => e->trimQuotes),
                "category": Js.Dict.get(filmObj, "title"),
              }
            )
          )
        )
        ->Belt.Option.map(mappedArray =>
          Js.Array2.filter(mappedArray, Belt.Option.isSome)->Js.Array2.map(Belt.Option.getExn)
        )
        ->Belt.Option.map(res => callback(res))
      } |> resolve
    )
}
