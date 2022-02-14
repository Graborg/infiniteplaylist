type firebase

type firebaseConfig = {
  apiKey: string,
  authDomain: string,
  projectId: string,
  storageBucket: string,
  messagingSenderId: string,
  appId: string,
}

module Auth = Firebase_Auth
module Firestore = Firebase_Firestore

@module("firebase/app") external firebase: firebase = "default"

@send
external initializeApp: (firebase, 'a) => unit = "initializeApp"

@send external auth: firebase => Auth.t = "auth"
@send external firestore: firebase => Firestore.t = "firestore"
@get external firestoreObj: firebase => Firestore.t = "firestore"
