let wrapper = Emotion.css(`
  padding-top: 24px;
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
  border-bottom: 1px solid var(--color-black);
  animation: fadeIn 2200ms both;  
`)

let titleWrapper = Emotion.css(`
  display: flex;
  align-items: center;
  gap: 4px;
  padding-bottom: 4px;
`)

let expandList = isOpen =>
  Emotion.css(
    `
  border: 0;
  background: transparent;
  transform: rotate(${isOpen ? "90" : "0"}deg);
  transition: transform 200ms;
  display: inline-block;
  padding: 0;
`,
  )

let chevronIcon = Emotion.css(`
    vertical-align: middle;
    transform: translateY(2px);
  `)

@react.component
let make = (
  ~header: string,
  ~films: array<FilmType.film>,
  ~selected=?,
  ~onItemSelect,
  ~initAsOpen=true,
  (),
) => {
  let (isOpen, toggle) = React.useState(() => true)
  React.useEffect0(() => {
    toggle(_ => initAsOpen)
    None
  })

  <div className=wrapper>
    <div className=titleWrapper>
      <h3 className=listTitle> {React.string(header)} </h3>
      <button onClick={_ => toggle(prev => !prev)} className={expandList(isOpen)}>
        <Icon name=ChevronRight className=chevronIcon size=20 />
      </button>
    </div>
    <ul className={listClass(isOpen)}>
      {films
      ->Belt.Array.mapWithIndex((i, film) => {
        let isSelected = Belt.Option.eq(selected, Some(film.title), (a, b) => a === b)
        <FilmListItem index=i key={Belt.Int.toString(film.id)} film isSelected click=onItemSelect />
      })
      ->React.array}
    </ul>
  </div>
}
