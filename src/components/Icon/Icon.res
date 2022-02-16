@react.component
let make = (~name: ReactFeather.name, ~size: int=24, ~className="") =>
  ReactFeather.make({
    "className": Some(className),
    "color": Some("var(--color-primary)"),
    "size": Some(size),
    "name": name,
  })
