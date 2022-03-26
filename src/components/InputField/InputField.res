open Emotion

let iconNameToLabelPadding: Icon.icon => string = iconName => {
  switch iconName {
  | Search => "8"
  | Mail => "6"
  | _ => "6"
  }
}

let label = iconName =>
  css(
    `
  position: absolute;
  top: -12px;
  left: ${iconNameToLabelPadding(iconName)}px;
  padding-right: 5px;
  background-color: var(--color-background);
  color: var(--color-primary);
  font-weight: 700;
  font-size: 1.2rem;
`,
  )

let inputField = css(`
  background-color: transparent;
  width: 100%;
  padding: 10px;
  border: 0;
  font-family: var(--font-bread);
  padding-left: 34px;
`)
let wrapper = (borderRadiusBottom: bool) =>
  css(
    `
  position: relative;
  border: 1px solid var(--color-primary);
  border-radius: ${borderRadiusBottom ? "4px" : "4px 4px 0 0"};
`,
  )
let iconClass = css(`
  position: absolute;
  left: 5px;
  top: 7px;
  color: var(--color-primary);
`)

@react.component
let make = (
  ~id: string,
  ~value,
  ~placeholder: string,
  ~labelName: string,
  ~onChange,
  ~onFocus=?,
  ~disabled: bool=false,
  ~borderRadiusBottom: bool=true,
  ~icon: Icon.icon,
  ~inputRef: option<ReactDOM.domRef>=?,
  (),
) => {
  <div className={wrapper(borderRadiusBottom)}>
    <label htmlFor=id className={label(icon)}> {React.string(labelName)} </label>
    <input className=inputField disabled placeholder value onChange ?onFocus ref=?inputRef />
    <Icon name=icon className=iconClass />
  </div>
}
