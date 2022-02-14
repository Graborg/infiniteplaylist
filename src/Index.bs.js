

import * as React from "react";
import * as ReactDom from "react-dom";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import App from "firebase/app";
import * as Auth from "firebase/auth";
import * as Firestore from "firebase/firestore";
import * as App$RescriptProjectTemplate from "./components/App/App.bs.js";

import './styles/main.scss'
;

var conf = {
  apiKey: "AIzaSyCTc74dSk1h1ImyBHcYyHx4X0E2kJloe9I",
  authDomain: "fermaandkarmisinfiniteplaylist.firebaseapp.com",
  projectId: "fermaandkarmisinfiniteplaylist",
  storageBucket: "fermaandkarmisinfiniteplaylist.appspot.com",
  messagingSenderId: "491628845187",
  appId: "1:491628845187:web:4067c45aee702242bfa3b6"
};

App.initializeApp(conf);

ReactDom.render(React.createElement(React.StrictMode, {
          children: React.createElement(App$RescriptProjectTemplate.make, {})
        }), Belt_Option.getExn(Caml_option.nullable_to_opt(document.querySelector("#root"))));

export {
  conf ,
  
}
/*  Not a pure module */
