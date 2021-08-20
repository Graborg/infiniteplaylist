'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Dom_storage = require("rescript/lib/js/dom_storage.js");
var RescriptReactRouter = require("@rescript/react/src/RescriptReactRouter.bs.js");
var Title$RescriptProjectTemplate = require("./Title.bs.js");
var Todoist$RescriptProjectTemplate = require("../Todoist.bs.js");
var RandomBtn$RescriptProjectTemplate = require("./RandomBtn.bs.js");
var Inputfield$RescriptProjectTemplate = require("./Inputfield.bs.js");
var FilmlistItem$RescriptProjectTemplate = require("./FilmlistItem.bs.js");

function Filmlist(Props) {
  var match = React.useState(function () {
        return /* LoadingFilms */0;
      });
  var setState = match[1];
  var state = match[0];
  var doSelectFilm = function (filmId) {
    return Curry._1(setState, (function (prevState) {
                  if (typeof prevState === "number") {
                    throw {
                          RE_EXN_ID: "Match_failure",
                          _1: [
                            "Filmlist.res",
                            23,
                            6
                          ],
                          Error: new Error()
                        };
                  }
                  return /* LoadedFilms */{
                          _0: prevState._0,
                          _1: filmId,
                          _2: prevState._2
                        };
                }));
  };
  var url = RescriptReactRouter.useUrl(undefined, undefined);
  React.useEffect((function () {
          var token = Dom_storage.getItem(Todoist$RescriptProjectTemplate.localStorageNamespace, localStorage);
          if (token !== undefined) {
            Todoist$RescriptProjectTemplate.Todoist.getFilms(token).then(function (films) {
                  var unseen = films.filter(function (film) {
                        return !film.seen;
                      });
                  var seen = films.filter(function (film) {
                        return film.seen;
                      });
                  Curry._1(setState, (function (_prevState) {
                          return /* LoadedFilms */{
                                  _0: unseen,
                                  _1: "",
                                  _2: seen
                                };
                        }));
                  return Promise.resolve(undefined);
                });
          } else {
            var search = url.search;
            if (search === "") {
              Curry._1(setState, (function (_preState) {
                      return /* NotLoggedin */2;
                    }));
            } else {
              Todoist$RescriptProjectTemplate.Todoist.setToken(Todoist$RescriptProjectTemplate.Todoist.searchStringToCode(search)).then(Todoist$RescriptProjectTemplate.Todoist.getFilms).then(function (films) {
                    Curry._1(setState, (function (_preState) {
                            return /* LoadedFilms */{
                                    _0: films,
                                    _1: "",
                                    _2: []
                                  };
                          }));
                    return Promise.resolve(undefined);
                  });
            }
          }
          
        }), []);
  var seenFilm = function (film) {
    Todoist$RescriptProjectTemplate.Todoist.setFilmAsSeen(film);
    setTimeout((function (param) {
            return Curry._1(setState, (function (param) {
                          if (typeof param === "number") {
                            throw {
                                  RE_EXN_ID: "Match_failure",
                                  _1: [
                                    "Filmlist.res",
                                    59,
                                    15
                                  ],
                                  Error: new Error()
                                };
                          }
                          var newUnseen = param._0.filter(function (f) {
                                return f.name !== film.name;
                              });
                          var newSeenFilms = [film].concat(param._2);
                          return /* LoadedFilms */{
                                  _0: newUnseen,
                                  _1: param._1,
                                  _2: newSeenFilms
                                };
                        }));
          }), 500);
    
  };
  var unDooSeenFilm = function (film) {
    Todoist$RescriptProjectTemplate.Todoist.setFilmAsUnseen(film);
    setTimeout((function (param) {
            return Curry._1(setState, (function (param) {
                          if (typeof param === "number") {
                            throw {
                                  RE_EXN_ID: "Match_failure",
                                  _1: [
                                    "Filmlist.res",
                                    70,
                                    15
                                  ],
                                  Error: new Error()
                                };
                          }
                          var newSeenFilms = param._2.filter(function (f) {
                                return f.name !== film.name;
                              });
                          var newUnseen = [film].concat(param._0);
                          return /* LoadedFilms */{
                                  _0: newUnseen,
                                  _1: param._1,
                                  _2: newSeenFilms
                                };
                        }));
          }), 500);
    
  };
  var getNextElector = function (seenFilms) {
    var selectedByKarmi = seenFilms.filter(function (film) {
          return film.creator === /* Karmi */0;
        }).length;
    var selectedByFerma = seenFilms.filter(function (film) {
          return film.creator === /* Ferma */1;
        }).length;
    if (selectedByKarmi > selectedByFerma) {
      return /* Ferma */1;
    } else {
      return /* Karmi */0;
    }
  };
  var addFilmToList = function (filmName) {
    return Todoist$RescriptProjectTemplate.Todoist.addFilm(filmName).then(function (param) {
                var film_id = param[1];
                var film_creator = param[0];
                var film = {
                  seen: false,
                  id: film_id,
                  name: filmName,
                  creator: film_creator
                };
                Curry._1(setState, (function (param) {
                        if (typeof param === "number") {
                          throw {
                                RE_EXN_ID: "Match_failure",
                                _1: [
                                  "Filmlist.res",
                                  95,
                                  15
                                ],
                                Error: new Error()
                              };
                        }
                        var newUnseen = param._0.concat([film]);
                        return /* LoadedFilms */{
                                _0: newUnseen,
                                _1: param._1,
                                _2: param._2
                              };
                      }));
                return Promise.resolve(undefined);
              });
  };
  if (typeof state === "number") {
    switch (state) {
      case /* LoadingFilms */0 :
          return "Loading...";
      case /* ErrorFetchingFilms */1 :
          return "An error occurred!";
      case /* NotLoggedin */2 :
          return React.createElement("a", {
                      href: Todoist$RescriptProjectTemplate.todoistLoginLink
                    }, "Log into Todoist");
      
    }
  } else {
    var seenFilms = state._2;
    var selected = state._1;
    var films = state._0;
    return React.createElement("div", {
                key: "filmlist",
                style: {
                  width: "100%"
                }
              }, React.createElement(Title$RescriptProjectTemplate.make, {}), React.createElement("div", {
                    className: "film-list"
                  }, Belt_Array.mapWithIndex(films, (function (i, film) {
                          var lastElement = i === (films.length - 1 | 0);
                          var selected$1 = selected === film.name;
                          return React.createElement(FilmlistItem$RescriptProjectTemplate.make, {
                                      film: film,
                                      lastElement: lastElement,
                                      selected: selected$1,
                                      click: seenFilm,
                                      key: String(film.id) + "h"
                                    });
                        }))), React.createElement("div", {
                    id: "underfilmlist-items"
                  }, React.createElement(Inputfield$RescriptProjectTemplate.make, {
                        addFilmToList: addFilmToList
                      }), React.createElement(RandomBtn$RescriptProjectTemplate.make, {
                        films: films,
                        doSelectFilm: doSelectFilm,
                        nextElector: getNextElector(seenFilms)
                      })), seenFilms.length > 0 ? React.createElement("div", undefined, React.createElement("p", {
                          style: {
                            margin: "10px 0 10px 10px"
                          }
                        }, "Peliculas vistas"), React.createElement("div", {
                          className: "film-list"
                        }, Belt_Array.mapWithIndex(seenFilms, (function (i, film) {
                                var lastElement = i === (films.length - 1 | 0);
                                var selected$1 = selected === film.name;
                                return React.createElement(FilmlistItem$RescriptProjectTemplate.make, {
                                            film: film,
                                            lastElement: lastElement,
                                            selected: selected$1,
                                            click: unDooSeenFilm,
                                            key: String(film.id) + "h"
                                          });
                              })))) : React.createElement("div", undefined));
  }
}

var make = Filmlist;

exports.make = make;
/* react Not a pure module */
