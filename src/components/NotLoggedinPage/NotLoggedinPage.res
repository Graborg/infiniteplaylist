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

@react.component
let make = () => {
  let (state, setState) = React.useState(_ => Login)
  let ((nickname, email), setText) = React.useState(_ => ("", ""))

  switch state {
  | Login =>
    <div className=wrapper>
      <MaxWidthWrapper> <Header /> </MaxWidthWrapper>
      <div className=fieldWrapper>
        <div className=headerWrapper>
          <h2 className=header> {React.string("Login")} </h2>
          <h2
            onClick={_ => setState(_ => Register)}
            className={Js.Array2.joinWith([header, inactiveHeader], " ")}>
            {React.string("Sign up")}
          </h2>
        </div>
        <InputField
          id="loginfield"
          placeholder="joe@email.com"
          labelName="Email"
          onFocusHandler={e => ()}
          onChangeHandler={text => setText(((prevNickname, _)) => (prevNickname, text))}
          icon=#Mail
        />
        <Button
          text="Login"
          onClick={_ =>
            FirebaseAdapter.sendSignInLink(~email, ())
            ->Promise.thenResolve(LocalStorage.setEmail)
            ->Promise.thenResolve(_ => setState(_ => WaitingForEmail))
            ->ignore}
        />
      </div>
      <Footer />
    </div>

  | Register =>
    <div className=wrapper>
      <MaxWidthWrapper> <Header /> </MaxWidthWrapper>
      <div className=fieldWrapper>
        <div className=headerWrapper>
          <h2
            onClick={_ => setState(_ => Login)}
            className={Js.Array2.joinWith([header, inactiveHeader], " ")}>
            {React.string("Login")}
          </h2>
          <h2 className=header> {React.string("Sign up")} </h2>
        </div>
        <InputField
          id="loginfield"
          placeholder="joe@email.com"
          labelName="Email"
          onFocusHandler={e => ()}
          onChangeHandler={text => setText(((prevNickname, _)) => (prevNickname, text))}
          icon=#Mail
        />
        <InputField
          id="nickname-field"
          placeholder="Peanut"
          labelName="Nickname"
          onFocusHandler={e => ()}
          onChangeHandler={text => setText(((_, prevEmail)) => (text, prevEmail))}
          icon=#Zap
        />
        <Button
          text="Register"
          onClick={_ =>
            FirebaseAdapter.sendSignInLink(~email, ~nickname, ())
            ->Promise.thenResolve(LocalStorage.setEmail)
            ->Promise.thenResolve(() => LocalStorage.setUserNick(nickname))
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
