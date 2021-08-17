'use strict';

var Fetch = require("bs-fetch/src/Fetch.bs.js");
var Js_dict = require("rescript/lib/js/js_dict.js");
var Js_json = require("rescript/lib/js/js_json.js");
var Belt_Array = require("rescript/lib/js/belt_Array.js");
var Belt_Float = require("rescript/lib/js/belt_Float.js");
var Caml_array = require("rescript/lib/js/caml_array.js");
var Belt_Option = require("rescript/lib/js/belt_Option.js");
var Caml_option = require("rescript/lib/js/caml_option.js");
var Dom_storage = require("rescript/lib/js/dom_storage.js");

var localStorageNamespace = "todoist-token";

var localStorageProjectIdNamespace = "todoist-project";

var clientSecret = "93820ee048244655adc1bb55475f0297";

var clientId = "be81e104bbad4668a009dbf1ae3221c6";

var todoistProjectsUrl = "https://api.todoist.com/rest/v1/projects";

var todoistProjectUrl = "https://api.todoist.com/rest/v1/tasks?project_id=";

var tasksUrl = "https://api.todoist.com/rest/v1/tasks";

var randomString = "fox0BUFvugh1kau";

var todoistLoginLink = "http://todoist.com/oauth/authorize?client_id=be81e104bbad4668a009dbf1ae3221c6&scope=data:read_write,data:delete&state=fox0BUFvugh1kau";

function trimQuotes(str) {
  return str.replace("\"", "").replace("\"", "");
}

function setTokenLocalStorage(token) {
  Dom_storage.setItem(localStorageNamespace, token, localStorage);
  return token;
}

function getTokenLocalStorage(param) {
  return Dom_storage.getItem(localStorageNamespace, localStorage);
}

function getProjectIdLocalStorage(param) {
  return Dom_storage.getItem(localStorageProjectIdNamespace, localStorage);
}

function setProjectIdLocalStorage(projectId) {
  return Dom_storage.setItem(localStorageProjectIdNamespace, projectId, localStorage);
}

function authorizationHeader(token) {
  return Fetch.RequestInit.make(undefined, {
                Authorization: "Bearer " + token
              }, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined);
}

function setFilmAsSeen(film) {
  var token = Dom_storage.getItem(localStorageNamespace, localStorage);
  var payload = {};
  payload["description"] = "completed";
  if (token !== undefined) {
    return fetch("https://api.todoist.com/rest/v1/tasks/" + String(film.id), Fetch.RequestInit.make(/* Post */2, {
                      "Content-Type": "application/json",
                      Authorization: "Bearer " + token
                    }, Caml_option.some(JSON.stringify(payload)), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined));
  }
  throw {
        RE_EXN_ID: "Match_failure",
        _1: [
          "Todoist.res",
          51,
          4
        ],
        Error: new Error()
      };
}

function setFilmAsUnseen(film) {
  var token = Dom_storage.getItem(localStorageNamespace, localStorage);
  var payload = {};
  payload["description"] = "";
  if (token !== undefined) {
    return fetch("https://api.todoist.com/rest/v1/tasks/" + String(film.id), Fetch.RequestInit.make(/* Post */2, {
                      "Content-Type": "application/json",
                      Authorization: "Bearer " + token
                    }, Caml_option.some(JSON.stringify(payload)), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined));
  }
  throw {
        RE_EXN_ID: "Match_failure",
        _1: [
          "Todoist.res",
          71,
          4
        ],
        Error: new Error()
      };
}

function addFilm(filmName) {
  var token = Dom_storage.getItem(localStorageNamespace, localStorage);
  var payload = {};
  var projectId = Dom_storage.getItem(localStorageProjectIdNamespace, localStorage);
  var projectIdFloat = Belt_Option.flatMap(projectId, Belt_Float.fromString);
  if (token !== undefined) {
    if (projectIdFloat !== undefined) {
      payload["content"] = filmName;
      payload["project_id"] = projectIdFloat;
      return fetch(tasksUrl, Fetch.RequestInit.make(/* Post */2, {
                            "Content-Type": "application/json",
                            Authorization: "Bearer " + token
                          }, Caml_option.some(JSON.stringify(payload)), undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined)(undefined)).then(function (prim) {
                    return prim.json();
                  }).then(function (res) {
                  var decoded = Js_json.decodeObject(res);
                  if (decoded !== undefined) {
                    var film = Caml_option.valFromOption(decoded);
                    var id = Belt_Option.getWithDefault(Js_json.decodeNumber(Belt_Option.getWithDefault(Js_dict.get(film, "id"), "0")), 1.0);
                    var creator = Belt_Option.getWithDefault(Js_json.decodeNumber(Belt_Option.getWithDefault(Js_dict.get(film, "creator"), "")), 1.0) | 0;
                    return Promise.resolve([
                                creator === 13612164 ? /* Karmi */0 : /* Ferma */1,
                                id
                              ]);
                  }
                  throw {
                        RE_EXN_ID: "Match_failure",
                        _1: [
                          "Todoist.res",
                          112,
                          10
                        ],
                        Error: new Error()
                      };
                });
    }
    throw {
          RE_EXN_ID: "Match_failure",
          _1: [
            "Todoist.res",
            93,
            4
          ],
          Error: new Error()
        };
  }
  throw {
        RE_EXN_ID: "Match_failure",
        _1: [
          "Todoist.res",
          93,
          4
        ],
        Error: new Error()
      };
}

