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
  var setCheck = match[1];
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
                textDecoration: match[0] ? "line-through" : "",
                justifyContent: "space-between",
                boxSizing: "border-box"
              },
              onClick: (function (param) {
                  Curry._1(setCheck, (function (prevState) {
                          return !prevState;
                        }));
                  return Curry._1(click, film);
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
