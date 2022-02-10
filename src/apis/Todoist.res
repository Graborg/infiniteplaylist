let clientSecret = "93820ee048244655adc1bb55475f0297"
let clientId = "be81e104bbad4668a009dbf1ae3221c6"
let todoistProjectsUrl = "https://api.todoist.com/rest/v1/projects"
let todoistProjectUrl = "https://api.todoist.com/rest/v1/tasks?project_id="
let tasksUrl = "https://api.todoist.com/rest/v1/tasks"
let randomString = "fox0BUFvugh1kau"
let targetProjectName = "FermaandKarmisInfinitePlaylist"
let todoistLoginLink =
  "http://todoist.com/oauth/authorize?client_id=" ++
  clientId ++
  "&scope=data:read_write,data:delete&state=" ++
  randomString

/* type film = { */
/* seen: bool, */
/* id: int, */
/* name: string, */
/* creator: creator, */
/* } */

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
type payload = {
  projectId: string,
  content: string,
}

let encodePayload = (projectId: string, content: FilmType.film) => {
  open Json.Encode
  object_(list{
    ("project_id", string(projectId)),
    ("content", string(content.title)),
  }) |> Json.stringify
}

let addFilm = (film: FilmType.film) => {
  open Js.Promise
  open Fetch

  let token = LocalStorage.getToken()
  let projectId = LocalStorage.getProjectId()
  switch (token, projectId) {
  | (Some(token), Some(projectId)) => {
      let payload = encodePayload(projectId, film)
      fetchWithInit(
        tasksUrl,
        RequestInit.make(
          ~method_=Post,
          ~body=BodyInit.make(payload),
          ~headers=HeadersInit.make({
            "Content-Type": "application/json",
            "Authorization": "Bearer " ++ token,
          }),
          (),
        ),
      ) |> then_(Response.json)
    }
  | (_, _) => reject(Not_found)
  }
}

type project = {
  id: int,
  name: string,
}

let decodeProject = json => {
  open Json.Decode
  {
    id: json |> field("id", int),
    name: json |> field("name", string),
  }
}

let decodeProjects = json => {
  open Json.Decode
  json |> array(decodeProject)
}

let getProjectId = token => {
  open Js.Promise
  open Fetch
  open Belt

  todoistProjectsUrl->fetchWithInit(authorizationHeader(token))
  |> then_(Response.json)
  |> then_(res => {
    let project = res->decodeProjects->Array.getBy(p => p.name === targetProjectName)
    switch project {
    | Some(p) => p.id->Int.toString->LocalStorage.setProjectId->resolve
    | None => reject(Not_found)
    }
  })
}

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

type filmMetaData = {seen: bool}
@scope("JSON") @val
external parseIntoMyData: string => filmMetaData = "parse"

let getFilms = token => {
  open Js.Promise
  open Fetch
  open FilmType
  getProjectId(token) |> then_(id =>
    fetchWithInit(todoistProjectUrl ++ id, authorizationHeader(token))
    |> then_(Response.json)
    |> then_(res =>
      res
      ->decodeTasks
      ->Js.Array2.map(film => {
        switch film.description {
        | None => {
            id: film.id,
            title: film.content,
            creator: getUserVariant(film.creator),
            releaseDate: None,
            posterPath: None,
            plot: None,
            genres: None,
            language: None,
            seen: false,
          }

        | Some("") => {
            seen: false,
            id: film.id,
            title: film.content,
            releaseDate: None,
            posterPath: None,
            plot: None,
            genres: None,
            language: None,
            creator: getUserVariant(film.creator),
          }
        | Some(description) => {
            seen: parseIntoMyData(description).seen,
            id: film.id,
            title: film.content,
            releaseDate: None,
            posterPath: None,
            plot: None,
            genres: None,
            language: None,
            creator: getUserVariant(film.creator),
          }
        }
      }) |> resolve
    )
  )
}

let encodeTokenPayload = (~code, ~clientSecret, ~clientId) => {
  open Json.Encode
  object_(list{
    ("code", string(code)),
    ("client_secret", string(clientSecret)),
    ("client_id", string(clientId)),
  }) |> Json.stringify
}

let decodeTokenPayload = json => {
  open Json.Decode
  json |> field("access_token", string)
}

let setToken = code => {
  open Js.Promise
  open Fetch

  let payload = encodeTokenPayload(~code, ~clientSecret, ~clientId)
  fetchWithInit(
    "https://todoist.com/oauth/access_token",
    RequestInit.make(
      ~method_=Post,
      ~body=BodyInit.make(payload),
      ~headers=HeadersInit.make({"Content-Type": "application/json"}),
      (),
    ),
  )
  |> then_(Response.json)
  |> then_(res => decodeTokenPayload(res)->LocalStorage.setToken |> resolve)
}

let searchStringToCode = search =>
  search
  ->Js.String2.split("&s")
  ->Belt.Array.getBy(e => Js.String2.startsWith(e, "code="))
  ->Belt.Option.flatMap(c => c->Js.String2.split("=")->Belt.Array.get(1))