function getProjectId(token) {
  return fetch(todoistProjectsUrl, authorizationHeader(token)).then(function (prim) {
                return prim.json();
              }).then(function (res) {
              var decoded = Js_json.decodeArray(res);
              if (decoded !== undefined) {
                var projectId = Belt_Array.get(Belt_Array.map(Belt_Array.keep(Belt_Array.map(decoded, Js_json.decodeObject), (function (e) {
                                return Belt_Option.getWithDefault(Js_dict.get(Belt_Option.getWithDefault(e, {}), "name"), "") === "FermaandKarmisInfinitePlaylist";
                              })), (function (e) {
                            return Js_dict.get(Belt_Option.getWithDefault(e, {}), "id");
                          })), 0);
                if (projectId !== undefined) {
                  var id = Caml_option.valFromOption(projectId);
                  if (id !== undefined) {
                    var idStringyfied = JSON.stringify(Caml_option.valFromOption(id));
                    Dom_storage.setItem(localStorageProjectIdNamespace, idStringyfied, localStorage);
                    return Promise.resolve(idStringyfied);
                  }
                  console.log("Project ID not found");
                  return Promise.resolve("");
                }
                throw {
                      RE_EXN_ID: "Match_failure",
                      _1: [
                        "Todoist.res",
                        152,
                        8
                      ],
                      Error: new Error()
                    };
              }
              throw {
                    RE_EXN_ID: "Match_failure",
                    _1: [
                      "Todoist.res",
                      138,
                      6
                    ],
                    Error: new Error()
                  };
            });
}

function getFilms(token) {
  return getProjectId(token).then(function (id) {
              return fetch(todoistProjectUrl + id, authorizationHeader(token)).then(function (prim) {
                            return prim.json();
                          }).then(function (res) {
                          var decoded = Js_json.decodeArray(res);
                          if (decoded !== undefined) {
                            return Promise.resolve(Belt_Array.map(Belt_Array.map(decoded, Js_json.decodeObject), (function (film) {
                                              if (film !== undefined) {
                                                var existingItem = Caml_option.valFromOption(film);
                                                var filmName = trimQuotes(Belt_Option.getWithDefault(Js_json.decodeString(Belt_Option.getWithDefault(Js_dict.get(existingItem, "content"), "")), ""));
                                                var id = Belt_Option.getWithDefault(Js_json.decodeNumber(Belt_Option.getWithDefault(Js_dict.get(existingItem, "id"), "0")), 1.0);
                                                var creator = Belt_Option.getWithDefault(Js_json.decodeNumber(Belt_Option.getWithDefault(Js_dict.get(existingItem, "creator"), "")), 1.0) | 0;
                                                var description = trimQuotes(Belt_Option.getWithDefault(Js_json.decodeString(Belt_Option.getWithDefault(Js_dict.get(existingItem, "description"), "")), ""));
                                                return {
                                                        seen: description === "completed",
                                                        id: id,
                                                        name: filmName,
                                                        creator: creator === 13612164 ? /* Karmi */0 : /* Ferma */1
                                                      };
                                              }
                                              throw {
                                                    RE_EXN_ID: "Match_failure",
                                                    _1: [
                                                      "Todoist.res",
                                                      179,
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
  setTokenLocalStorage: setTokenLocalStorage,
  getTokenLocalStorage: getTokenLocalStorage,
  getProjectIdLocalStorage: getProjectIdLocalStorage,
  setProjectIdLocalStorage: setProjectIdLocalStorage,
  authorizationHeader: authorizationHeader,
  setFilmAsSeen: setFilmAsSeen,
  setFilmAsUnseen: setFilmAsUnseen,
  addFilm: addFilm,
  getProjectId: getProjectId,
  getFilms: getFilms,
  setToken: setToken,
  searchStringToCode: searchStringToCode
};

exports.localStorageNamespace = localStorageNamespace;
exports.localStorageProjectIdNamespace = localStorageProjectIdNamespace;
exports.clientSecret = clientSecret;
exports.clientId = clientId;
exports.todoistProjectsUrl = todoistProjectsUrl;
exports.todoistProjectUrl = todoistProjectUrl;
exports.tasksUrl = tasksUrl;
exports.randomString = randomString;
exports.todoistLoginLink = todoistLoginLink;
exports.Todoist = Todoist;
/* No side effect */
