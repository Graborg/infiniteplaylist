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
  height: 100px;
  width: max(300px, 50%);
  max-width: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
`)

@react.component
let make = (~userId, ~doneHandler) => {
  let (partnerEmail, setPartnerEmail) = React.useState(_ => "")

  let addPartner = partnerEmail => {
    FirebaseAdapter.setPartner(~userId, ~partnerEmail)
    ->Promise.thenResolve(_ => {
      RescriptReactRouter.push("/")
      doneHandler()
    })
    ->ignore
  }

  <div className=wrapper>
    <MaxWidthWrapper> <Header /> </MaxWidthWrapper>
    <div className=fieldWrapper>
      <InputField
        placeholder="joe@email.com"
        onFocusHandler={_ => ()}
        onChangeHandler={email => setPartnerEmail(_ => email)}
        id="partner-email-field"
        labelName="Partner email"
        icon=#Mail
      />
      <Button text="addPartner" onClick={_ => addPartner(partnerEmail)} />
    </div>
    <Footer />
  </div>
}
