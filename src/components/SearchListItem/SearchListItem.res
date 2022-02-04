let itemWrapper = Emotion.css(`
  display: grid; 
  grid-template-columns: 2fr 1fr; 
  grid-template-rows:  1fr auto;
  grid-template-areas:
    'header poster'
    'plot poster';
  padding: 12px 8px;
  column-gap: 12px;
  row-gap: 12px;
  border-bottom: 1px solid var(--color-primary);
  font-size: 1rem;
`)

let itemHeader = Emotion.css(`
  grid-area: header;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  gap: 4px;
  color: var(--color-lightest-gray);
  font-family: var(--font-fancy);
`)

let titleWrapper = Emotion.css(`
  display: flex;
  overflow: hidden;
  white-space: nowrap;
  gap: 4px;
  font-weight: bold;
  font-size: 1.125rem;
  color: var(--color-black);
`)

let itemTitle = Emotion.css(`
  text-overflow: ellipsis;
  overflow:hidden;
  white-space: nowrap;
  font-style: oblique 12deg;
  padding-right: 1px;
`)

let itemPlot = Emotion.css(`
  grid-area: plot;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 5;
  overflow: hidden;
  height: fit-content;
  color: var(--color-black);
`)

let poster = posterHasLoaded => 
  Emotion.css(`
  max-width:100%;
  height: 100%;
  grid-area: poster;
  border-radius: 4px;
  display: ${posterHasLoaded ? "block" : "none"};
`)

let posterSkeleton = posterHasLoaded => 
  Emotion.css(`
    display: ${posterHasLoaded ? "none" : "block" };
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
  `)
@react.component
let make = (~film: TheMovieDB.filmResult, ~clickHandler) => {
  let (posterHasLoaded, setPosterLoading) = React.useState(() => false)

  <li onClick={item => clickHandler(film)}>
    {switch (film["title"], film["genres"], film["year"], film["poster_path"], film["plot"]) {
    | (Some(title), Some(genres), Some(year), Some(poster_path), Some(plot)) =>
      <div className=itemWrapper>
        <div className=itemHeader>
          <p className=titleWrapper>
            <span className=itemTitle> {React.string(title)} </span>
            <span> {React.string(year)} </span>
            <span> {React.string(`•`)} </span>
            <span> {React.string(`2h 35m`)} </span>
          </p>
          <span>
            {React.string(genres->Belt.Array.slice(~offset=0, ~len=2)->Js.Array2.joinWith("/"))}
          </span>
        </div>
        <p className=itemPlot> {React.string(plot)} </p>
        <div className=posterSkeleton(posterHasLoaded) />
        <img className=poster(posterHasLoaded) onLoad={(_) => 
          setPosterLoading((_) => true)
        } src={TheMovieDB.poster_uri ++ poster_path } />
      </div>
    | (Some(title), _, _, _, _) => React.string(title)
    | (_, _, _, _, _) => React.string("<error no title>")
    }}
  </li>
}
