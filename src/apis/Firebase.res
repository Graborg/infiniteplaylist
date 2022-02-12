type firebase
type firebaseConfig

module Auth = Firebase_Auth
module Firestore = Firebase_Firestore

@module("firebase/app") external firebase: firebase = "default"

@send
external initializeApp: (firebase, 'a) => unit = "initializeApp"

@send external auth: firebase => Auth.t = "auth"
@send external firestore: firebase => Firestore.t = "firestore"
