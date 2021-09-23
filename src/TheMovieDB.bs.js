'use strict';

var Curry = require("rescript/lib/js/curry.js");
var Js_dict = require("rescript/lib/js/js_dict.js");
var Js_json = require("rescript/lib/js/js_json.js");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");

var api_key = "6457e32b10837b9f9a7bbdf1e6aa0aa0";

var base_uri = "https://api.themoviedb.org/3/";

function trimQuotes(str) {
  return str.replace("\"", "").replace("\"", "");
}

function search(str, callback) {
  return fetch("https://api.themoviedb.org/3/search/movie?api_key=6457e32b10837b9f9a7bbdf1e6aa0aa0&query=" + str).then(function (prim) {
                return prim.json();
              }).then(function (res) {
              var decodedOptionArray = Belt_Option.flatMap(Js_json.decodeObject(res), (function (results) {
                      return Belt_Option.flatMap(Js_dict.get(results, "results"), Js_json.decodeArray);
                    }));
              if (decodedOptionArray !== undefined) {
                if (decodedOptionArray.length !== 0) {
                  return Promise.resolve(Curry._1(callback, /* Results */{
                                  _0: decodedOptionArray.map(Js_json.decodeObject).map(function (decodedObject) {
                                            return Belt_Option.map(decodedObject, (function (filmObj) {
                                                          return {
                                                                  title: Belt_Option.map(Belt_Option.map(Js_dict.get(filmObj, "title"), (function (prim) {
                                                                              return JSON.stringify(prim);
                                                                            })), trimQuotes),
                                                                  year: Belt_Option.flatMap(Belt_Option.map(Belt_Option.map(Js_dict.get(filmObj, "release_date"), (function (prim) {
                                                                                  return JSON.stringify(prim);
                                                                                })), trimQuotes), (function (date) {
                                                                          return Belt_Array.get(date.split("-"), 0);
                                                                        })),
                                                                  category: Belt_Option.map(Js_dict.get(filmObj, "title"), (function (prim) {
                                                                          return JSON.stringify(prim);
                                                                        }))
                                                                };
                                                        }));
                                          }).filter(Belt_Option.isSome).map(Belt_Option.getExn)
                                }));
                } else {
                  Curry._1(callback, /* NoResultsFound */1);
                  return Promise.resolve(undefined);
                }
              } else {
                return Promise.resolve(undefined);
              }
            });
}

var TheMovieDBAdapter = {
  search: search
};

exports.api_key = api_key;
exports.base_uri = base_uri;
exports.trimQuotes = trimQuotes;
exports.TheMovieDBAdapter = TheMovieDBAdapter;
/* No side effect */
