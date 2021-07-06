'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");
var Caml_option = require("rescript/lib/js/caml_option.js");

function Make(Config) {
  var useLocalStorage = function (param) {
    var key = Config.key;
    var match = React.useState(function () {
          return localStorage.getItem(key);
        });
    var setState = match[1];
    var setValue = function (value) {
      localStorage.setItem(key, Curry._1(Config.toString, value));
      return Curry._1(setState, (function (param) {
                    return localStorage.getItem(key);
                  }));
    };
    return [
            Curry._1(Config.fromString, Caml_option.nullable_to_opt(match[0])),
            setValue
          ];
  };
  return {
          useLocalStorage: useLocalStorage
        };
}

exports.Make = Make;
/* react Not a pure module */
