type state =
  | Login
  | Register
  | WaitingForEmail
  | Error

let wrapper = Emotion.css(`
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  padding-top: 30vh;
`)

let fieldWrapper = Emotion.css(`
  align-self: center;
  width: max(300px, 50%);
  max-width: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  gap: 16px;
`)
let header = Emotion.css(`
  color: var(--color-primary);
  font-size: 1.5rem;
`)

let inactiveHeader = Emotion.css(`
  color: var(--color-lightest-gray);
`)
let headerWrapper = Emotion.css(`
  display: flex;
  gap: 12px;
`)
let contentWrapper = Emotion.css(`
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-left: 16px;
  padding-right: 16px;
  margin: auto;
  gap: 8px;
`)

let description = Emotion.css(`
  text-align: center;
`)
@react.component
let make = () => {
  let (state, setState) = React.useState(_ => Login)
  let (email, setEmail) = React.useState(_ => "")
  let (submitIsDisabled, setDisableSubmit) = React.useState(_ => false)

  switch state {
  | Login => <>
      <MaxWidthWrapper> <Header isUsersTurnOpt=None /> </MaxWidthWrapper>
      <form
        onSubmit={(e: ReactEvent.Form.t) => {
          ReactEvent.Form.preventDefault(e)
          setDisableSubmit(_ => true)
          FirebaseAdapter.sendSignInLink(~email, ())
          ->Promise.thenResolve(LocalStorage.setEmail)
          ->Promise.thenResolve(_ => setState(_ => WaitingForEmail))
          ->ignore
        }}
        className=wrapper>
        <div className=fieldWrapper>
          <div className=headerWrapper>
            <h2 className=header> {React.string("Login/Register")} </h2>
          </div>
          <InputField
            id="loginfield"
            placeholder="joe@email.com"
            labelName="Email"
            onChange={e => {
              let email = ReactEvent.Form.target(e)["value"]
              setDisableSubmit(_ => false)
              setEmail(_ => email)
            }}
            value=email
            icon=Mail
          />
          <Button disabled=submitIsDisabled text="Send link" />
        </div>
        <Footer />
      </form>
    </>
  | WaitingForEmail => <>
      <Header isUsersTurnOpt=None />
      <div className=wrapper>
        <div className=contentWrapper>
          <h3> {React.string("Check your email inbox for login link!")} </h3>
          <p className=description>
            {React.string("A 'magic' email-link has been sent to you, which you can use to login.")}
          </p>
        </div>
        <Footer />
      </div>
    </>
  | _ => <p> {React.string("error")} </p>
  }
}
