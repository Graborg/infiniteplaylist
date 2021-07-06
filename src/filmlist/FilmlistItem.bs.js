'use strict';

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
  return React.createElement("div", {
              key: String(id),
              style: {
                borderBottom: lastElement ? "" : "1px #cecece solid",
                display: "flex",
                margin: "0 10px",
                minHeight: "56px",
                padding: "21px 5px 13px",
                paddingLeft: selected ? "20px" : "10px",
                justifyContent: "space-between",
                boxSizing: "border-box"
              }
            }, React.createElement("p", undefined, selected ? "🤠" + " " : "", film.name, selected ? " " + "🤠" : ""), React.createElement("p", {
                  style: {
                    border: "black 5px"
                  }
                }, film.creator ? "Ferma" : "karmi"));
}

var make = FilmlistItem;

exports.creatorToString = creatorToString;
exports.make = make;
/* react Not a pure module */
