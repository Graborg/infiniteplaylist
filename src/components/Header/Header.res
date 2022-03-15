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

let getUserNames: unit => Promise.t<(option<string>, option<string>)> = () => {
  open Promise
  let maybeUserName = LocalStorage.getUserDisplayName()
  let maybePartnerName = LocalStorage.getPartnerDisplayName()
  let maybeUserId = LocalStorage.getUserId()
  let maybeUserEmail = LocalStorage.getEmail()
  switch (maybeUserName, maybePartnerName, maybeUserId, maybeUserEmail) {
  | (Some(userName), Some(partnerName), _, _) => resolve((Some(userName), Some(partnerName)))
  | (_, _, Some(userId), Some(email)) =>
    FirebaseAdapter.getUserNames(~userId, ~email)->thenResolve(((
      displayName,
      partnerDisplayName,
    )) => {
      Belt.Option.map(displayName, name => LocalStorage.setUserDisplayName(name))->ignore
      Belt.Option.map(partnerDisplayName, name => LocalStorage.setPartnerDisplayName(name))->ignore
      (displayName, partnerDisplayName)
    })
  | (_, _, _, _) => resolve((None, None))
  }
}

@react.component
let make = (~isLoggedIn=false) => {
  let ((maybeUserName, maybePartnerName), setNames) = React.useState(() => (None, None))
  React.useEffect0(() => {
    getUserNames()
    ->Promise.thenResolve(((maybeUserName, maybePartnerName)) =>
      setNames(_ => (maybeUserName, maybePartnerName))
    )
    ->ignore

    None
  })

  <div className={wrapper}>
    {switch (isLoggedIn, maybePartnerName, maybeUserName) {
    | (true, Some(partnerName), Some(userName)) =>
      <div className={nameWrapper}>
        <p className={ampersand}> {React.string("&")} </p>
        <p className={names}> {React.string(partnerName ++ " " ++ userName ++ "'s")} </p>
      </div>
    | (true, None, Some(userName)) =>
      <div className={nameWrapper}>
        <p className={names}> {React.string(userName ++ "'s")} </p>
      </div>
    | (true, _, None) => <a href="/invitePartner"> {React.string("set username")} </a>
    | (false, _, _) => <div />
    }}
    <a href="/"> <p className={logo}> {React.string("Infinite Playlists")} </p> </a>
    {isLoggedIn
      ? <div className={icons}>
          <ReactFeather.Search size={28} /> <ReactFeather.Menu size={28} />
        </div>
      : <div />}
  </div>
}
