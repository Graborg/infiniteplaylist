let wrapper = Emotion.css(`
  width: fit-content;
  align-self: center;
`)

@react.component
let make = (~clickHandler) =>
  <div className=wrapper> <Button onClick=clickHandler text="Login" /> </div>
