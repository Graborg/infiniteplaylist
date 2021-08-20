'use strict';

var React = require("react");
var ReactDom = require("react-dom");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var Caml_option = require("rescript/lib/js/caml_option.js");
var Filmlist$RescriptProjectTemplate = require("./filmlist/Filmlist.bs.js");

import './styles/main.scss'
;

ReactDom.render(React.createElement(React.StrictMode, {
          children: React.createElement(Filmlist$RescriptProjectTemplate.make, {})
        }), Belt_Option.getExn(Caml_option.nullable_to_opt(document.querySelector("#root"))));

/*  Not a pure module */
