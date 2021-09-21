'use strict';

var Curry = require("rescript/lib/js/curry.js");
var Js_dict = require("rescript/lib/js/js_dict.js");
var Js_json = require("rescript/lib/js/js_json.js");
var Js_option = require("rescript/lib/js/js_option.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var Caml_option = require("rescript/lib/js/caml_option.js");

var api_key = "6457e32b10837b9f9a7bbdf1e6aa0aa0";

var base_uri = "https://api.themoviedb.org/3/";

function search(str, callback) {
  fetch("https://api.themoviedb.org/3/search/movie?api_key=6457e32b10837b9f9a7bbdf1e6aa0aa0&query=" + str).then(function (prim) {
          return prim.json();
        }).then(function (res) {
        var decoded = Js_json.decodeObject(res);
        if (decoded !== undefined) {
          Curry._1(callback, Belt_Option.getWithDefault(Js_json.decodeArray(Belt_Option.getWithDefault(Js_dict.get(Caml_option.valFromOption(decoded), "results"), [])), []).map(function (film) {
                      return Belt_Option.flatMap(Js_json.decodeObject(film), (function (filmObj) {
                                    return {
                                            title: Js_dict.get(filmObj, "title"),
                                            year: Js_dict.get(filmObj, "release_date"),
                                            category: Js_dict.get(filmObj, "title")
                                          };
                                  }));
                    }).filter(Js_option.isSome));
        } else {
          throw {
                RE_EXN_ID: "Match_failure",
                _1: [
                  "TheMovieDB.res",
                  12,
                  6
                ],
                Error: new Error()
              };
        }
        return Promise.resolve("");
      });
  
}

var TheMovieDBAdapter = {
  search: search
};

var timeout = 5000;

exports.api_key = api_key;
exports.base_uri = base_uri;
exports.timeout = timeout;
exports.TheMovieDBAdapter = TheMovieDBAdapter;
/* No side effect */
