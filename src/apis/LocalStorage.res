let tokenNamespace = "firebase-token"
let projectNamespace = "todoist-project"

open Dom.Storage

let setToken: string => string = token => {
  setItem(tokenNamespace, token, localStorage)
  token
}

let getToken: unit => option<string> = () => getItem(tokenNamespace, localStorage)
