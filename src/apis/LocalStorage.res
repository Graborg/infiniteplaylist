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

let getUserNick: unit => option<string> = () => getItem(nickNameSpace, localStorage)
let setUserNick: string => unit = userNick => setItem(nickNameSpace, userNick, localStorage)

let getPartnerNick: unit => option<string> = () => getItem(partnerNickNameSpace, localStorage)
let setPartnerNick: string => unit = partnerNick =>
  setItem(partnerNickNameSpace, partnerNick, localStorage)

let setEmail: string => unit = email => setItem(emailNamespace, email, localStorage)
let getEmail: unit => option<string> = () => getItem(emailNamespace, localStorage)
let removeEmail: unit => unit = () => removeItem(emailNamespace, localStorage)
