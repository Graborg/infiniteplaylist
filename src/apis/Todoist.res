let localStorageNamespace = "todoist-token"
let localStorageProjectIdNamespace = "todoist-project"
let clientSecret = "93820ee048244655adc1bb55475f0297"
let clientId = "be81e104bbad4668a009dbf1ae3221c6"
let todoistProjectsUrl = "https://api.todoist.com/rest/v1/projects"
let todoistProjectUrl = "https://api.todoist.com/rest/v1/tasks?project_id="
let tasksUrl = "https://api.todoist.com/rest/v1/tasks"
let randomString = "fox0BUFvugh1kau"
let todoistLoginLink =
  "http://todoist.com/oauth/authorize?client_id=" ++
  clientId ++
  "&scope=data:read_write,data:delete&state=" ++
  randomString

open Js.Promise
type creator =
  | Karmi
  | Ferma
type film = {
  seen: bool,
  id: int,
  name: string,
  creator: creator,
}
let trimQuotes = str => str->Js.String2.replace("\"", "")->Js.String2.replace("\"", "")

let setTokenLocalStorage = token => {
  Dom.Storage.setItem(localStorageNamespace, token, Dom.Storage.localStorage)
  token
}
let getTokenLocalStorage = () =>
  Dom.Storage.getItem(localStorageNamespace, Dom.Storage.localStorage)
let getProjectIdLocalStorage = () =>
  Dom.Storage.getItem(localStorageProjectIdNamespace, Dom.Storage.localStorage)
let setProjectIdLocalStorage = projectId =>
  Dom.Storage.setItem(localStorageProjectIdNamespace, projectId, Dom.Storage.localStorage)

let authorizationHeader = token =>
  Fetch.RequestInit.make(
    ~headers=Fetch.HeadersInit.make({
      "Authorization": "Bearer " ++ token,
    }),
    (),
  )

/* let setFilmAsSeen = (film: film) => { */
/* let token = getTokenLocalStorage() */
/* let payload = Js.Dict.empty() */
/* Js.Dict.set(payload, "description", Js.Json.string("completed")) */
/* switch token { */
/* | Some(token) => */
/* Fetch.fetchWithInit( */
/* tasksUrl ++ "/" ++ Belt.Float.toString(film.id), */
/* Fetch.RequestInit.make( */
/* ~method_=Post, */
/* ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))), */
/* ~headers=Fetch.HeadersInit.make({ */
/* "Content-Type": "application/json", */
/* "Authorization": "Bearer " ++ token, */
/* }), */
/* (), */
/* ), */
/* ) */
/* } */
/* } */
/* let setFilmAsUnseen = (film: film) => { */
/* let token = getTokenLocalStorage() */
/* let payload = Js.Dict.empty() */
/* Js.Dict.set(payload, "description", Js.Json.string("")) */
/* switch token { */
/* | Some(token) => */
/* Fetch.fetchWithInit( */
/* tasksUrl ++ "/" ++ Belt.Float.toString(film.id), */
/* Fetch.RequestInit.make( */
/* ~method_=Post, */
/* ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))), */
/* ~headers=Fetch.HeadersInit.make({ */
/* "Content-Type": "application/json", */
/* "Authorization": "Bearer " ++ token, */
/* }), */
/* (), */
/* ), */
/* ) */
/* } */
/* } */

let addFilm = (filmName: string) => {
  let token = getTokenLocalStorage()
  let payload = Js.Dict.empty()
  let projectId = getProjectIdLocalStorage()
  let projectIdFloat = Belt.Option.flatMap(projectId, Belt.Float.fromString)
  switch (token, projectIdFloat) {
  | (Some(token), Some(projectId)) => {
      Js.Dict.set(payload, "content", Js.Json.string(filmName))
      Js.Dict.set(payload, "project_id", Js.Json.number(projectId))
      Fetch.fetchWithInit(
        tasksUrl,
        Fetch.RequestInit.make(
          ~method_=Post,
          ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
          ~headers=Fetch.HeadersInit.make({
            "Content-Type": "application/json",
            "Authorization": "Bearer " ++ token,
          }),
          (),
        ),
      )
      |> then_(Fetch.Response.json)
      |> then_(res => {
        let decoded = Js.Json.decodeObject(res)
        switch decoded {
        | Some(film) => {
            let id =
              Js.Dict.get(film, "id")
              ->Belt.Option.getWithDefault(Js.Json.string("0"))
              ->Js.Json.decodeNumber
              ->Belt.Option.getWithDefault(1.0)
            let creator =
              Js.Dict.get(film, "creator")
              ->Belt.Option.getWithDefault(Js.Json.string(""))
              ->Js.Json.decodeNumber
              ->Belt.Option.getWithDefault(1.0)
              ->Belt.Float.toInt
            Js.Promise.resolve((creator === 13612164 ? Karmi : Ferma, id))
          }
        }
      })
    }
  }
}

let getProjectId = token =>
  Fetch.fetchWithInit(todoistProjectsUrl, authorizationHeader(token))
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

      switch projectId {
      | Some(id) =>
        switch id {
        | Some(projectId) => {
            let idStringyfied = Js.Json.stringify(projectId)
            setProjectIdLocalStorage(idStringyfied)
            Js.Promise.resolve(idStringyfied)
          }

        | None => {
            Js.log("Project ID not found")
            Js.Promise.resolve("")
          }
        }
      }
    }
  })

type description = {seen: bool}

type task = {
  id: int,
  assigner: int,
  content: string,
  description: option<string>,
  creator: int,
  created: string,
}

type tasks = {items: array<task>}

let decodeTask = json => {
  open Json.Decode
  {
    id: json |> field("id", int),
    assigner: json |> field("assigner", int),
    content: json |> field("content", string),
    description: json |> optional(field("description", string)),
    creator: json |> field("creator", int),
    created: json |> field("created", string),
  }
}

let decodeTasks = json => {
  open Json.Decode
  json |> array(decodeTask)
}

type data = {seen: bool}
@scope("JSON") @val
external parseIntoMyData: string => data = "parse"

let getCreator = (userId: int) => userId === 13612164 ? Karmi : Ferma
let getFilms = token =>
  getProjectId(token) |> then_(id =>
    Fetch.fetchWithInit(todoistProjectUrl ++ id, authorizationHeader(token))
    |> then_(Fetch.Response.json)
    |> then_(res =>
      res
      ->decodeTasks
      ->Js.Array2.map(film => {
        switch film.description {
        | None => {
            seen: false,
            id: film.id,
            name: film.content,
            creator: getCreator(film.creator),
          }
        | Some("") => {
            seen: false,
            id: film.id,
            name: film.content,
            creator: getCreator(film.creator),
          }
        | Some(description) => {
            seen: parseIntoMyData(description).seen,
            id: film.id,
            name: film.content,
            creator: getCreator(film.creator),
          }
        }
      }) |> Js.Promise.resolve
    )
  )

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
