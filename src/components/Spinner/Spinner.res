let wrapper = Emotion.css(`
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  gap: 30%;
`)
let spinner = Emotion.css(`
  align-self: center;
`)

@react.component
let make = () =>
  <div className=wrapper>
    <p className=spinner style={ReactDOMStyle.make(~fontSize="100px", ())}>
      {React.string(`🐄`)}
    </p>
  </div>
