open Emotion

let itemWrapper = css(`
  display: grid; 
  grid-template-columns: 2fr 1fr; 
  grid-template-rows:  1fr auto;
  grid-template-areas:
    'header poster'
    'plot poster';
  column-gap: 12px;
  row-gap: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--color-primary-light);
  font-size: 1rem;
  @media (min-width: 600px) {
    grid-template-rows: auto 1fr;
  }
`)

let listItem = css(
  `
  padding: 12px 8px 0 8px;
  &:last-child .${itemWrapper}  {
    border-bottom: 0;
  }
  &:focus-visible {
    outline: 5px auto;
  }
`,
)

let itemHeader = css(`
  grid-area: header;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  gap: 4px;
  color: var(--color-lightest-gray);
  font-family: var(--font-fancy);
`)

let metaWrapper = css(`
  display: flex;
  overflow: hidden;
  white-space: nowrap;
  gap: 4px;
`)

let titleWrapper = css(`
display: flex;
  white-space: nowrap;
  font-weight: bold;
  font-size: 1.125rem;
  color: var(--color-black);
`)

let itemTitle = css(`
  text-overflow: ellipsis;
  overflow:hidden;
  font-style: oblique 12deg;
  padding-right: 4px;
`)

let itemPlot = css(`
  grid-area: plot;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 5;
  overflow: hidden;
  height: fit-content;
  color: var(--color-black);
  @media (min-width: 450px) {

  -webkit-line-clamp: 8;
  }
`)

let poster = posterHasLoaded =>
  css(
    `
  max-width:100%;
  height: 100%;
  grid-area: poster;
  border-radius: 4px;
  display: ${posterHasLoaded ? "block" : "none"};
  object-fit: contain;
`,
  )

let posterSkeleton = posterHasLoaded =>
  css(
    `
    display: ${posterHasLoaded ? "none" : "block"};
    min-height: 175px;
    background: var(--color-lightest-gray);
    grid-area: poster;
    border-radius: 4px;
    position: relative;
    &::after {
      position: absolute;
      inset: 0;
      transform: translateX(-50%);
      background-image: linear-gradient(
        90deg, 
        rgba(255, 255, 255, 0) 0,
        rgba(255, 255, 255, 0.2) 20%, 
        rgba(255, 255, 255, 0.5) 60%, 
        rgba(255, 255, 255, 0)
      );
      animation: shimmer 2s infinite;
      content: '';
    }

    @keyframes shimmer {
      100% {
        transform: translateX(100%);
      }
    }
  `,
  )

let yearFromDate: string => string = date => Js.String2.slice(date, ~from=0, ~to_=4)
@react.component
let make = (~film: TheMovieDB.searchResult, ~clickHandler: TheMovieDB.searchResult => unit) => {
  let (posterHasLoaded, setPosterLoading) = React.useState(() => false)

  <li
    tabIndex=0
    className=listItem
    onKeyDown={key => {
      if ReactEvent.Keyboard.key(key) === "Enter" {
        clickHandler(film)
      }
    }}
    onClick={_ => clickHandler(film)}>
    {switch (film.title, film.genres, film.releaseDate, film.posterPath, film.plot) {
    | (title, Some(genres), Some(releaseDate), Some(poster_path), Some(plot)) =>
      <div className=itemWrapper>
        <div className=itemHeader>
          <p className=titleWrapper>
            <span className=itemTitle> {React.string(title)} </span>
            <span> {React.string(" (" ++ releaseDate->yearFromDate ++ ")")} </span>
          </p>
          <p className=metaWrapper>
            <span>
              {React.string(genres->Belt.Array.slice(~offset=0, ~len=2)->Js.Array2.joinWith("/"))}
            </span>
            <span> {React.string(`•`)} </span>
            <span> {React.string(`2h 35m`)} </span>
          </p>
        </div>
        <p className=itemPlot> {React.string(plot)} </p>
        <div className={posterSkeleton(posterHasLoaded)} />
        <img
          className={poster(posterHasLoaded)}
          onLoad={_ => setPosterLoading(_ => true)}
          src={TheMovieDB.poster_uri ++ poster_path}
        />
      </div>
    | (title, _, _, _, _) => React.string(title)
    }}
  </li>
}
