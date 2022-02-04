open Emotion
let wrapper = css(`
  display: grid;
  grid-template-columns: 1fr 100px 1fr;
  align-items: center;
  height: 70px;
  color: #3C4248;
`)

let logo = css(`
  font-family: var(--font-logo);
  justify-self: center;
  line-height: 0.8;
  font-size: 1.3rem;
  color: #C1666B;
`)

let icons = css(`
  display:flex;
  gap: 16px;
  justify-self: end;
`)

let nameWrapper = css(`
  font-weight: 700;
  display: flex;
  align-items: center;
`)

let ampersand = css(`
  font-size: 2.7rem;
`)

let names = css(`
  line-height: 1;
  font-size: 1rem;
  width: min-content;
`)

@react.component
let make = () =>
  <div className={wrapper}>
    <div className={nameWrapper}>
      <p className={ampersand}> {React.string("&")} </p>
      <p className={names}> {React.string("Ferma Karmi's")} </p>
    </div>
    <p className={logo}> {React.string("Infinite Playlist")} </p>
    <div className={icons}> <ReactFeather.Search size={28} /> <ReactFeather.Menu size={28} /> </div>
  </div>
