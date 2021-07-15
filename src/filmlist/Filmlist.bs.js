'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Dom_storage = require("rescript/lib/js/dom_storage.js");
var RescriptReactRouter = require("@rescript/react/src/RescriptReactRouter.bs.js");
var Title$RescriptProjectTemplate = require("./Title.bs.js");
var Todoist$RescriptProjectTemplate = require("../Todoist.bs.js");
var RandomBtn$RescriptProjectTemplate = require("./RandomBtn.bs.js");
var FilmlistItem$RescriptProjectTemplate = require("./FilmlistItem.bs.js");

function selectFilm(setState, filmId) {
  return Curry._1(setState, (function (prevState) {
                if (typeof prevState === "number") {
                  throw {
                        RE_EXN_ID: "Match_failure",
                        _1: [
                          "Filmlist.res",
                          19,
                          4
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
}

function Filmlist(Props) {
  var match = React.useState(function () {
        return /* LoadingFilms */0;
      });
  var setState = match[1];
  var state = match[0];
  var selectFilmWithSetState = function (param) {
    return selectFilm(setState, param);
  };
  var url = RescriptReactRouter.useUrl(undefined, undefined);
  React.useEffect((function () {
          var token = Dom_storage.getItem(Todoist$RescriptProjectTemplate.localStorageNamespace, localStorage);
          if (token !== undefined) {
            Todoist$RescriptProjectTemplate.Todoist.getFilms(token).then(function (films) {
                  Curry._1(setState, (function (_prevState) {
                          return /* LoadedFilms */{
                                  _0: films,
                                  _1: "",
                                  _2: []
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
    return Curry._1(setState, (function (param) {
                  if (typeof param === "number") {
                    throw {
                          RE_EXN_ID: "Match_failure",
                          _1: [
                            "Filmlist.res",
                            57,
                            13
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
  };
  var unDooSeenFilm = function (film) {
    return Curry._1(setState, (function (param) {
                  if (typeof param === "number") {
                    throw {
                          RE_EXN_ID: "Match_failure",
                          _1: [
                            "Filmlist.res",
                            63,
                            13
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
                        }))), React.createElement(RandomBtn$RescriptProjectTemplate.make, {
                    films: films,
                    selectFilmWithSetState: selectFilmWithSetState
                  }), seenFilms.length > 0 ? React.createElement("div", undefined, React.createElement("p", {
                          style: {
                            margin: "10px 0 10px 10px"
                          }
                        }, "Seen films"), React.createElement("div", {
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

exports.selectFilm = selectFilm;
exports.make = make;
/* react Not a pure module */
