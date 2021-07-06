'use strict';

var React = require("react");

function Title(Props) {
  return React.createElement("div", {
              style: {
                margin: "10px"
              }
            }, React.createElement("h2", {
                  className: "gradient-text"
                }, "Ferma and Karmi's infinite playlist"));
}

var make = Title;

exports.make = make;
/* react Not a pure module */
