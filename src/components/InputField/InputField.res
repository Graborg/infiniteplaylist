open Emotion

let iconNameToLabelPadding: ReactFeather.name => string = iconName => {
  switch iconName {
  | #Search => "8"
  | #Mail => "6"
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
  ~placeholder: string,
  ~labelName: string,
  ~onChangeHandler,
  ~onFocusHandler,
  ~disabled: bool=false,
  ~borderRadiusBottom: bool=true,
  ~icon: ReactFeather.name,
  (),
) => {
  let (text, setText) = React.useState(_ => "")

  let onChange = e => {
    let currentText = ReactEvent.Form.target(e)["value"]
    setText(currentText)
    onChangeHandler(currentText)
  }

  <div className={wrapper(borderRadiusBottom)}>
    <label htmlFor=id className={label(icon)}> {React.string(labelName)} </label>
    <input
      type_="email"
      className=inputField
      disabled
      placeholder
      value={text}
      onChange
      onFocus=onFocusHandler
    />
    <Icon name=icon className=iconClass />
  </div>
}
