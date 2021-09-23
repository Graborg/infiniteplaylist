'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var ReactDebounce = require("rescript-debounce-react/src/ReactDebounce.bs.js");
var TheMovieDB$RescriptProjectTemplate = require("../TheMovieDB.bs.js");

function Inputfield(Props) {
  var addFilmToList = Props.addFilmToList;
  var match = React.useState(function () {
        return true;
      });
  var toggleList = match[1];
  var match$1 = React.useState(function () {
        return [
                "",
                /* NoResultsInit */0,
                -1
              ];
      });
  var setText = match$1[1];
  var match$2 = match$1[0];
  var activeOption = match$2[2];
  var suggestedFilms = match$2[1];
  var searchText = match$2[0];
  var wrapperRef = React.useRef(null);
  React.useEffect((function () {
          var handleClickOutside = function ($$event) {
            var dom = wrapperRef.current;
            if (!(dom == null) && dom.contains($$event.target)) {
              return ;
            }
            return Curry._1(toggleList, (function (param) {
                          return false;
                        }));
          };
          Curry._2(window.addEventListener, "mousedown", handleClickOutside);
          
        }), []);
  var searchDebounced = ReactDebounce.useDebounced(undefined, (function (text) {
          TheMovieDB$RescriptProjectTemplate.TheMovieDBAdapter.search(text, (function (res) {
                  return Curry._1(setText, (function (param) {
                                return [
                                        param[0],
                                        res,
                                        param[2]
                                      ];
                              }));
                }));
          
        }));
  return React.createElement("div", {
              ref: wrapperRef,
              id: "searchbox-wrapper"
            }, React.createElement("ul", {
                  id: "suggested-films"
                }, match[0] ? (
                    typeof suggestedFilms === "number" ? (
                        suggestedFilms !== 0 ? React.createElement("li", undefined, "No results found") : ""
                      ) : Belt_Array.mapWithIndex(Belt_Array.slice(suggestedFilms._0, 0, 5), (function (i, film) {
                              var match = film.title;
                              var match$1 = film.year;
                              return React.createElement("li", {
                                          className: i === activeOption ? "highlight" : "",
                                          onClick: (function (item) {
                                              Curry._1(addFilmToList, item.target.innerText);
                                              return Curry._1(toggleList, (function (param) {
                                                            return false;
                                                          }));
                                            })
                                        }, React.createElement("p", undefined, match !== undefined ? (
                                                match$1 !== undefined ? match + " (" + match$1 + ")" : match
                                              ) : "<error no title>"));
                            }))
                  ) : ""), React.createElement("input", {
                  id: "searchbox",
                  placeholder: "A\xc3\xb1ada pelicula",
                  value: searchText,
                  onKeyDown: (function (e) {
                      var keyCode = e.keyCode;
                      if (keyCode === 13) {
                        Curry._1(addFilmToList, searchText);
                        return Curry._1(toggleList, (function (param) {
                                      return false;
                                    }));
                      } else if (keyCode === 38) {
                        return Curry._1(setText, (function (param) {
                                      var activeOptionState = param[2];
                                      var suggestedFilmsState = param[1];
                                      if (typeof suggestedFilmsState === "number") {
                                        return [
                                                param[0],
                                                suggestedFilmsState,
                                                activeOptionState
                                              ];
                                      }
                                      var filmList = suggestedFilmsState._0;
                                      var optionsLength = filmList.length;
                                      var newActiveOptionState = activeOptionState === optionsLength ? optionsLength : activeOptionState + 1 | 0;
                                      var selectedFromDropdown = Belt_Option.getWithDefault(Belt_Option.flatMap(Belt_Array.get(filmList, newActiveOptionState), (function (filmItem) {
                                                  return filmItem.title;
                                                })), "");
                                      return [
                                              selectedFromDropdown,
                                              suggestedFilmsState,
                                              newActiveOptionState
                                            ];
                                    }));
                      } else if (keyCode === 40) {
                        return Curry._1(setText, (function (param) {
                                      var activeOptionState = param[2];
                                      var suggestedFilmsState = param[1];
                                      if (typeof suggestedFilmsState === "number") {
                                        return [
                                                param[0],
                                                suggestedFilmsState,
                                                activeOptionState
                                              ];
                                      }
                                      var newActiveOptionState = activeOptionState === 0 ? 0 : activeOptionState - 1 | 0;
                                      var selectedFromDropdown = Belt_Option.getWithDefault(Belt_Option.flatMap(Belt_Array.get(suggestedFilmsState._0, newActiveOptionState), (function (filmItem) {
                                                  return filmItem.title;
                                                })), "");
                                      return [
                                              selectedFromDropdown,
                                              suggestedFilmsState,
                                              newActiveOptionState
                                            ];
                                    }));
                      } else {
                        return ;
                      }
                    }),
                  onFocus: (function (e) {
                      return Curry._1(toggleList, (function (param) {
                                    return true;
                                  }));
                    }),
                  onChange: (function (e) {
                      var currentValue = e.target.value;
                      Curry._1(setText, (function (param) {
                              return [
                                      currentValue,
                                      param[1],
                                      -1
                                    ];
                            }));
                      return Curry._1(searchDebounced, currentValue);
                    })
                }), React.createElement("label", {
                  className: "searchbox__label",
                  htmlFor: "searchbox"
                }, "Añada pelicula"));
}

var make = Inputfield;

exports.make = make;
/* react Not a pure module */
