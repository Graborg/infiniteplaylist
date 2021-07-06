open Todoist

let creatorToString = (creator: Todoist.creator) =>
  switch creator {
  | Karmi => "karmi"
  | Ferma => "Ferma"
  }

@react.component
let make = (~film: Todoist.film, ~id, ~lastElement: bool, ~selected: bool) => {
  <div
    key={Belt.Int.toString(id)}
    style={ReactDOMStyle.make(
      ~display="flex",
      ~padding="21px 5px 13px",
      ~margin="0 10px",
      ~paddingLeft=selected ? "20px" : "10px",
      ~borderBottom=lastElement ? "" : "1px #cecece solid",
      ~justifyContent="space-between",
      ~boxSizing="border-box",
      ~minHeight="56px",
      (),
    )}>
    <p>
      {selected ? React.string(j`🤠` ++ " ") : React.string("")}
      {React.string(film.name)}
      {selected ? React.string(" " ++ j`🤠`) : React.string("")}
    </p>
    <p style={ReactDOMStyle.make(~border="black 5px", ())}>
      {React.string(creatorToString(film.creator))}
    </p>
  </div>
}
