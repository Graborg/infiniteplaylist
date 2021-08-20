'use strict';

var Curry = require("rescript/lib/js/curry.js");
var React = require("react");
var Random = require("rescript/lib/js/random.js");
var Belt_Array = require("rescript/lib/js/belt_Array.js");

var confetti = (function () {
        window.confetti({
        angle: 125,
        particleCount: 100,
        spread: 70,
        origin: {x:0.7}
        });
    });

var horn = (function () {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      const audioCtx = new AudioContext();
      const audioElement = document.querySelector('audio');
      const track = audioCtx.createMediaElementSource(audioElement);
      const playButton = document.querySelector('.tape-controls-play');
      if (audioCtx.state === 'suspended') {
          audioCtx.resume();
      }
      const gainNode = audioCtx.createGain();

      const volumeControl = document.querySelector('[data-action="volume"]');
      // connect our graph
      track.connect(gainNode).connect(audioCtx.destination);
      audioElement.play();
    });

function creatorToString(creator) {
  if (creator) {
    return "🐄 " + "Ferma!" + " 🐄";
  } else {
    return "🐘 " + "Karmi!" + " 🐘";
  }
}

function electFilm(setState, films, selectFilm, nextElector) {
  Curry._1(confetti, undefined);
  Curry._1(horn, undefined);
  var filmsOfCreator = films.filter(function (film) {
        return film.creator === nextElector;
      });
  var randomIndex = Random.$$int(filmsOfCreator.length);
  var film = Belt_Array.get(filmsOfCreator, randomIndex);
  if (film !== undefined) {
    Curry._1(selectFilm, film.name);
    Curry._1(setState, (function (_prevState) {
            return /* FilmElected */{
                    _0: film.name
                  };
          }));
  }
  
}

function RandomBtn(Props) {
  var films = Props.films;
  var doSelectFilm = Props.doSelectFilm;
  var nextElector = Props.nextElector;
  var match = React.useState(function () {
        return /* NoElection */1;
      });
  var setState = match[1];
  var state = match[0];
  return React.createElement("div", undefined, typeof state === "number" ? "" : React.createElement("h2", {
                    className: "gradient-text result"
                  }, state._0), React.createElement("p", {
                  style: {
                    color: nextElector === /* Ferma */1 ? "#476098" : "#8b9862",
                    marginBottom: "5px",
                    textAlign: "center"
                  }
                }, creatorToString(nextElector)), React.createElement("div", {
                  style: {
                    display: "flex",
                    alignItems: "baseline",
                    flexDirection: "row",
                    justifyContent: "space-between"
                  }
                }, React.createElement("button", {
                      style: {
                        color: nextElector === /* Ferma */1 ? "#476098" : "#8b9862",
                        boxShadow: "0 0 0 1px" + (
                          nextElector === /* Ferma */1 ? "#476098" : "#8b9862"
                        )
                      },
                      onClick: (function (_event) {
                          return electFilm(setState, films, doSelectFilm, nextElector);
                        })
                    }, "Hace un volado")));
}

var make = RandomBtn;

exports.confetti = confetti;
exports.horn = horn;
exports.creatorToString = creatorToString;
exports.electFilm = electFilm;
exports.make = make;
/* react Not a pure module */
