@val @scope(("window", "location"))
external reload: unit => unit = "reload"
open Emotion

let wrapper = css(`
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
`)

let fieldWrapper = css(`
  align-self: center;
  width: max(300px, 50%);
  max-width: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  gap: 16px;
`)

let header = css(`
  color: var(--color-primary);
  font-size: 1.5rem;
`)
let descriptionWrapper = css(`
  padding-bottom: 16px;
  font-weight: 600;
  color: var(--color-lightest-gray);
`)

@react.component
let make = (~user, ~doneHandler) => {
  let (partnerEmail, setPartnerEmail) = React.useState(_ => "")
  let (displayName, setDisplayName) = React.useState(_ => "")

  let completeRegistration = (partnerEmail, displayName) => {
    let userId = user->Firebase.Auth.User.uid
    FirebaseAdapter.addUser(~userId, ~displayName, ~partnerEmail)
    ->Promise.then(_ => FirebaseAdapter.setPartnerAccessToFilmList(~userId, ~partnerEmail))
    ->Promise.thenResolve(_ => {
      RescriptReactRouter.push("/")
      LocalStorage.setUserDisplayName(displayName)->ignore
      doneHandler(user)
    })
    ->ignore
  }

  <div className=wrapper>
    <MaxWidthWrapper> <Header /> </MaxWidthWrapper>
    <div className=fieldWrapper>
      <p className=descriptionWrapper>
        <h1 className=header> {React.string("Invite Partner")} </h1>
        <p> {React.string("Enter your nickname and your partners email")} </p>
      </p>
      <InputField
        placeholder="Peanut"
        onFocusHandler={_ => ()}
        onChangeHandler={name => setDisplayName(_ => name)}
        id="nickname-field"
        labelName="Your nickname"
        icon=#Zap
      />
      <InputField
        placeholder="joe@email.com"
        onFocusHandler={_ => ()}
        onChangeHandler={email => setPartnerEmail(_ => email)}
        id="partner-email-field"
        labelName="Partner email"
        icon=#Mail
      />
    </div>
    <Footer />
  </div>
}
