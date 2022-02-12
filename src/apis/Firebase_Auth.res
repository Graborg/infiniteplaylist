type t

@module external require: t = "firebase/auth"

module User = {
  type t

  @get external displayName: t => string = "displayName"
  @get external email: t => string = "email"
  @get external emailVerified: t => bool = "emailVerified"
  @get external isAnonymous: t => bool = "isAnonymous"
  @get external photoURL: t => string = "photoURL"
  @get external refreshToken: t => string = "refreshToken"
  @get external uid: t => string = "uid"
  @get external phoneNumber: t => Js.Nullable.t<string> = "phoneNumber"

  @send
  external getIdToken: (t, unit) => Js.Promise.t<string> = "getIdToken"
}

module Result = {
  type t

  module Credentials = {
    type t

    @get external accessToken: t => string = "accessToken"
    @get external idToken: t => string = "idToken"
    @get external providerId: t => string = "providerId"
    @get external signInMethod: t => string = "signInMethod"
  }

  module AdditionalUserInfo = {
    type t

    module Profile = {
      type t

      @get external email: t => string = "email"
      @get external familyName: t => string = "family_name"
      @get external givenName: t => string = "given_name"
      @get external grantedScopes: t => string = "granted_scopes"
      @get external id: t => string = "id"
      @get external locale: t => string = "locale"
      @get external name: t => string = "name"
      @get external picture: t => string = "picture"
      @get external verifiedEmail: t => bool = "verified_email"
    }

    @get external isNewUser: t => bool = "isNewUser"
    @get external providerId: t => string = "providerId"
    @get external profile: t => Profile.t = "profile"
  }

  @get external user: t => User.t = "user"
  @get external credentials: t => Credentials.t = "user"
  @get external operationType: t => string = "operationType"
  @get
  external additionalUserInfo: t => AdditionalUserInfo.t = "additionalUserInfo"
}

module Provider = {
  type t

  @new @module("firebase") @scope("auth")
  external google: unit => t = "GoogleAuthProvider"

  @new @module("firebase") @scope("auth")
  external twitter: unit => t = "TwitterAuthProvider"
}

@send
external signInAnonymously: t => Js.Promise.t<Result.t> = "signInAnonymously"

@send
external signInWithEmailAndPassword: (
  t,
  ~email: string,
  ~password: string,
) => Js.Promise.t<Result.t> = "signInWithEmailAndPassword"

type actionCodeSettings = {url: string, handleCodeInApp: bool}
@send
external sendPasswordResetEmail: (
  t,
  ~email: string,
  ~actionCodeSettings: Js.Nullable.t<actionCodeSettings>,
) => Js.Promise.t<unit> = "sendPasswordResetEmail"

@send
external sendSignInLinkToEmail: (
  t,
  ~email: string,
  ~actionCodeSettings: actionCodeSettings,
) => Js.Promise.t<unit> = "sendSignInLinkToEmail"

@send
external isSignInWithEmailLink: (t, ~link: string) => bool = "isSignInWithEmailLink"

@send
external signInWithEmailLink: (t, ~email: string, ~link: string) => Js.Promise.t<User.t> =
  "signInWithEmailLink"

@send
external confirmPasswordReset: (t, ~code: string, ~newPassword: string) => Js.Promise.t<unit> =
  "confirmPasswordReset"

@send
external signInWithPopup: (t, Provider.t) => Js.Promise.t<Result.t> = "signInWithPopup"

@send
external onAuthStateChanged: (t, User.t => unit) => unit = "onAuthStateChanged"

@send external signOut: (t, unit) => unit = "signOut"

@get external currentUser: t => User.t = "currentUser"
