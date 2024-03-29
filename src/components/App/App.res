@val external window: 'a = "window"

type state =
  | Onboarding(FirebaseAdapter.optionalFirebaseUser)
  | Error
  | InvalidLoginLinkError
  | LoginEmailNotFoundError
  | NotLoggedin
  | IsLoggedIn(FilmList.t, FilmList.t)

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
let isUsersTurn = (seenFilms: FilmList.t, user) => {
  open FirebaseAdapter
  switch (user, seenFilms) {
  | (_, Loading) => None
  | (SomeUser(user), Loaded(loadedSeenFilms)) => {
      let userId = Firebase_Auth.User.uid(user)
      let nrOfSeen = Belt.Array.reduce(loadedSeenFilms, 0, (acc, film) => {
        if film.creatorId === userId {
          acc + 1
        } else {
          acc
        }
      })
      Some(nrOfSeen < Belt.Array.size(loadedSeenFilms) - nrOfSeen)
    }
  | _ => raise(Error)
  }
}

@react.component
let make = () => {
  let urlParts = RescriptReactRouter.useUrl()
  let firebaseUser = FirebaseAdapter.useUser()
  let (state, setState) = React.useState(() => {
    switch (urlParts.path, LocalStorage.getUserId()) {
    | (list{}, Some(_)) => IsLoggedIn(Loading, Loading)
    | (list{"invitePartner"}, _) => Onboarding(firebaseUser)
    | _ => NotLoggedin
    }
  })
  //let (filmRandomlySelected, randomlySelectFilm) = React.useState(() => "")

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
      setState(_ => IsLoggedIn(Loaded(unseen), Loaded(seen)))
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

  React.useEffect2(() => {
    switch (urlParts.path, firebaseUser) {
    | (list{}, SomeUser(user)) => loadAndSetFilms(user)->ignore
    | (list{"invitePartner"}, SomeUser(_)) => setState(_ => Onboarding(firebaseUser))
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
        | IsLoggedIn(Loaded(films), seenFilms) => {
            let creatorName =
              LocalStorage.getUserDisplayName()->Belt.Option.getWithDefault("name not set")
            let film = convertToFilm(~creatorName, ~creatorIsCurrentUser=true, ~firebaseFilm)
            let alreadyInList = films->Js.Array2.map(f => f.id)->Js.Array2.includes(film.id)

            if alreadyInList {
              Js.Console.error("Item already in list")
            } else {
              setState(_ => {
                let newUnseen = Js.Array.concat(films, [film])
                IsLoggedIn(Loaded(newUnseen), seenFilms)
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
      | IsLoggedIn(Loaded(films), Loaded(seenFilms)) =>
        let newUnseen = Js.Array2.filter(films, f => f.title !== film.title)
        let newSeenFilms = Js.Array.concat(seenFilms, [film])
        IsLoggedIn(Loaded(newUnseen), Loaded(newSeenFilms))
      | _ => raise(Error)
      }
    })
    film->FirebaseAdapter.convertFromFilm->FirebaseAdapter.setFilmAsSeen->ignore
  }

  let markFilmAsNotSeen = (film: FilmType.film) => {
    setState(pastState => {
      switch pastState {
      | IsLoggedIn(Loaded(films), Loaded(seenFilms)) =>
        let newSeenFilms = Js.Array2.filter(seenFilms, f => f.title !== film.title)
        let newUnseen = Js.Array.concat([film], films)
        IsLoggedIn(Loaded(newUnseen), Loaded(newSeenFilms))
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
  | NotLoggedin => <NotLoggedinPage />
  | IsLoggedIn(films, seenFilms) =>
    <MaxWidthWrapper>
      <Header isLoggedIn=true isUsersTurnOpt={isUsersTurn(seenFilms, firebaseUser)} />
      <Search onItemSelect=addFilmHandler />
      <FilmList initAsOpen=true header="Not seen" films selected="" onItemSelect=markFilmAsSeen />
      <FilmList initAsOpen=false header="Seen" films=seenFilms onItemSelect=markFilmAsNotSeen />
    </MaxWidthWrapper>
  }
}
