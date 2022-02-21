@val external window: 'a = "window"
type state =
  | LoadingFilms
  | Onboarding(Firebase.Auth.User.t)
  | Error
  | InvalidLoginLinkError
  | LoginEmailNotFoundError
  | LoadedFilms(array<FilmType.film>, array<FilmType.film>)
  | NotLoggedin

type url = {
  path: list<string>,
  hash: string,
  search: string,
}

let wrapper = Emotion.css(`
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
`)

let listTitle = Emotion.css(`
  font-size: calc(20rem/16);
  width: fit-content;
  padding-bottom: 4px;
  padding-top: 24px;
  border-bottom: 1px solid var(--color-black);
`)

@react.component
let make = () => {
  let (state, setState) = React.useState(() => LoadingFilms)
  //let (filmRandomlySelected, randomlySelectFilm) = React.useState(() => "")
  let firebaseUser = FirebaseAdapter.useUser()

  /* let doSelectFilm = filmId => */
  /* setState(prevState => */
  /* switch prevState { */
  /* | LoadedFilms(list, seenFilms) => LoadedFilms(list, seenFilms) */
  /* | _ => prevState */
  /* } */
  /* ) */
  let loadAndSetFilms = (user: Firebase.Auth.User.t) =>
    FirebaseAdapter.getFilmLists(user)->Promise.thenResolve((movieList: array<FilmType.film>) => {
      open Js.Array2

      let unseen = movieList->filter(film => !film.seen)
      let seen = movieList->filter(film => film.seen)
      setState(_ => LoadedFilms(unseen, seen))
    })

  let handleLoginCallback = () => {
    open Promise
    open FirebaseAdapter
    let url: string = window["location"]["href"]
    handleAuthCallback(~link=url)
    ->thenResolve(_ => RescriptReactRouter.push("/invitePartner"))
    ->catch(error =>
      switch error {
      | InvalidLink => RescriptReactRouter.push("/invalidEmailLinkError")
      | EmailNotFound => RescriptReactRouter.push("/emailNotFoundError")
      | _ => RescriptReactRouter.replace("/error")
      }->resolve
    )
    ->ignore
  }

  let handleOnboardingDone = user => loadAndSetFilms(user)

  let urlParts = RescriptReactRouter.useUrl()
  React.useEffect2(() => {
    switch (urlParts.path, firebaseUser) {
    | (list{"invitePartner"}, SomeUser(user)) => setState(_ => Onboarding(user))
    | (_, SomeUser(user)) => {
        loadAndSetFilms(user)->ignore
        RescriptReactRouter.push("/")
      }
    | (list{"loginCallback"}, NoUser) => handleLoginCallback()
    | (list{"emailNotFoundError"}, NoUser) => setState(_prevState => LoginEmailNotFoundError)
    | (list{"invalidEmailLinkError"}, NoUser) => setState(_prevState => InvalidLoginLinkError)
    | (list{}, NoUser) => setState(_prevState => NotLoggedin)
    | _ => setState(prevState => prevState)
    }

    None
  }, (urlParts.search, firebaseUser))

  let addFilmHandler: TheMovieDB.searchResult => unit = item => {
    open FirebaseAdapter
    open Firebase.Auth.User
    switch firebaseUser {
    | NoUser => Js.Console.error("Can't add movie if not logged in")
    | LoadingUser => Js.Console.error("Can't add movie if not logged in")
    | SomeUser(user) => {
        let firebaseFilm: firebaseFilm = {
          id: item.id,
          title: item.title,
          creatorId: uid(user),
          releaseDate: item.releaseDate,
          posterPath: item.posterPath,
          plot: item.plot,
          language: item.language,
          genres: item.genres,
          seen: false,
        }
        switch state {
        | LoadedFilms(films, seenFilms) => {
            let film = firebaseFilm->convertToFilm
            let alreadyInList = films->Js.Array2.map(f => f.id)->Js.Array2.includes(film.id)

            if alreadyInList {
              Js.Console.error("Item already in list")
            } else {
              setState(_ => {
                let newUnseen = Js.Array.concat([film], films)
                LoadedFilms(newUnseen, seenFilms)
              })
              user->uid->addFilmToList(firebaseFilm)->ignore
            }
          }
        | _ => Js.Console.error("Can't add movie to filmlist state if not loaded")
        }
      }
    }
  }

  let markFilmAsSeen = (film: FilmType.film) => {
    Js.Global.setTimeout(() => {
      setState(pastState => {
        switch pastState {
        | LoadedFilms(films, seenFilms) =>
          let newUnseen = Js.Array2.filter(films, f => f.title !== film.title)
          let newSeenFilms = Js.Array.concat(seenFilms, [film])
          LoadedFilms(newUnseen, newSeenFilms)
        | _ => pastState
        }
      })
    }, 500)->ignore
  }

  /* let unDooSeenFilm = (film: FilmType.film) => { */
  /* //let _k = Todoist.setFilmAsUnseen(film) */
  /* Js.Global.setTimeout(() => { */
  /* setState((LoadedFilms(films, seenFilms)) => { */
  /* let newSeenFilms = Js.Array2.filter(seenFilms, f => f.title !== film.title) */
  /* let newUnseen = Js.Array.concat(films, [film]) */
  /* LoadedFilms(newUnseen, newSeenFilms) */
  /* }) */
  /* }, 500) -> ignore */
  /* } */

  /* let getNextElector = (seenFilms: array<FilmType.film>) => { */
  /* let selectedByKarmi = */
  /* Js.Array2.filter(seenFilms, film => film.creator === FilmType.Karmi)->Js.Array.length */
  /* let selectedByFerma = */
  /* Js.Array2.filter(seenFilms, film => film.creator === Ferma)->Js.Array.length */

  /* selectedByKarmi > selectedByFerma ? FilmType.Ferma : FilmType.Karmi */
  /* } */

  switch state {
  | LoginEmailNotFoundError =>
    React.string(
      "Could not log you in, make sure you are using the same browser/session as when you requested the email",
    )
  | InvalidLoginLinkError =>
    React.string(
      "The link is invalid, please try checking your inbox or try the login button again",
    )
  | Error => React.string("Something went wrong!! :(")
  | Onboarding(user) => <Onboarding user doneHandler=handleOnboardingDone />
  | LoadingFilms => <Spinner />
  | NotLoggedin => <Login />
  | LoadedFilms(films, seenFilms) =>
    <MaxWidthWrapper>
      <Header />
      <SearchField addFilmHandler />
      <h3 className=listTitle> {React.string("Not seen")} </h3>
      <FilmList films selected="" markFilmAsSeen />
      <h3> {React.string("Seen")} </h3>
      <SeenFilmList films=seenFilms />
    </MaxWidthWrapper>
  }
}
