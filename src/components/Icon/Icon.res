type icon =
  | Search
  | Mail
  | Zap
  | ChevronRight

@react.component
let make = (~name: icon, ~size: int=24, ~className="") => {
  switch name {
  | Search => <ReactFeather.Search size className />
  | Mail => <ReactFeather.Mail size className />
  | Zap => <ReactFeather.Zap size className />
  | ChevronRight => <ReactFeather.ChevronRight size className />
  }
}
