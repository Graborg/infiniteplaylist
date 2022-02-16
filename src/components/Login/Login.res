type state =
  | Initial(string)
  | WaitingForEmail
  | Error

let wrapper = Emotion.css(`
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
`)

let fieldWrapper = Emotion.css(`
  align-self: center;
  height: 100px;
  width: max(300px, 50%);
  max-width: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
`)

@react.component
let make = () => {
  let (state, setState) = React.useState(_ => Initial(""))
  let onChangeHandler = text => setState(_ => Initial(text))

  switch state {
  | Initial(email) =>
    <div className=wrapper>
      <MaxWidthWrapper> <Header /> </MaxWidthWrapper>
      <div className=fieldWrapper>
        <InputField
          id="loginfield"
          placeholder="joe@email.com"
          labelName="Email"
          onFocusHandler={e => ()}
          onChangeHandler
          icon=#Mail
        />
        <LoginButton
          clickHandler={_ =>
            FirebaseAdapter.sendSignInLink(~email)
            ->Promise.thenResolve(LocalStorage.setEmail)
            ->Promise.thenResolve(_ => setState(_ => WaitingForEmail))
            ->ignore}
        />
      </div>
      <Footer />
    </div>
  | WaitingForEmail => <p> {React.string("Check your email for login link!")} </p>
  | _ => <p> {React.string("error")} </p>
  }
}
