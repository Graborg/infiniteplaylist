let tokenNamespace = "todoist-token"
let projectNamespace = "todoist-project"

open Dom.Storage

let setToken = token => {
  setItem(tokenNamespace, token, localStorage)
  token
}

let getToken = () => getItem(tokenNamespace, localStorage)

let getProjectId = () => getItem(projectNamespace, localStorage)

let setProjectId = projectId => {
  setItem(projectNamespace, projectId, localStorage)
  projectId
}
