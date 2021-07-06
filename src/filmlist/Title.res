@react.component
let make = () => {
  <div style={ReactDOMStyle.make(~margin="10px", ())}>
    <h2 className="gradient-text"> {React.string("Ferma and Karmi's infinite playlist")} </h2>
  </div>
}
