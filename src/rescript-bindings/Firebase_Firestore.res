type t

module DocSnapshot = {
  type t

  @get external exists: t => bool = "exists"
  @get external id: t => string = "id"
  @send external data: (t, unit) => 'a = "data"
}

module QuerySnapshot = {
  type t

  @get external docs: t => array<DocSnapshot.t> = "docs"
  @get external size: t => int = "size"
}
module FieldValue = {
  type t

  @send external arrayUnion: (t, 'a) => t = "arrayUnion"
}

module Collection = {
  type t

  module DocRef = {
    type t

    @deriving(abstract)
    type setOptions = {merge: bool}

    @send external data: (t, unit) => 'a = "data"
    @send external get: (t, unit) => Promise.t<DocSnapshot.t> = "get"
    @send external delete: (t, unit) => Promise.t<unit> = "delete"
    @send external set: (t, 'a, ~options: setOptions=?, unit) => Promise.t<unit> = "set"
    @send external update: (t, 'a, ~options: setOptions=?, unit) => Promise.t<unit> = "update"
  }

  @send external add: (t, 'a) => Promise.t<DocRef.t> = "add"
  @send external get: (t, unit) => Promise.t<QuerySnapshot.t> = "get"
  @send external doc: (t, string) => DocRef.t = "doc"
  @send
  external where: (
    t,
    string,
    @string
    [
      | @as("==") #equal
      | @as(">") #greater
      | @as(">=") #greaterEqual
      | @as("<") #lower
      | @as("<=") #lowerEqual
      | @as("array-contains") #arrayContains
    ],
    string,
  ) => t = "where"
}

@module external require: t = "firebase/firestore"

@send external collection: (t, string) => Collection.t = "collection"
@get external fieldValue: t => FieldValue.t = "FieldValue"

module Transaction = {
  type firestore = t
  type t

  type updateFunction<'a> = t => Promise.t<'a>

  @send external get: (t, Collection.DocRef.t) => Promise.t<DocSnapshot.t> = "get"
  @send external update: (t, Collection.DocRef.t, 'a) => t = "update"
  @send
  external set: (t, Collection.DocRef.t, 'a, ~options: Collection.DocRef.setOptions=?, unit) => t =
    "set"
  @send external delete: (t, Collection.DocRef.t) => t = "delete"
}

@send
external runTransaction: (t, Transaction.updateFunction<'a>) => Promise.t<'a> = "runTransaction"
