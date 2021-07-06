let localStorageNamespace = "todoist-token"
let clientSecret = "93820ee048244655adc1bb55475f0297"
let clientId = "be81e104bbad4668a009dbf1ae3221c6"
let todoistProjectsUrl = "https://api.todoist.com/rest/v1/projects"
let todoistProjectUrl = "https://api.todoist.com/rest/v1/tasks?project_id="
let randomString = "fox0BUFvugh1kau"
let todoistLoginLink =
  "http://todoist.com/oauth/authorize?client_id=" ++
  clientId ++
  "&scope=data:read,data:delete&state=" ++
  randomString

module Todoist = {
  open Js.Promise
  type creator =
    | Karmi
    | Ferma
  type film = {
    name: string,
    creator: creator,
  }
  let trimQuotes = str => str->Js.String2.replace("\"", "")->Js.String2.replace("\"", "")

  let getProjectId = token =>
    Fetch.fetchWithInit(
      todoistProjectsUrl,
      Fetch.RequestInit.make(
        ~headers=Fetch.HeadersInit.make({"Authorization": "Bearer " ++ token}),
        (),
      ),
    )
    |> then_(Fetch.Response.json)
    |> then_(res => {
      let decoded = Js.Json.decodeArray(res)
      switch decoded {
      | Some(list) =>
        let projectId =
          Belt.Array.map(list, e => Js.Json.decodeObject(e))
          ->Belt.Array.keep(e =>
            Js.Dict.get(
              Belt.Option.getWithDefault(e, Js.Dict.empty()),
              "name",
            )->Belt.Option.getWithDefault(Js.Json.string("")) ===
              Js.Json.string("FermaandKarmisInfinitePlaylist")
          )
          ->Belt.Array.map(e => Js.Dict.get(Belt.Option.getWithDefault(e, Js.Dict.empty()), "id"))
          ->Belt.Array.get(0)

        Js.log(projectId)
        switch projectId {
        | Some(id) =>
          Js.log(id)
          Js.Promise.resolve(Belt.Option.getWithDefault(id, Js.Json.string(""))->Js.Json.stringify)
        }
      }
    })

  let getFilms = token => {
    getProjectId(token) |> then_(id =>
      Fetch.fetchWithInit(
        todoistProjectUrl ++ id,
        Fetch.RequestInit.make(
          ~headers=Fetch.HeadersInit.make({
            "Authorization": "Bearer " ++ token,
          }),
          (),
        ),
      )
      |> then_(Fetch.Response.json)
      |> then_(res => {
        let decoded = Js.Json.decodeArray(res)
        switch decoded {
        | Some(films) =>
          let h = Belt.Array.map(films, e => Js.Json.decodeObject(e))->Belt.Array.map(film =>
            switch film {
            | Some(existingItem) =>
              let filmName =
                Js.Dict.get(existingItem, "content")
                ->Belt.Option.getWithDefault(Js.Json.string(""))
                ->Js.Json.decodeString
                ->Belt.Option.getWithDefault("")
                ->trimQuotes

              let creator =
                Js.Dict.get(existingItem, "creator")
                ->Belt.Option.getWithDefault(Js.Json.string(""))
                ->Js.Json.decodeNumber
                ->Belt.Option.getWithDefault(1.0)
                ->Belt.Float.toInt
              {
                name: filmName,
                creator: creator === 13612164 ? Karmi : Ferma,
              }
            }
          )
          Js.Promise.resolve(h)
        | None => Js.Promise.resolve([])
        }
      })
    )
  }

  let setTokenLocalStorage = token => {
    Dom.Storage.setItem(localStorageNamespace, token, Dom.Storage.localStorage)
    token
  }

  let setToken = code => {
    switch code {
    | Some(code) =>
      let payload = Js.Dict.empty()
      Js.Dict.set(payload, "code", Js.Json.string(code))
      Js.Dict.set(payload, "client_secret", Js.Json.string(clientSecret))
      Js.Dict.set(payload, "client_id", Js.Json.string(clientId))

      Fetch.fetchWithInit(
        "https://todoist.com/oauth/access_token",
        Fetch.RequestInit.make(
          ~method_=Post,
          ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
          ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
          (),
        ),
      )
      |> then_(Fetch.Response.json)
      |> then_(jsonResponse => {
        let decoded = Js.Json.decodeObject(jsonResponse)
        let maybeToken = switch decoded {
        | Some(payload) => Js.Dict.get(payload, "access_token")
        | None => None
        }

        switch maybeToken {
        | Some(token) =>
          let tokenWithoutQuotes = token->Js.Json.stringify->trimQuotes->setTokenLocalStorage
          Js.Promise.resolve(tokenWithoutQuotes)
        | None => Js.Promise.reject(Not_found)
        }
      })
    | None => Js.Promise.reject(Not_found)
    }
  }

  let searchStringToCode = search => {
    let code =
      search->Js.String2.split("&s")->Belt.Array.getBy(e => Js.String2.startsWith(e, "code="))
    switch code {
    | Some(v) => Some(Js.String2.split(v, "=")[1])
    | None => None
    }
  }
}
