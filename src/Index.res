%%raw("import './styles/main.scss'")

open Firebase
let conf: firebaseConfig = {
  apiKey: "AIzaSyCTc74dSk1h1ImyBHcYyHx4X0E2kJloe9I",
  authDomain: "fermaandkarmisinfiniteplaylist.firebaseapp.com",
  projectId: "fermaandkarmisinfiniteplaylist",
  storageBucket: "fermaandkarmisinfiniteplaylist.appspot.com",
  messagingSenderId: "491628845187",
  appId: "1:491628845187:web:4067c45aee702242bfa3b6",
}
firebase->initializeApp(conf)
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
