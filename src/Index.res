%%raw("import './styles/main.scss'")

let _ = {
  open Firebase.Auth
  require
}
let _ = {
  open Firebase.Firestore
  require
}

ReactDOM.render(
  <React.StrictMode> <App /> </React.StrictMode>,
  ReactDOM.querySelector("#root")->Belt.Option.getExn,
)
