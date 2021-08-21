module IMDBService = {
  open Js.Promise

  let search = (
    str: string,
    setState: (((string, array<'a>, bool, int)) => (string, array<'a>, bool, int)) => unit,
  ) =>
    Fetch.fetchWithInit(
      "https://imdb8.p.rapidapi.com/auto-complete?q=" ++ str,
      Fetch.RequestInit.make(
        ~headers=Fetch.HeadersInit.make({
          "x-rapidapi-key": "2df82a1ee9msha7bfe50dac1853fp17ec3ejsn869e578089bb",
          "x-rapidapi-host": "imdb8.p.rapidapi.com",
        }),
        (),
      ),
    )
    |> then_(Fetch.Response.json)
    |> then_(res => {
      let decoded = Js.Json.decodeObject(res)

      switch decoded {
      | Some(imdbResult) => {
          let topResults =
            Js.Dict.get(imdbResult, "d")
            ->Belt.Option.getWithDefault(Js.Json.array([]))
            ->Js.Json.decodeArray
            ->Belt.Option.getWithDefault([])
            ->Js.Array2.map(film => {
              Js.Json.decodeObject(film)->Belt.Option.flatMap(filmObj => Some({
                "title": Js.Dict.get(filmObj, "l"),
                "year": Js.Dict.get(filmObj, "y"),
                "category": Js.Dict.get(filmObj, "q"),
              }))
            })
            ->Js.Array2.filter(Js.Option.isSome)
            ->Js.Array2.filter(film =>
              Belt.Option.map(film, f =>
                Belt.Option.getWithDefault(f["category"], Js.Json.string("none")) ==
                  Js.Json.string("feature")
              )->Belt.Option.getWithDefault(false)
            )
          Js.log(topResults)
          setState(((prev, _prev2, _, activeOption)) => (prev, topResults, true, activeOption))
        }
      }

      Js.Promise.resolve("")
    })
    |> ignore
}
