type t =
  | Loading
  | Loaded(array<FilmType.film>)

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
`)

let titleWrapper = Emotion.css(`
  display: flex;
  align-items: center;
  gap: 4px;
  padding-bottom: 4px;
  animation: fadeIn 2200ms both;  
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
  cursor: pointer;
`,
  )

let chevronIcon = Emotion.css(`
    vertical-align: middle;
    transform: translateY(2px);
  `)
let userCountHeader = Emotion.css(`
  color: var(--color-user);
  padding: 0 5px;
`)

let partnerCountHeader = Emotion.css(`
  color: var(--color-partner);
  padding: 0 5px;
`)

let b = Emotion.css(`
display: flex;
background-color: var(--color-black);
border-radius: 5px;
color: white;
padding: 0 2px 1px 2px;
`)

open Belt.Int
open Belt.Array
let userFilmCountInList = (films: array<FilmType.film>) =>
  films->keep(f => f.creatorIsCurrentUser)->size->toString

let partnerFilmCountInList = (films: array<FilmType.film>) =>
  films->keep(f => !f.creatorIsCurrentUser)->size->toString
@react.component
let make = (~header: string, ~films: t, ~selected=?, ~onItemSelect, ~initAsOpen=true, ()) => {
  let (isOpen, toggle) = React.useState(() => true)

  React.useEffect0(() => {
    toggle(_ => initAsOpen)
    None
  })

  <div className=wrapper>
    <div className=titleWrapper>
      <h3 className=listTitle> {React.string(header)} </h3>
      {switch films {
      | Loading => <> </>
      | Loaded(loadedFilms) =>
        <div className=b>
          {React.string("(")}
          <h3 className=userCountHeader> {React.string(userFilmCountInList(loadedFilms))} </h3>
          {React.string(",")}
          <h3 className=partnerCountHeader>
            {React.string(partnerFilmCountInList(loadedFilms))}
          </h3>
          {React.string(")")}
        </div>
      }}
      <button onClick={_ => toggle(prev => !prev)} className={expandList(isOpen)}>
        <Icon name=ChevronRight className=chevronIcon size=20 />
      </button>
    </div>
    {switch films {
    | Loading => <> </>
    | Loaded(loadedFilms) =>
      <ul className={listClass(isOpen)}>
        {loadedFilms
        ->Belt.Array.mapWithIndex((i, film) => {
          let isSelected = Belt.Option.eq(selected, Some(film.title), (a, b) => a === b)
          <FilmListItem
            index=i key={Belt.Int.toString(film.id)} film isSelected click=onItemSelect
          />
        })
        ->React.array}
      </ul>
    }}
  </div>
}
