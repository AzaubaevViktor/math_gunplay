// Generated by CoffeeScript 1.7.1
(function() {
  var Controller, Model, View, deepCopy, getValScope, _Carousel;

  getValScope = function(val, scope) {
    if (scope[0] > val) {
      return scope[0];
    } else if (scope[1] < val) {
      return scope[1];
    }
    return val;
  };

  deepCopy = function(v) {
    return $.extend(true, [], v);
  };

  Model = (function() {
    function Model() {
      this.isDay = false;
      this.isGame = false;
      this.stTime = 15 * 60;
      this.time = 0;
      this.timer = void 0;
      this.players = [];
      this.snapshots = [];
      this.snapshotPoint = -1;
      this.levels = {
        square: [0.8, 1],
        hospital: [0.3, 0.8],
        resuscitation: [0, 0.3],
        morgue: [-10000, 0]
      };
      this.view = void 0;
      this.addSnapshot();
      void 0;
    }

    Model.prototype.joinView = function(view) {
      this.view = view;
    };

    Model.prototype.forwardSnapshot = function() {
      this.snapshotPoint += 1;
      return this.loadSnapshot(this.snapshotPoint);
    };

    Model.prototype.loadSnapshot = function(snapshotN) {
      var _ref;
      if (snapshotN == null) {
        snapshotN = this.snapshotPoint - 1;
      }
      this.snapshotPoint = snapshotN;
      _ref = this.snapshots[this.snapshotPoint], this.isGame = _ref.isGame, this.isDay = _ref.isDay, this.players = _ref.players;
      this.view.updateUI();
      return void 0;
    };

    Model.prototype.addSnapshot = function() {
      var _ref, _ref1;
      this.snapshotPoint += 1;
      [].splice.apply(this.snapshots, [(_ref = this.snapshotPoint), 9e9].concat(_ref1 = {
        'isGame': this.isGame,
        'isDay': this.isDay,
        'players': deepCopy(this.players)
      })), _ref1;
      if (this.view) {
        this.view.snapshotButtons();
      }
      return void 0;
    };

    Model.prototype.clearSnapshots = function() {
      this.snapshotPoint = -1;
      this.snapshots = [];
      this.addSnapshot();
      return void 0;
    };

    Model.prototype.setDayTimer = function() {
      this.time = this.stTime;
      this.view.updateTime();
      this.timer = setInterval(function(_this) {
        _this.time -= 1;
        if (_this.time <= 0) {
          _this.changeDayNight();
        } else {
          _this.view.updateTime();
        }
        return void 0;
      }, 1000, this);
      return void 0;
    };

    Model.prototype.changeDayNight = function() {
      clearInterval(this.timer);
      if (!this.isGame) {
        this.isGame = true;
        this.isDay = true;
      } else {
        this.isDay = !this.isDay;
      }
      if (this.isDay) {
        this.setDayTimer();
      }
      this.clearSnapshots();
      this.view.updateUI();
      return void 0;
    };

    Model.prototype.setHealth = function(plN, health) {
      this.players[plN].health = getValScope(health, [0, 1]);
      return void 0;
    };

    Model.prototype.getLevel = function(plN) {
      var h, level, scope, _ref;
      if (plN !== -1) {
        h = this.players[plN].health;
        _ref = this.levels;
        for (level in _ref) {
          scope = _ref[level];
          if ((scope[0] < h && h <= scope[1])) {
            return level;
          }
        }
      }
      return void 0;
    };

    Model.prototype.getAttack = function(plN) {
      var pl;
      pl = this.players[plN];
      return (getValScope(10 + pl.solve - pl.unsolve - 3 * pl.treatment, [0, 20])) / 100;
    };

    Model.prototype.getAttackTo = function(plN, plN2) {
      if ((0 === this.players[plN].health) || ((this.getLevel(plN)) !== (this.getLevel(plN2)))) {
        return 0;
      }
      return this.getAttack(plN);
    };

    Model.prototype.getTreat = function(plN, solved) {
      var h, pl;
      pl = this.players[plN];
      h = 5 * solved + pl.solve - pl.unsolve - 3 * pl.treatment - 5;
      if ((this.getLevel(plN)) === 'hospital') {
        h += 10;
      }
      return (getValScope(h, [-Infinity, Infinity])) / 100;
    };

    Model.prototype.treat = function(plN, solved) {
      var pl;
      pl = this.players[plN];
      this.setHealth(plN, pl.health + this.getTreat(plN, solved));
      if ((this.getLevel(plN)) === "resuscitation") {
        pl.treatment = 0;
      } else {
        pl.treatment += 1;
      }
      this.addSnapshot();
      this.view.treat(plN);
      return void 0;
    };

    Model.prototype.hit = function(plN1, plN2) {
      var pl1, pl2;
      pl1 = this.players[plN1];
      pl2 = this.players[plN2];
      this.setHealth(plN2, pl2.health - this.getAttackTo(plN1, plN2));
      pl1.solve += 1;
      this.view.hit(plN1, plN2);
      this.addSnapshot();
      return void 0;
    };

    Model.prototype.miss = function(plN1) {
      var pl1;
      pl1 = this.players[plN1].unsolve += 1;
      this.view.miss(plN1);
      this.addSnapshot();
      return void 0;
    };

    Model.prototype.addPlayer = function(name) {
      this.players.push({
        name: name,
        id: this.players.length,
        health: 1,
        solve: 0,
        unsolve: 0,
        treatment: 0
      });
      this.view.updateUI();
      return void 0;
    };

    return Model;

  })();

  View = (function() {
    function View() {
      var ind, item, items, _i, _len, _ref;
      this.elements = {
        buttons: {
          backward: $("#backward"),
          forward: $("#forward"),
          daynight: $("#daynight")
        },
        inputs: {
          newPlayer: $("#addplayer")
        },
        blocks: {
          newPlayer: $(".pl-addplayer")
        },
        carousel: {
          "this": new _Carousel($("#carousel")),
          items: [$("#item0"), $("#item1"), $("#item2"), $("#item3")]
        },
        tables: [$("#table0")],
        places: [
          {
            "this": $("#table0 > .pl-list"),
            list: []
          }
        ],
        templates: {
          players: ($("#players-template")).html(),
          place: ($("#place-template")).html()
        }
      };
      this.nightMode = {
        is: false,
        selected: -1,
        attack: -1
      };
      items = this.elements.carousel.items;
      _ref = items.slice(1);
      for (ind = _i = 0, _len = _ref.length; _i < _len; ind = ++_i) {
        item = _ref[ind];
        item.html("<table id=\"table" + (ind + 1) + "\" class=\"table\"> " + this.elements.templates.players + " </table>");
        this.elements.tables.push($("#table" + (ind + 1)));
        this.elements.places.push({
          "this": $("#table" + (ind + 1) + " > .pl-list"),
          list: []
        });
      }
    }

    View.prototype.joinModel = function(model) {
      this.model = model;
    };

    View.prototype.joinController = function(controller) {
      this.controller = controller;
    };

    View.prototype.updateUI = function() {
      this.snapshotButtons();
      if (!this.model.isGame) {
        this.beforeGameUI();
      } else {
        if (this.model.isDay) {
          this.dayUI();
        } else {
          this.nightUI();
        }
      }
      return void 0;
    };

    View.prototype.placeTest = function() {
      var listItem, place, places, _i, _len;
      places = this.elements.places;
      if (places[0].list.length < this.model.players.length) {
        for (_i = 0, _len = places.length; _i < _len; _i++) {
          place = places[_i];
          place["this"].append(this.elements.templates.place);
          listItem = place["this"].find("tr:last-child");
          listItem.hide();
          place.list.push({
            "this": listItem,
            id: listItem.find(".id"),
            name: listItem.find(".name"),
            health: listItem.find(".health"),
            attack: listItem.find(".attack"),
            tasks: listItem.find(".tasks"),
            actions: {
              "this": listItem.find(".actions"),
              solve: listItem.find(".solve"),
              unsolve: listItem.find(".unsolve"),
              treat: [listItem.find(".treat0"), listItem.find(".treat1"), listItem.find(".treat2"), listItem.find(".treat3")]
            }
          });
          place.list.slice(-1)[0].actions["this"].hide();
        }
      }
      return void 0;
    };

    View.prototype.snapshotButtons = function() {
      if (this.model.snapshotPoint !== 0) {
        this.elements.buttons.backward.show(500);
      } else {
        this.elements.buttons.backward.hide(500);
      }
      if (this.model.snapshotPoint !== (this.model.snapshots.length - 1)) {
        return this.elements.buttons.forward.show(500);
      } else {
        return this.elements.buttons.forward.hide(500);
      }
    };

    View.prototype.beforeGameUI = function() {
      var listById;
      this.nightMode.is = false;
      listById = this.model.players;
      this.elements.carousel["this"].hideControls();
      this.elements.carousel["this"].go(0);
      this.elements.carousel["this"].pause();
      this.elements.blocks.newPlayer.show(500);
      this.elements.buttons.daynight.text("Начать игру!");
      this.placeTest();
      return this.placePlayers([listById]);
    };

    View.prototype.dayUI = function() {
      var getSortF, listByHealth, listById, listBySolve, listByUnsolve;
      this.nightMode.is = false;
      this.nightMode.attack = -1;
      this.nightMode.selected = -1;
      this.elements.carousel["this"].showControls();
      this.elements.carousel["this"].go(0);
      this.elements.carousel["this"].start();
      this.elements.blocks.newPlayer.hide(500);
      getSortF = function(item) {
        return function(a, b) {
          return b[item] - a[item];
        };
      };
      listById = this.model.players;
      listByHealth = deepCopy(listById);
      listByHealth.sort(getSortF('health'));
      listBySolve = deepCopy(listById);
      listBySolve.sort(getSortF('solve'));
      listByUnsolve = deepCopy(listById);
      listByUnsolve.sort(getSortF('unsolve'));
      return this.placePlayers([listById, listByHealth, listBySolve, listByUnsolve]);
    };

    View.prototype.nightUI = function() {
      var listById;
      this.nightMode.is = true;
      this.controller.bindNight();
      this.elements.carousel["this"].hideControls();
      this.elements.carousel["this"].go(0);
      this.elements.carousel["this"].pause();
      this.elements.blocks.newPlayer.hide(500);
      listById = this.model.players;
      this.elements.buttons.daynight.text("Ночь");
      return this.placePlayers([listById]);
    };

    View.prototype.placePlayers = function(lists) {
      var attackLevel, l, list, listItem, p, place, player, _i, _j, _len, _len1;
      for (l = _i = 0, _len = lists.length; _i < _len; l = ++_i) {
        list = lists[l];
        place = this.elements.places[l];
        attackLevel = this.model.getLevel(this.nightMode.attack);
        for (p = _j = 0, _len1 = list.length; _j < _len1; p = ++_j) {
          player = list[p];
          listItem = place.list[p];
          listItem.id.text(player.id + 1);
          listItem.name.text(player.name);
          if (this.nightMode.is && (p === this.nightMode.selected)) {
            listItem.health.hide();
            listItem.attack.hide();
            listItem.tasks.hide();
            listItem.actions["this"].show();
          } else {
            listItem.health.show().text((player.health * 100).toFixed(0));
            listItem.attack.show().text(((this.model.getAttack(player.id)) * 100).toFixed(0));
            listItem.tasks.show().text("" + player.solve + "/" + player.unsolve);
            listItem.actions["this"].hide();
          }
          listItem["this"].removeClass().addClass(this.model.getLevel(player.id));
          if ((this.nightMode.attack !== -1) && (attackLevel !== this.model.getLevel(p))) {
            listItem["this"].addClass("not").prop({
              "disabled": true
            });
          } else {
            listItem["this"].removeClass("not");
          }
          listItem["this"].show(500);
          void 0;
        }
        void 0;
      }
      return void 0;
    };

    View.prototype.updateTime = function() {
      var minutes;
      minutes = this.model.time % 60;
      minutes = minutes < 10 ? "0" + minutes : minutes;
      return this.elements.buttons.daynight.text("День (" + (Math.floor(this.model.time / 60)) + ":" + minutes + ")");
    };

    View.prototype.hit = function(plN1, plN2) {
      console.log("BADABOOM " + plN1 + " ====> " + plN2);
      this.nightMode.attack = -1;
      this.nightMode.selected = -1;
      this.updateUI();
      return void 0;
    };

    View.prototype.miss = function(plN) {
      console.log("PHAHAHA " + plN);
      this.nightMode.selected = -1;
      this.nightMode.attack = -1;
      this.updateUI();
      return void 0;
    };

    View.prototype.treat = function(plN) {
      this.nightMode.attack = -1;
      this.nightMode.selected = -1;
      return this.updateUI();
    };

    View.prototype.attackMode = function(plN) {
      if (-1 === this.nightMode.attack) {
        this.nightMode.attack = plN;
      } else {
        this.nightMode.attack = -1;
        this.nightMode.selected = -1;
      }
      return this.updateUI();
    };

    View.prototype.selectMode = function(plN) {
      if (-1 !== this.nightMode.attack) {
        return this.model.hit(this.nightMode.attack, plN);
      } else {
        this.nightMode.selected = plN === this.nightMode.selected ? -1 : plN;
        return this.updateUI();
      }
    };

    return View;

  })();

  Controller = (function() {
    function Controller() {
      this.isBindNight = 0;
    }

    Controller.prototype.joinModel = function(model) {
      this.model = model;
    };

    Controller.prototype.joinView = function(view) {
      this.view = view;
    };

    Controller.prototype.bind = function() {
      var input, _this;
      _this = this;
      input = this.view.elements.inputs.newPlayer;
      input.keyup(function(e) {
        var name;
        if (13 === e.keyCode) {
          name = input.val();
          input.val("");
          _this.model.addPlayer(name);
        }
        return void 0;
      });
      this.view.elements.buttons.daynight.click(function() {
        return _this.model.changeDayNight();
      });
      this.view.elements.buttons.forward.click(function() {
        return _this.model.forwardSnapshot();
      });
      this.view.elements.buttons.backward.click(function() {
        return _this.model.loadSnapshot();
      });
      return void 0;
    };

    Controller.prototype.bindNight = function() {
      var item, plN, place, solved, tr, _i, _j, _len, _len1, _ref, _ref1, _results;
      if (!this.isBindNight) {
        this.isBindNight = 1;
        place = this.view.elements.places[0];
        _ref = place.list;
        _results = [];
        for (plN = _i = 0, _len = _ref.length; _i < _len; plN = ++_i) {
          item = _ref[plN];
          item.actions.unsolve.on('click', {
            plN: plN,
            _this: this
          }, function(event) {
            var model, _ref1, _ref2;
            _ref1 = event.data, plN = _ref1.plN, (_ref2 = _ref1._this, model = _ref2.model);
            return model.miss(plN);
          });
          item.actions.solve.on('click', {
            plN: plN,
            _this: this
          }, function(event) {
            var view, _ref1, _ref2;
            _ref1 = event.data, plN = _ref1.plN, (_ref2 = _ref1._this, view = _ref2.view);
            return view.attackMode(plN);
          });
          _ref1 = item.actions.treat;
          for (solved = _j = 0, _len1 = _ref1.length; _j < _len1; solved = ++_j) {
            tr = _ref1[solved];
            tr.on('click', {
              plN: plN,
              _this: this,
              solved: solved
            }, function(event) {
              var model, _ref2, _ref3;
              _ref2 = event.data, plN = _ref2.plN, (_ref3 = _ref2._this, model = _ref3.model), solved = _ref2.solved;
              return model.treat(plN, solved);
            });
            void 0;
          }
          item["this"].on('click', "td:not(.actions)", {
            plN: plN,
            _this: this
          }, function(event) {
            var model, view, _ref2, _ref3;
            _ref2 = event.data, plN = _ref2.plN, (_ref3 = _ref2._this, view = _ref3.view, model = _ref3.model);
            return view.selectMode(plN);
          });
          item.id.css('cursor', 'pointer');
          item.name.css('cursor', 'pointer');
          _results.push(void 0);
        }
        return _results;
      }
    };

    return Controller;

  })();

  _Carousel = (function() {
    function _Carousel(elem) {
      this.elem = elem;
    }

    _Carousel.prototype.start = function() {
      return this.elem.carousel("cycle");
    };

    _Carousel.prototype.pause = function() {
      return this.elem.carousel("pause");
    };

    _Carousel.prototype.go = function(num) {
      return this.elem.carousel(num);
    };

    _Carousel.prototype.next = function() {
      return this.elem.carousel("next");
    };

    _Carousel.prototype.prev = function() {
      return this.elem.carousel("prev");
    };

    _Carousel.prototype.hideControls = function() {
      this.elem.find(".carousel-control").fadeOut(500);
      this.elem.find(".carousel-indicators").fadeOut(500);
      return void 0;
    };

    _Carousel.prototype.showControls = function() {
      this.elem.find(".carousel-control").fadeIn(500);
      this.elem.find(".carousel-indicators").fadeIn(500);
      return void 0;
    };

    return _Carousel;

  })();

  ($(document)).ready(function() {
    var controller, model, view;
    console.log("I'm alive!");
    jQuery.fx.interval = 40;
    model = new Model();
    view = new View();
    controller = new Controller();
    model.joinView(view);
    view.joinModel(model);
    view.joinController(controller);
    controller.joinView(view);
    controller.joinModel(model);
    controller.bind();
    window.Model = Model;
    window.View = View;
    window.Controller = Controller;
    window._Carousel = _Carousel;
    window.model = model;
    window.view = view;
    window.controller = controller;
    ($(".navbar-btn")).tooltip();
    ($(".with-tooltip")).tooltip();
    ($("#version")).text(__version__);
    view.updateUI();
    model.addPlayer("Математики");
    model.addPlayer("Лунатики");
    model.addPlayer("Пузатики");
    return void 0;
  });

}).call(this);

//# sourceMappingURL=core.map
