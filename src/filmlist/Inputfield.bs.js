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
                false
              ];
      });
  var setText = match[1];
  var match$1 = match[0];
  var searchDebounced = ReactDebounce.useDebounced(undefined, (function (text) {
          return IMDB$RescriptProjectTemplate.IMDBService.search(text, setText);
        }));
  return React.createElement("div", undefined, React.createElement("input", {
                  value: match$1[0],
                  onChange: (function (e) {
                      var currentValue = e.target.value;
                      Curry._1(setText, (function (param) {
                              return [
                                      currentValue,
                                      param[1],
                                      true
                                    ];
                            }));
                      return Curry._1(searchDebounced, currentValue);
                    })
                }), React.createElement("ul", {
                  id: "suggested-films"
                }, match$1[2] ? Belt_Array.map(Belt_Array.slice(match$1[1], 0, 5), (function (film) {
                          return Belt_Option.mapWithDefault(film, "", (function (someFilm) {
                                        return React.createElement("li", {
                                                    onClick: (function (item) {
                                                        var currentValue = item.target.innerText;
                                                        return Curry._1(setText, (function (param) {
                                                                      return [
                                                                              currentValue,
                                                                              param[1],
                                                                              false
                                                                            ];
                                                                    }));
                                                      })
                                                  }, React.createElement("p", undefined, trimQuotes(JSON.stringify(someFilm))));
                                      }));
                        })) : ""));
}

var make = Inputfield;

exports.trimQuotes = trimQuotes;
exports.make = make;
/* react Not a pure module */
