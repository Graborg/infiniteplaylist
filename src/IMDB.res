module IMDBService = {
  open Js.Promise

  let search = (
    str: string,
    setState: (((string, array<'a>, bool)) => (string, array<'a>, bool)) => unit,
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
            ->Js.Array2.map(film =>
              Js.Json.decodeObject(film)->Belt.Option.flatMap(filmObj => Js.Dict.get(filmObj, "l"))
            )
            ->Js.Array2.filter(Js.Option.isSome)
          setState(((prev, _prev2, _)) => (prev, topResults, true))
        }
      }

      Js.Promise.resolve("")
    })
    |> ignore
}
