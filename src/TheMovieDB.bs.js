'use strict';

var Curry = require("rescript/lib/js/curry.js");
var Js_dict = require("rescript/lib/js/js_dict.js");
var Js_json = require("rescript/lib/js/js_json.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var Caml_option = require("rescript/lib/js/caml_option.js");

var api_key = "6457e32b10837b9f9a7bbdf1e6aa0aa0";

var base_uri = "https://api.themoviedb.org/3/";

function trimQuotes(str) {
  return str.replace("\"", "").replace("\"", "");
}

function search(str, callback) {
  return fetch("https://api.themoviedb.org/3/search/movie?api_key=6457e32b10837b9f9a7bbdf1e6aa0aa0&query=" + str).then(function (prim) {
                return prim.json();
              }).then(function (res) {
              var results = Js_json.decodeObject(res);
              return Promise.resolve(results !== undefined ? Belt_Option.map(Belt_Option.map(Belt_Option.map(Belt_Option.flatMap(Js_dict.get(Caml_option.valFromOption(results), "results"), Js_json.decodeArray), (function (resArray) {
                                          return resArray.map(function (film) {
                                                      return Belt_Option.map(Js_json.decodeObject(film), (function (filmObj) {
                                                                    return {
                                                                            title: Belt_Option.map(Belt_Option.map(Js_dict.get(filmObj, "title"), (function (prim) {
                                                                                        return JSON.stringify(prim);
                                                                                      })), trimQuotes),
                                                                            year: Belt_Option.map(Belt_Option.map(Js_dict.get(filmObj, "release_date"), (function (e) {
                                                                                        return JSON.stringify(e);
                                                                                      })), trimQuotes),
                                                                            category: Js_dict.get(filmObj, "title")
                                                                          };
                                                                  }));
                                                    });
                                        })), (function (mappedArray) {
                                      return mappedArray.filter(Belt_Option.isSome).map(Belt_Option.getExn);
                                    })), Curry.__1(callback)) : undefined);
            });
}

var TheMovieDBAdapter = {
  search: search
};

var timeout = 5000;

exports.api_key = api_key;
exports.base_uri = base_uri;
exports.timeout = timeout;
exports.trimQuotes = trimQuotes;
exports.TheMovieDBAdapter = TheMovieDBAdapter;
/* No side effect */
