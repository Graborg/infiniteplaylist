open Emotion
let wrapper = showAnimation =>
  css(
    `
  display: grid;
  grid-template-columns: 1fr 100px 1fr;
  align-items: center;
  height: 70px;
  color: var(--color-lighter-gray);
  @keyframes fadeIn {
    from {
      filter: opacity(0)
    }
    to {
      filter: opacity(1)
    }
  }
  @keyframes pop {
    from {
      transform: translateX(-100%);
    }
    to {
      transform: translateX(0);
    }
  }
  /* ${showAnimation ? "animation: pop 600ms both ease" : ""} ; */
`,
  )

let logo = css(`
  font-family: var(--font-logo);
  justify-self: center;
  line-height: 0.8;
  font-size: 1.3rem;
  color: var(--color-primary);
  will-change: filter;
`)

let icons = css(`
  display:flex;
  gap: 16px;
  justify-self: end;
  /* animation: fadeIn 1200ms 100ms both ease; */
 `)

let nameWrapper = css(`
  font-weight: 700;
  display: flex;
  z-index: 2;
  align-items: center;
  /* animation: fadeIn 1200ms 100ms both ease; */
`)

let ampersand = css(`
  font-size: 2.7rem;
`)

let name = css(`
  line-height: 1;

`)

let turnIndicator = userColor =>
  css(
    `
    @keyframes blink {
      0% {
        opacity: 0;
      }
      50% {
        opacity: 1;
      }
      100% {
        opacity: 0;
      }
    }
    display: inline-block;
    width: 7px;
    height: 7px;
    background-color: ${userColor}; 
    border-radius: 50%;
    vertical-align: middle;
    margin-left: 4px;
    line-height: 1;
    transform: translateY(-1px);
    animation: blink 1700ms 1500ms both ease-in-out;
    animation-iteration-count: 2.5;
    & .tooltip {
      display: none;
      font-size: 0.8rem;
      position: absolute;
      left: 10px;
      top: -6px;
      padding: 2px;
      white-space: nowrap;
      border: 1px solid var(--color-primary-light);
      background-color: var(--color-background);
    }
    &:hover .tooltip {
      display: inline-block;
      
    }

`,
  )
let hiddenElement = css(``)
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
let make = (~isLoggedIn=false, ~isUsersTurnOpt, ()) => {
  let ((maybeUserName, maybePartnerName), setNames) = React.useState(() => (
    LocalStorage.getUserDisplayName(),
    LocalStorage.getPartnerDisplayName(),
  ))
  React.useEffect0(() => {
    getUserNames()
    ->Promise.thenResolve(((maybeUserName, maybePartnerName)) =>
      setNames(_ => (maybeUserName, maybePartnerName))
    )
    ->ignore

    None
  })

  open Belt
  <div className={wrapper(!isLoggedIn)}>
    {switch (isLoggedIn, maybePartnerName, maybeUserName) {
    | (true, Some(partnerName), Some(userName)) =>
      <div className={nameWrapper}>
        <h2 className={ampersand}> {React.string("&")} </h2>
        <div>
          <h2 className=name>
            {React.string(partnerName)}
            {Option.mapWithDefault(isUsersTurnOpt, <div />, isUsersTurn =>
              isUsersTurn
                ? <> </>
                : <div className={turnIndicator("var(--color-partner)")}>
                    <div className="tooltip"> {React.string("Your partner's turn to choose")} </div>
                  </div>
            )}
          </h2>
          <h2 className=name>
            {React.string(userName ++ "'s")}
            {Option.mapWithDefault(isUsersTurnOpt, <div />, isUsersTurn =>
              isUsersTurn
                ? <div className={turnIndicator("var(--color-user)")}>
                    <div className="tooltip"> {React.string("Your turn to choose")} </div>
                  </div>
                : <> </>
            )}
          </h2>
        </div>
      </div>
    | (true, None, Some(userName)) =>
      <div className={nameWrapper}>
        <h2 className={name}> {React.string(userName ++ "'s")} </h2>
      </div>
    | (true, _, None) => <a href="/invitePartner"> {React.string("set username")} </a>
    | (false, _, _) => <div />
    }}
    <a href="/"> <h2 className={logo}> {React.string("Infinite Playlist")} </h2> </a>
    {isLoggedIn
      ? <div className={icons}>
          <ReactFeather.Search size={28} /> <ReactFeather.Menu size={28} />
        </div>
      : <div />}
  </div>
}
