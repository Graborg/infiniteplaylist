@val @scope(("window", "location"))
open Emotion

let wrapper = css(`
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding-top: 30vh;
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
let make = (~user: FirebaseAdapter.optionalFirebaseUser, ~doneHandler) => {
  let (partnerEmail, setPartnerEmail) = React.useState(_ => "")
  let (displayName, setDisplayName) = React.useState(_ => "")
  let (submitIsDisabled, setDisableSubmit) = React.useState(_ => false)

  let completeRegistration = (existingUser, partnerEmail, displayName) => {
    let userId = existingUser->Firebase.Auth.User.uid
    FirebaseAdapter.addUser(~userId, ~displayName, ~partnerEmail)
    ->Promise.then(_ => FirebaseAdapter.setPartnerAccessToFilmList(~userId, ~partnerEmail))
    ->Promise.thenResolve(_ => {
      RescriptReactRouter.push("/")
      LocalStorage.setUserDisplayName(displayName)->ignore
      doneHandler(existingUser)
    })
    ->ignore
  }
  <>
    <MaxWidthWrapper> <Header isUsersTurnOpt=None /> </MaxWidthWrapper>
    <div className=wrapper>
      {switch user {
      | SomeUser(existingUser) =>
        <form
          className=fieldWrapper
          onSubmit={(e: ReactEvent.Form.t) => {
            setDisableSubmit(_ => true)
            ReactEvent.Form.preventDefault(e)
            completeRegistration(existingUser, partnerEmail, displayName)
          }}>
          <p className=descriptionWrapper>
            <h1 className=header> {React.string("Invite Partner")} </h1>
            <p> {React.string("Enter your nickname and your partners email")} </p>
          </p>
          <InputField
            placeholder="Peanut"
            onChange={e => {
              let name = ReactEvent.Form.target(e)["value"]
              setDisableSubmit(_ => false)
              setDisplayName(_ => name)
            }}
            id="nickname-field"
            labelName="Your nickname"
            icon=Zap
            value=displayName
          />
          <InputField
            placeholder="joe@email.com"
            onChange={e => {
              let email = ReactEvent.Form.target(e)["value"]
              setDisableSubmit(_ => false)
              setPartnerEmail(_ => email)
            }}
            id="partner-email-field"
            labelName="Partner email"
            icon=Mail
            value=partnerEmail
          />
          <Button disabled=submitIsDisabled text="Enter" />
        </form>
      | _ =>
        <form className=fieldWrapper>
          <p className=descriptionWrapper>
            <h1 className=header> {React.string("Invite Partner")} </h1>
            <p> {React.string("Enter your nickname and your partners email")} </p>
          </p>
          <InputField
            placeholder="Peanut"
            onChange={e => {
              let name = ReactEvent.Form.target(e)["value"]
              setDisableSubmit(_ => false)
              setDisplayName(_ => name)
            }}
            id="nickname-field"
            labelName="Your nickname"
            icon=Zap
            value=displayName
          />
          <InputField
            placeholder="joe@email.com"
            onChange={e => {
              let email = ReactEvent.Form.target(e)["value"]
              setDisableSubmit(_ => false)
              setPartnerEmail(_ => email)
            }}
            id="partner-email-field"
            labelName="Partner email"
            icon=Mail
            value=partnerEmail
          />
          <Button disabled=true text="Enter" />
        </form>
      }}
      <Footer />
    </div>
  </>
}
