open Todoist

type mouseOver =
  | MouseIsOver
  | MouseNotOver

let creatorToString = (creator: Todoist.creator) =>
  switch creator {
  | Karmi => j`🐘 ` ++ "Karmi" ++ j` 🐘`
  | Ferma => j`🐄 ` ++ "Ferma" ++ j` 🐄`
  }

@react.component
let make = (
  ~film: Todoist.film,
  ~lastElement: bool,
  ~selected: bool,
  ~click: Todoist.film => unit,
) => {
  let (checked, setCheck) = React.useState(_ => false)

  {
    <div
      key={Belt.Float.toString(film.id)}
      className="film-item inputGroup"
      onClick={_ => {
        setCheck(prevState => !prevState)
        click(film)
      }}
      style={ReactDOMStyle.make(
        ~display="flex",
        // ~padding="21px 0 13px",
        ~padding="21px 5px 13px",
        ~margin="0 10px",
        ~borderBottom=lastElement ? "" : "1px #cecece solid",
        ~justifyContent="space-between",
        ~boxSizing="border-box",
        ~minHeight="56px",
        ~textDecoration=checked ? "line-through" : "",
        ~color={film.creator === Ferma ? "#476098" : "#8b9862"},
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
}
