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

module Collection = {
  type t

  module DocRef = {
    type t

    @deriving(abstract)
    type setOptions = {merge: bool}

    @send external data: (t, unit) => 'a = "data"
    @send external get: (t, unit) => Js.Promise.t<DocSnapshot.t> = "get"
    @send external delete: (t, unit) => Js.Promise.t<unit> = "delete"
    @send
    external set: (t, 'a, ~options: setOptions=?, unit) => Js.Promise.t<unit> = "set"
  }

  @send external add: (t, 'a) => Js.Promise.t<DocRef.t> = "add"
  @send external get: (t, unit) => Js.Promise.t<QuerySnapshot.t> = "get"
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

module Transaction = {
  type firestore = t
  type t

  type updateFunction<'a> = t => Js.Promise.t<'a>

  @send external get: (t, Collection.DocRef.t) => Js.Promise.t<DocSnapshot.t> = "get"
  @send external update: (t, Collection.DocRef.t, 'a) => t = "update"
  @send
  external set: (t, Collection.DocRef.t, 'a, ~options: Collection.DocRef.setOptions=?, unit) => t =
    "set"
  @send external delete: (t, Collection.DocRef.t) => t = "delete"
}

@send
external runTransaction: (t, Transaction.updateFunction<'a>) => Js.Promise.t<'a> = "runTransaction"
