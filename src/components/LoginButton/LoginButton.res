@val external window: 'a = "window"

let sendLoginEmail = _ => {
  open Firebase
  let acos: Firebase_Auth.actionCodeSettings = {
    url: "http://localhost:8000",
    handleCodeInApp: true,
  }
  firebase
  ->auth
  ->Auth.sendSignInLinkToEmail(~email="mgraborg@gmail.com", ~actionCodeSettings=acos)
  ->ignore
}
let wrapper = Emotion.css(`
  width: fit-content;
  align-self: center;
`)

@react.component
let make = () => <div className=wrapper> <Button onClick=sendLoginEmail text="Login" /> </div>
