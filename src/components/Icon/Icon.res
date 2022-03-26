type icon =
  | Search
  | Mail
  | Zap

@react.component
let make = (~name: icon, ~size: int=24, ~className="") => {
  switch name {
  | Search => <ReactFeather.Search className />
  | Mail => <ReactFeather.Mail className />
  | Zap => <ReactFeather.Zap className />
  }
  /* ReactFeather.make({ */
  /* "className": Some(className), */
  /* "color": Some("var(--color-primary)"), */
  /* "size": Some(size), */
  /* "name": name, */
  /* }) */
}
