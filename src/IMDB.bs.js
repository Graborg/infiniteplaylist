'use strict';

var Curry = require("rescript/lib/js/curry.js");
var Fetch = require("bs-fetch/src/Fetch.bs.js");
var Js_dict = require("rescript/lib/js/js_dict.js");
var Js_json = require("rescript/lib/js/js_json.js");
var Caml_obj = require("rescript/lib/js/caml_obj.js");
var Js_option = require("rescript/lib/js/js_option.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var Caml_option = require("rescript/lib/js/caml_option.js");

function search(str, setState) {
  fetch("https://imdb8.p.rapidapi.com/auto-complete?q=" + str, Fetch.RequestInit.make(undefined, {
                  "x-rapidapi-key": "2df82a1ee9msha7bfe50dac1853fp17ec3ejsn869e578089bb",
                  "x-rapidapi-host": "imdb8.p.rapidapi.com"
                }, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined)).then(function (prim) {
          return prim.json();
        }).then(function (res) {
        var decoded = Js_json.decodeObject(res);
        if (decoded !== undefined) {
          var topResults = Belt_Option.getWithDefault(Js_json.decodeArray(Belt_Option.getWithDefault(Js_dict.get(Caml_option.valFromOption(decoded), "d"), [])), []).map(function (film) {
                    return Belt_Option.flatMap(Js_json.decodeObject(film), (function (filmObj) {
                                  return {
                                          title: Js_dict.get(filmObj, "l"),
                                          year: Js_dict.get(filmObj, "y"),
                                          category: Js_dict.get(filmObj, "q")
                                        };
                                }));
                  }).filter(Js_option.isSome).filter(function (film) {
                return Belt_Option.getWithDefault(Belt_Option.map(film, (function (f) {
                                  return Caml_obj.caml_equal(Belt_Option.getWithDefault(f.category, "none"), "feature");
                                })), false);
              });
          console.log(topResults);
          Curry._1(setState, (function (param) {
                  return [
                          param[0],
                          topResults,
                          param[2]
                        ];
                }));
        } else {
          throw {
                RE_EXN_ID: "Match_failure",
                _1: [
                  "IMDB.res",
                  22,
                  6
                ],
                Error: new Error()
              };
        }
        return Promise.resolve("");
      });
  
}

var IMDBService = {
  search: search
};

exports.IMDBService = IMDBService;
/* No side effect */
