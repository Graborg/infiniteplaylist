'use strict';

var Fetch = require("bs-fetch/src/Fetch.bs.js");
var Js_dict = require("rescript/lib/js/js_dict.js");
var Js_json = require("rescript/lib/js/js_json.js");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Caml_array = require("rescript/lib/js/caml_array.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var Caml_option = require("rescript/lib/js/caml_option.js");
var Dom_storage = require("rescript/lib/js/dom_storage.js");

var localStorageNamespace = "todoist-token";

var clientSecret = "93820ee048244655adc1bb55475f0297";

var clientId = "be81e104bbad4668a009dbf1ae3221c6";

var todoistProjectsUrl = "https://api.todoist.com/rest/v1/projects";

var todoistProjectUrl = "https://api.todoist.com/rest/v1/tasks?project_id=";

var randomString = "fox0BUFvugh1kau";

var todoistLoginLink = "http://todoist.com/oauth/authorize?client_id=be81e104bbad4668a009dbf1ae3221c6&scope=data:read,data:delete&state=fox0BUFvugh1kau";

function trimQuotes(str) {
  return str.replace("\"", "").replace("\"", "");
}

function getProjectId(token) {
  return fetch(todoistProjectsUrl, Fetch.RequestInit.make(undefined, {
                        Authorization: "Bearer " + token
                      }, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined)).then(function (prim) {
                return prim.json();
              }).then(function (res) {
              var decoded = Js_json.decodeArray(res);
              if (decoded !== undefined) {
                var projectId = Belt_Array.get(Belt_Array.map(Belt_Array.keep(Belt_Array.map(decoded, Js_json.decodeObject), (function (e) {
                                return Belt_Option.getWithDefault(Js_dict.get(Belt_Option.getWithDefault(e, {}), "name"), "") === "FermaandKarmisInfinitePlaylist";
                              })), (function (e) {
                            return Js_dict.get(Belt_Option.getWithDefault(e, {}), "id");
                          })), 0);
                console.log(projectId);
                if (projectId !== undefined) {
                  var id = Caml_option.valFromOption(projectId);
                  console.log(id);
                  return Promise.resolve(JSON.stringify(Belt_Option.getWithDefault(id, "")));
                }
                throw {
                      RE_EXN_ID: "Match_failure",
                      _1: [
                        "Todoist.res",
                        51,
                        8
                      ],
                      Error: new Error()
                    };
              }
              throw {
                    RE_EXN_ID: "Match_failure",
                    _1: [
                      "Todoist.res",
                      36,
                      6
                    ],
                    Error: new Error()
                  };
            });
}

function getFilms(token) {
  return getProjectId(token).then(function (id) {
              return fetch(todoistProjectUrl + id, Fetch.RequestInit.make(undefined, {
                                    Authorization: "Bearer " + token
                                  }, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined)).then(function (prim) {
                            return prim.json();
                          }).then(function (res) {
                          var decoded = Js_json.decodeArray(res);
                          if (decoded !== undefined) {
                            return Promise.resolve(Belt_Array.map(Belt_Array.map(decoded, Js_json.decodeObject), (function (film) {
                                              if (film !== undefined) {
                                                var existingItem = Caml_option.valFromOption(film);
                                                var filmName = trimQuotes(Belt_Option.getWithDefault(Js_json.decodeString(Belt_Option.getWithDefault(Js_dict.get(existingItem, "content"), "")), ""));
                                                var id = Belt_Option.getWithDefault(Js_json.decodeNumber(Belt_Option.getWithDefault(Js_dict.get(existingItem, "id"), "")), 1.0) | 0;
                                                var creator = Belt_Option.getWithDefault(Js_json.decodeNumber(Belt_Option.getWithDefault(Js_dict.get(existingItem, "creator"), "")), 1.0) | 0;
                                                return {
                                                        id: id,
                                                        name: filmName,
                                                        creator: creator === 13612164 ? /* Karmi */0 : /* Ferma */1
                                                      };
                                              }
                                              throw {
                                                    RE_EXN_ID: "Match_failure",
                                                    _1: [
                                                      "Todoist.res",
                                                      76,
                                                      12
                                                    ],
                                                    Error: new Error()
                                                  };
                                            })));
                          } else {
                            return Promise.resolve([]);
                          }
                        });
            });
}

function setTokenLocalStorage(token) {
  Dom_storage.setItem(localStorageNamespace, token, localStorage);
  return token;
}

function setToken(code) {
  if (code === undefined) {
    return Promise.reject({
                RE_EXN_ID: "Not_found"
              });
  }
  var payload = {};
  payload["code"] = code;
  payload["client_secret"] = clientSecret;
  payload["client_id"] = clientId;
  return fetch("https://todoist.com/oauth/access_token", Fetch.RequestInit.make(/* Post */2, {
                        "Content-Type": "application/json"
                      }, Caml_option.some(JSON.stringify(payload)), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined)).then(function (prim) {
                return prim.json();
              }).then(function (jsonResponse) {
              var decoded = Js_json.decodeObject(jsonResponse);
              var maybeToken = decoded !== undefined ? Js_dict.get(Caml_option.valFromOption(decoded), "access_token") : undefined;
              if (maybeToken !== undefined) {
                return Promise.resolve(setTokenLocalStorage(trimQuotes(JSON.stringify(Caml_option.valFromOption(maybeToken)))));
              } else {
                return Promise.reject({
                            RE_EXN_ID: "Not_found"
                          });
              }
            });
}

function searchStringToCode(search) {
  var code = Belt_Array.getBy(search.split("&s"), (function (e) {
          return e.startsWith("code=");
        }));
  if (code !== undefined) {
    return Caml_array.get(code.split("="), 1);
  }
  
}

var Todoist = {
  trimQuotes: trimQuotes,
  getProjectId: getProjectId,
  getFilms: getFilms,
  setTokenLocalStorage: setTokenLocalStorage,
  setToken: setToken,
  searchStringToCode: searchStringToCode
};

exports.localStorageNamespace = localStorageNamespace;
exports.clientSecret = clientSecret;
exports.clientId = clientId;
exports.todoistProjectsUrl = todoistProjectsUrl;
exports.todoistProjectUrl = todoistProjectUrl;
exports.randomString = randomString;
exports.todoistLoginLink = todoistLoginLink;
exports.Todoist = Todoist;
/* No side effect */
