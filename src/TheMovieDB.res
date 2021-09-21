let api_key = "6457e32b10837b9f9a7bbdf1e6aa0aa0"
let base_uri = "https://api.themoviedb.org/3/"
let timeout = 5000
module TheMovieDBAdapter = {
  open Js.Promise

  let search = (str: string, callback: array<'a> => unit) =>
    Fetch.fetch(base_uri ++ "search/movie?api_key=" ++ api_key ++ "&query=" ++ str)
    |> then_(Fetch.Response.json)
    |> then_(res => {
      let decoded = Js.Json.decodeObject(res)
      switch decoded {
      | Some(imdbResult) => {
          let topResults =
            Js.Dict.get(imdbResult, "results")
            ->Belt.Option.getWithDefault(Js.Json.array([]))
            ->Js.Json.decodeArray
            ->Belt.Option.getWithDefault([])
            ->Js.Array2.map(film =>
              Js.Json.decodeObject(film)->Belt.Option.flatMap(filmObj => Some({
                "title": Js.Dict.get(filmObj, "title"),
                "year": Js.Dict.get(filmObj, "release_date"),
                "category": Js.Dict.get(filmObj, "title"),
              }))
            )
            ->Js.Array2.filter(Js.Option.isSome)
          callback(topResults)
        }
      }

      Js.Promise.resolve("")
    })
    |> ignore
}
