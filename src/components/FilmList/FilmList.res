let wrapper = Emotion.css(`
  @keyframes fadeUp {
    from {
      transform: translateY(25%);
      filter: opacity(0);
    }
    to {
      transform: translateY(0);
      filter: opacity(1);
    }
  }
  will-change: transform;
  animation: fadeUp 700ms 900ms cubic-bezier(.26,.68,.44,1.01) both;
`)

let listClass = showList =>
  Emotion.css(
    `
  display: ${showList ? "grid" : "none"};
  margin-top: 10px;
  --min-column-width: min(170px, 100%);
  gap: 16px;
  grid-template-columns:
    repeat(auto-fill, minmax(var(--min-column-width), 1fr));
`,
  )

let listTitle = Emotion.css(`
  font-size: calc(20rem/16);
  width: fit-content;
  padding-bottom: 4px;
  padding-top: 24px;
  border-bottom: 1px solid var(--color-black);
`)
@react.component
let make = (
  ~header: string,
  ~films: array<FilmType.film>,
  ~isOpen: bool,
  ~selected=?,
  ~onItemSelect,
  (),
) =>
  <div className=wrapper>
    <h3 className=listTitle> {React.string(header)} </h3>
    <ul className={listClass(isOpen)}>
      {films
      ->Belt.Array.map(film => {
        let isSelected = Belt.Option.eq(selected, Some(film.title), (a, b) => a === b)
        <FilmListItem key={Belt.Int.toString(film.id)} film isSelected click=onItemSelect />
      })
      ->React.array}
    </ul>
  </div>
