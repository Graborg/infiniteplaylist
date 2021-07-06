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
                        _1: filmId
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
                                  _1: ""
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
                                    _1: ""
                                  };
                          }));
                    return Promise.resolve(undefined);
                  });
            }
          }
          
        }), []);
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
    var selected = state._1;
    var films = state._0;
    return React.createElement("div", {
                style: {
                  width: "100%"
                }
              }, React.createElement(Title$RescriptProjectTemplate.make, {}), React.createElement("div", {
                    className: "film-list"
                  }, Belt_Array.mapWithIndex(films, (function (id, film) {
                          var lastElement = id === (films.length - 1 | 0);
                          var selected$1 = selected === film.name;
                          return React.createElement(FilmlistItem$RescriptProjectTemplate.make, {
                                      film: film,
                                      id: id,
                                      lastElement: lastElement,
                                      selected: selected$1
                                    });
                        }))), React.createElement(RandomBtn$RescriptProjectTemplate.make, {
                    films: films,
                    selectFilmWithSetState: selectFilmWithSetState
                  }));
  }
}

var make = Filmlist;

exports.selectFilm = selectFilm;
exports.make = make;
/* react Not a pure module */
