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

exception Error
let isUsersTurn = (seenFilms: array<FilmType.film>, user) => {
  open FirebaseAdapter
  switch user {
  | SomeUser(user) => {
      let userId = Firebase_Auth.User.uid(user)
      let nrOfSeen = Belt.Array.reduce(seenFilms, 0, (acc, film) => {
        if film.creatorId === userId {
          acc + 1
        } else {
          acc
        }
      })
      nrOfSeen < Belt.Array.size(seenFilms) - nrOfSeen
    }
  | _ => raise(Error)
  }
}

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
  let loadAndSetFilms = (user: Firebase.Auth.User.t) => {
    let (userColor, partnerColor) = switch (
      LocalStorage.getUserDisplayName(),
      LocalStorage.getPartnerDisplayName(),
    ) {
    | (Some(name), Some(partnerName)) =>
      if Js.String2.localeCompare(name, partnerName) > 0.0 {
        ("#f582ae", "#8bd3dd")
      } else {
        ("#8bd3dd", "#f582ae")
      }
    | (_, _) => ("#000000", "")
    }

    Emotion.injectGlobal(
      `
      html {
        --color-user: ${userColor};
        --color-partner: ${partnerColor};
      }
    `,
    )

    FirebaseAdapter.getFilmLists(user)->Promise.thenResolve((movieList: array<FilmType.film>) => {
      open Js.Array2

      let unseen = movieList->filter(film => !film.seen)
      let seen = movieList->filter(film => film.seen)
      setState(_ => LoadedFilms(unseen, seen))
    })
  }

  let handleLoginCallback = () => {
    open FirebaseAdapter
    let url: string = window["location"]["href"]
    handleAuthCallback(~link=url)->Promise.catch(error => {
      let _ = switch error {
      | InvalidLink => RescriptReactRouter.push("/invalidEmailLinkError")
      | EmailNotFound => RescriptReactRouter.push("/emailNotFoundError")
      | _ => RescriptReactRouter.replace("/error")
      }
      Promise.resolve()
    })
  }

  let handleOnboardingDone = user => loadAndSetFilms(user)

  let userIsSet = user =>
    if Belt.Option.isSome(LocalStorage.getUserDisplayName()) {
      Promise.resolve(true)
    } else {
      user
      ->Firebase.Auth.User.email
      ->FirebaseAdapter.getUserName
      ->Promise.thenResolve(userName =>
        switch userName {
        | Some(name) => {
            LocalStorage.setUserDisplayName(name)
            true
          }
        | _ => false
        }
      )
    }

  let urlParts = RescriptReactRouter.useUrl()
  React.useEffect2(() => {
    switch (urlParts.path, firebaseUser) {
    | (list{}, SomeUser(user)) => loadAndSetFilms(user)->ignore
    | (list{"invitePartner"}, SomeUser(user)) => setState(_ => Onboarding(user))
    | (list{"loginCallback"}, SomeUser(user)) =>
      userIsSet(user)
      ->Promise.thenResolve(displayNameIsSet => {
        if displayNameIsSet {
          RescriptReactRouter.push("/")
        } else {
          RescriptReactRouter.push("/invitePartner")
        }
      })
      ->Promise.catch(_ => RescriptReactRouter.push("/invitePartner")->Promise.resolve)
      ->ignore
    | (list{"loginCallback"}, NoUser) => handleLoginCallback()->ignore
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
            let creatorName =
              LocalStorage.getUserDisplayName()->Belt.Option.getWithDefault("name not set")
            let film = convertToFilm(~creatorName, ~creatorIsCurrentUser=true, ~firebaseFilm)
            let alreadyInList = films->Js.Array2.map(f => f.id)->Js.Array2.includes(film.id)

            if alreadyInList {
              Js.Console.error("Item already in list")
            } else {
              setState(_ => {
                let newUnseen = Js.Array.concat(films, [film])
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
    setState(pastState => {
      switch pastState {
      | LoadedFilms(films, seenFilms) =>
        let newUnseen = Js.Array2.filter(films, f => f.title !== film.title)
        let newSeenFilms = Js.Array.concat(seenFilms, [film])
        LoadedFilms(newUnseen, newSeenFilms)
      | _ => pastState
      }
    })
    film->FirebaseAdapter.convertFromFilm->FirebaseAdapter.setFilmAsSeen->ignore
  }

  let markFilmAsNotSeen = (film: FilmType.film) => {
    setState(pastState => {
      switch pastState {
      | LoadedFilms(films, seenFilms) =>
        let newSeenFilms = Js.Array2.filter(seenFilms, f => f.title !== film.title)
        let newUnseen = Js.Array.concat([film], films)
        LoadedFilms(newUnseen, newSeenFilms)
      | _ => raise(Error)
      }
    })
    film->FirebaseAdapter.convertFromFilm->FirebaseAdapter.setFilmAsUnSeen->ignore
  }

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
  | LoadingFilms => <> <Search /> <Spinner /> </>
  | NotLoggedin => <NotLoggedinPage />
  | LoadedFilms(films, seenFilms) =>
    <div>
      /* <Header isLoggedIn=true isUsersTurnOpt={isUsersTurn(seenFilms, firebaseUser)} /> */
      <Search onItemSelect=addFilmHandler noAnimation=true />
      <FilmList initAsOpen=true header="Not seen" films selected="" onItemSelect=markFilmAsSeen />
      <FilmList initAsOpen=false header="Seen" films=seenFilms onItemSelect=markFilmAsNotSeen />
    </div>
  }
}
