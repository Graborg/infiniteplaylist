

import * as React from "react";
import * as ReactDom from "react-dom";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as App$RescriptProjectTemplate from "./components/App/App.bs.js";

import './styles/main.scss'
;

ReactDom.render(React.createElement(React.StrictMode, {
          children: React.createElement(App$RescriptProjectTemplate.make, {})
        }), Belt_Option.getExn(Caml_option.nullable_to_opt(document.querySelector("#root"))));

export {
  
}
/*  Not a pure module */
