'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");

function creatorToString(creator) {
  if (creator) {
    return "Ferma";
  } else {
    return "karmi";
  }
}

function FilmlistItem(Props) {
  var film = Props.film;
  var id = Props.id;
  var lastElement = Props.lastElement;
  var selected = Props.selected;
  var match = React.useState(function () {
        return false;
      });
  var setMouseOver = match[1];
  var match$1 = React.useState(function () {
        return false;
      });
  var setCheck = match$1[1];
  var isChecked = match$1[0];
  if (match[0] || isChecked) {
    return React.createElement("div", {
                key: String(id),
                className: "film-item inputGroup",
                style: {
                  margin: "0 10px",
                  padding: "0"
                },
                onMouseEnter: (function (param) {
                    return Curry._1(setMouseOver, (function (param) {
                                  return true;
                                }));
                  }),
                onMouseLeave: (function (param) {
                    return Curry._1(setMouseOver, (function (param) {
                                  return false;
                                }));
                  })
              }, React.createElement("input", {
                    id: String(id) + "input",
                    checked: isChecked,
                    type: "checkbox",
                    onChange: (function (param) {
                        console.log("Hej");
                        return Curry._1(setCheck, (function (prev) {
                                      return !prev;
                                    }));
                      })
                  }), React.createElement("label", {
                    style: {
                      backgroundColor: "white",
                      borderBottom: lastElement ? "" : "1px #cecece solid",
                      display: "flex",
                      minHeight: "56px",
                      padding: "21px 0 13px",
                      paddingLeft: "20px",
                      justifyContent: "space-between",
                      boxSizing: "border-box"
                    },
                    htmlFor: String(id) + "input"
                  }, film.name));
  } else {
    return React.createElement("div", {
                key: String(id),
                className: "film-item inputGroup",
                style: {
                  borderBottom: lastElement ? "" : "1px #cecece solid",
                  display: "flex",
                  margin: "0 10px",
                  minHeight: "56px",
                  padding: "21px 5px 13px",
                  justifyContent: "space-between",
                  boxSizing: "border-box"
                },
                onMouseEnter: (function (param) {
                    return Curry._1(setMouseOver, (function (param) {
                                  return true;
                                }));
                  }),
                onMouseLeave: (function (param) {
                    return Curry._1(setMouseOver, (function (param) {
                                  return false;
                                }));
                  })
              }, React.createElement("p", undefined, selected ? "🤠" + " " : "", film.name, selected ? " " + "🤠" : ""), React.createElement("p", {
                    style: {
                      border: "black 5px"
                    }
                  }, film.creator ? "Ferma" : "karmi"));
  }
}

var make = FilmlistItem;

exports.creatorToString = creatorToString;
exports.make = make;
/* react Not a pure module */
