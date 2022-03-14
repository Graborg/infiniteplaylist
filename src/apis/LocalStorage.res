let tokenNamespace = "firebase-userId"
let emailNamespace = "email"
let partnerNickNameSpace = "partner-nick"
let nickNameSpace = "user-nick"

open Dom.Storage

let getUserId: unit => option<string> = () => getItem(tokenNamespace, localStorage)
let setUserId: string => string = token => {
  setItem(tokenNamespace, token, localStorage)
  token
}

let getUserDisplayName: unit => option<string> = () => getItem(nickNameSpace, localStorage)
let setUserDisplayName: string => unit = name => setItem(nickNameSpace, name, localStorage)

let getPartnerDisplayName: unit => option<string> = () =>
  getItem(partnerNickNameSpace, localStorage)
let setPartnerDisplayName: string => unit = name =>
  setItem(partnerNickNameSpace, name, localStorage)

let setEmail: string => unit = email => setItem(emailNamespace, email, localStorage)
let getEmail: unit => option<string> = () => getItem(emailNamespace, localStorage)
let removeEmail: unit => unit = () => removeItem(emailNamespace, localStorage)
