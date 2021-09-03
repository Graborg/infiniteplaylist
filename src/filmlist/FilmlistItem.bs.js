'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");

function creatorToString(creator) {
  if (creator) {
    return "🐄 " + "Ferma" + " 🐄";
  } else {
    return "🐘 " + "Karmi" + " 🐘";
  }
}

function FilmlistItem(Props) {
  var film = Props.film;
  var lastElement = Props.lastElement;
  var selected = Props.selected;
  var click = Props.click;
  var match = React.useState(function () {
        return false;
      });
  var setMouseOver = match[1];
  React.useState(function () {
        return false;
      });
  return React.createElement("div", {
              key: String(film.id),
              className: "film-item inputGroup",
              style: {
                borderBottom: lastElement ? "" : "1px #cecece solid",
                color: film.creator === /* Ferma */1 ? "#476098" : "#8b9862",
                display: "flex",
                margin: "0 10px",
                minHeight: "56px",
                padding: "21px 5px 13px",
                justifyContent: "space-between",
                boxSizing: "border-box"
              },
              onClick: (function (param) {
                  return Curry._1(click, film);
                }),
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
                }, creatorToString(film.creator)));
}

var make = FilmlistItem;

exports.creatorToString = creatorToString;
exports.make = make;
/* react Not a pure module */
