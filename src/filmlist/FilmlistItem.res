open Todoist

type mouseOver =
  | MouseIsOver
  | MouseNotOver

let creatorToString = (creator: Todoist.creator) =>
  switch creator {
  | Karmi => "karmi"
  | Ferma => "Ferma"
  }

@react.component
let make = (~film: Todoist.film, ~id, ~lastElement: bool, ~selected: bool) => {
  let (isMouseOver, setMouseOver) = React.useState(_ => false)
  let (isChecked, setCheck) = React.useState(_ => false)

  {
    isMouseOver || isChecked
      ? <div
          key={Belt.Int.toString(id)}
          onMouseEnter={_ => setMouseOver(_ => true)}
          onMouseLeave={_ => setMouseOver(_ => false)}
          className="film-item inputGroup"
          style={ReactDOMStyle.make(~padding="0", ~margin="0 10px", ())}>
          <input
            checked=isChecked
            onChange={_ => {
              Js.log("Hej")
              setCheck(prev => !prev)
            }}
            id={Belt.Int.toString(id) ++ "input"}
            type_="checkbox"
          />
          <label
            style={ReactDOMStyle.make(
              ~display="flex",
              ~padding="21px 0 13px",
              ~paddingLeft="20px",
              ~justifyContent="space-between",
              ~boxSizing="border-box",
              ~minHeight="56px",
              ~borderBottom=lastElement ? "" : "1px #cecece solid",
              ~backgroundColor="white",
              (),
            )}
            htmlFor={Belt.Int.toString(id) ++ "input"}>
            {React.string(film.name)}
          </label>
        </div>
      : <div
          key={Belt.Int.toString(id)}
          onMouseEnter={_ => setMouseOver(_ => true)}
          onMouseLeave={_ => setMouseOver(_ => false)}
          className="film-item inputGroup"
          style={ReactDOMStyle.make(
            ~display="flex",
            // ~padding="21px 0 13px",
            ~padding="21px 5px 13px",
            ~margin="0 10px",
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
}
