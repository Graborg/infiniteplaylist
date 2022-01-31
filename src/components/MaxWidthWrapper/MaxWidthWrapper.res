let maxWidthWrapper = Emotion.css(`
  position: relative;
  max-width: min(100%, calc(1200px + 32px * 2));
  padding-left: 16px;
  padding-right: 16px;
  @media (min-width: calc(1100 / 16rem)) {
    padding-left: 32px;
    padding-right: 32px;
  }
`)

@react.component
let make = (~children) => <div className={maxWidthWrapper}> children </div>
