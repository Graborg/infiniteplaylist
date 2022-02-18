let tokenNamespace = "firebase-userId"
let emailNamespace = "email"

open Dom.Storage

let setUserId: string => string = token => {
  setItem(tokenNamespace, token, localStorage)
  token
}

let getUserId: unit => option<string> = () => getItem(tokenNamespace, localStorage)

let setEmail: string => unit = email => setItem(emailNamespace, email, localStorage)
let getEmail: unit => option<string> = () => getItem(emailNamespace, localStorage)
let removeEmail: unit => unit = () => removeItem(emailNamespace, localStorage)
