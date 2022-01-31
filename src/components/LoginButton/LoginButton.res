@val external window: 'a = "window"

let redirectToTodoist = _ => window["location"]["href"] = Todoist.todoistLoginLink

let wrapper = Emotion.css(`
  width: fit-content;
  align-self: center;
`)

@react.component
let make = () => <div className=wrapper> <Button onClick=redirectToTodoist text="Login" /> </div>
