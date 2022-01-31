let btn = Emotion.css(`
  background-color: var(--color-primary);
  color: var(--color-background);
  margin:0;
  border: 0;
  border-radius: 2px;
  padding: 10px 15px;
  text-align: center;
  font-size: 1.5rem;
  font-family: var(--font-fancy);
  font-weight: 700;

`)

@react.component
let make = (~text: string, ~onClick: ReactEvent.Mouse.t => unit) =>
  <button className={btn} onClick={onClick}> {React.string(text)} </button>
