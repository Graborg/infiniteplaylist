'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var ReactDebounce = require("rescript-debounce-react/src/ReactDebounce.bs.js");
var IMDB$RescriptProjectTemplate = require("../IMDB.bs.js");

function trimQuotes(str) {
  return str.replace("\"", "").replace("\"", "");
}

function Inputfield(Props) {
  var match = React.useState(function () {
        return [
                "",
                [],
                false,
                -1
              ];
      });
  var setText = match[1];
  var match$1 = match[0];
  var suggestedFilms = match$1[1];
  var searchDebounced = ReactDebounce.useDebounced(undefined, (function (text) {
          return IMDB$RescriptProjectTemplate.IMDBService.search(text, setText);
        }));
  return React.createElement("div", undefined, React.createElement("input", {
                  value: match$1[0],
                  onKeyDown: (function (e) {
                      var keyCode = e.keyCode;
                      console.log(keyCode);
                      if (keyCode === 13) {
                        return Curry._1(setText, (function (param) {
                                      var activeOptionState = param[3];
                                      return [
                                              trimQuotes(Belt_Option.getWithDefault(Belt_Option.map(suggestedFilms[activeOptionState], (function (e) {
                                                              var h = JSON.stringify(Belt_Option.getWithDefault(e.title, ""));
                                                              console.log(h);
                                                              return h;
                                                            })), "")),
                                              param[1],
                                              false,
                                              activeOptionState
                                            ];
                                    }));
                      } else if (keyCode === 38) {
                        return Curry._1(setText, (function (param) {
                                      var activeOptionState = param[3];
                                      return [
                                              param[0],
                                              param[1],
                                              param[2],
                                              activeOptionState === 0 ? 0 : activeOptionState - 1 | 0
                                            ];
                                    }));
                      } else if (keyCode === 40) {
                        return Curry._1(setText, (function (param) {
                                      var activeOptionState = param[3];
                                      var suggestedFilmsState = param[1];
                                      return [
                                              param[0],
                                              suggestedFilmsState,
                                              param[2],
                                              activeOptionState === (suggestedFilmsState.length - 1 | 0) ? activeOptionState : activeOptionState + 1 | 0
                                            ];
                                    }));
                      } else {
                        return ;
                      }
                    }),
                  onChange: (function (e) {
                      var currentValue = e.target.value;
                      Curry._1(setText, (function (param) {
                              return [
                                      currentValue,
                                      param[1],
                                      true,
                                      -1
                                    ];
                            }));
                      return Curry._1(searchDebounced, currentValue);
                    })
                }), React.createElement("ul", {
                  id: "suggested-films"
                }, match$1[2] ? Belt_Array.map(Belt_Array.slice(suggestedFilms, 0, 5), (function (film) {
                          return Belt_Option.mapWithDefault(film, "", (function (someFilm) {
                                        var title = trimQuotes(JSON.stringify(Belt_Option.getWithDefault(someFilm.title, "")));
                                        var year = trimQuotes(JSON.stringify(Belt_Option.getWithDefault(someFilm.year, "")));
                                        return React.createElement("li", {
                                                    onClick: (function (item) {
                                                        var currentValue = item.target.innerText;
                                                        return Curry._1(setText, (function (param) {
                                                                      if (param[3] !== -1) {
                                                                        throw {
                                                                              RE_EXN_ID: "Match_failure",
                                                                              _1: [
                                                                                "Inputfield.res",
                                                                                79,
                                                                                26
                                                                              ],
                                                                              Error: new Error()
                                                                            };
                                                                      }
                                                                      return [
                                                                              currentValue,
                                                                              param[1],
                                                                              false,
                                                                              -1
                                                                            ];
                                                                    }));
                                                      })
                                                  }, React.createElement("p", undefined, title + " (" + year + ")"));
                                      }));
                        })) : ""));
}

var make = Inputfield;

exports.trimQuotes = trimQuotes;
exports.make = make;
/* react Not a pure module */
