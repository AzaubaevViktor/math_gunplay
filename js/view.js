// Generated by CoffeeScript 1.8.0
(function() {
  var View;

  View = (function() {
    function View() {
      var ind, item, items, _i, _len;
      this.elements = {
        buttons: {
          backward: $("#backward"),
          forward: $("#forward"),
          daynight: $("#daynight"),
          stats: $("#stats")
        },
        inputs: {},
        blocks: {},
        carousel: {
          "this": new _Carousel($("#carousel")),
          items: [$("#item0"), $("#item1"), $("#item2"), $("#item3")]
        },
        tables: [],
        places: [],
        templates: {
          players: ($("#players-template")).html(),
          place: ($("#place-template")).html(),
          addplayer: ($("#addplayer-template")).html()
        },
        settings: $("#settings-modal .modal-body"),
        saves: $("#saves-modal .modal-body"),
        stats: $("#stats-modal .modal-body")
      };
      this.nightMode = {
        is: false,
        selected: -1,
        attack: -1
      };
      items = this.elements.carousel.items;
      for (ind = _i = 0, _len = items.length; _i < _len; ind = ++_i) {
        item = items[ind];
        item.html("<table id=\"table" + ind + "\" class=\"table\"> " + this.elements.templates.players + " </table>");
        this.elements.tables.push($("#table" + ind));
        this.elements.places.push({
          "this": $("#table" + ind + " > .pl-list"),
          list: []
        });
      }
      this.elements.tables[0].append(this.elements.templates.addplayer);
      this.elements.inputs.newPlayer = $("#addplayer");
      this.elements.blocks.newPlayer = $(($(".pl-addplayer"))[0]);
      void 0;
    }

    View.prototype.joinModel = function(_at_model) {
      this.model = _at_model;
      this.updateSaves();
      this.initStats();
      return void 0;
    };

    View.prototype.joinController = function(_at_controller) {
      this.controller = _at_controller;
      this.generateSettings();
      return void 0;
    };

    View.prototype.updateSaves = function() {
      var id, time, _ref;
      this.elements.saves.html("");
      _ref = this.model.saves.ids;
      for (id in _ref) {
        time = _ref[id];
        this.elements.saves.append("<button type='button' id='" + id + "' act='load' class='btn btn-default'>" + time + "</button> <button type='button' id='" + id + "' act='delete' class='btn btn-default'>&times;</button><br>");
      }
      return this.elements.saves.append("<button type='button' act='new' class='btn btn-default'>Сохранить</button>");
    };

    View.prototype.generateSettings = function() {
      var body, def, desc, elem, help, name, sett, settDesc, _results;
      sett = this.model.settings;
      settDesc = this.model._settingsDesc;
      body = this.elements.settings;
      _results = [];
      for (name in settDesc) {
        desc = settDesc[name];
        help = desc.help ? "<p class='help-block'>" + desc.help + "</p>" : "";
        switch (desc.type) {
          case "text":
            body.append("<div class='row'> <div class='col-lg-10'> <p class='form-control-static' id='" + name + "'>" + desc.before + "</p> " + help + " </div> </div>");
            break;
          case "number":
            body.append("<div class='row'> <div class='col-lg-10'> <div class='input-group'> <span class='input-group-addon'>" + desc.before + "</span> <input id='" + name + "' type='number' class='form-control' placeholder='" + (desc.def ? desc.def : '') + "'> <span class='input-group-addon'>" + desc.after + "</span> </div> " + help + " </div> </div>");
            break;
          case "checkbox":
            body.append("<div class='row'> <div class='col-lg-10'> <div class='checkbox'> <label> <input id='" + name + "' type='checkbox'>" + desc.after + " </label> " + help + " </div> </div> </div>");
            break;
        }
        elem = $("#" + name);
        this.elements.settings[name] = elem[0];
        def = this.model.settings[name];
        this.controller.bindSettings(elem, name, desc.type, def);
        _results.push(void 0);
      }
      return _results;
    };

    View.prototype.updateUI = function() {
      this.placeTest();
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
      var ind, listItem, plN, place, places, tr, _i, _j, _k, _len, _len1, _len2, _ref;
      places = this.elements.places;
      while (places[0].list.length < this.model.players.length) {
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
              treat: [listItem.find(".treat0"), listItem.find(".treat1"), listItem.find(".treat2"), listItem.find(".treat3")],
              penalty: listItem.find(".penalty")
            }
          });
          place.list.slice(-1)[0].actions["this"].hide();
        }
        listItem = places[0].list.slice(-1)[0];
        plN = places[0].list.length - 1;
        listItem["this"].attr("plN", "" + plN);
        listItem.actions.solve.attr({
          "act": "solve",
          "plN": "" + plN
        });
        listItem.actions.unsolve.attr({
          "act": "unsolve",
          "plN": "" + plN
        });
        _ref = listItem.actions.treat;
        for (ind = _j = 0, _len1 = _ref.length; _j < _len1; ind = ++_j) {
          tr = _ref[ind];
          tr.attr({
            "plN": "" + plN,
            "act": "treat",
            "solved": "" + ind
          });
        }
        listItem.actions.penalty.attr({
          "act": "penalty",
          "plN": "" + plN
        });
      }
      while (places[0].list.length > this.model.players.length) {
        for (_k = 0, _len2 = places.length; _k < _len2; _k++) {
          place = places[_k];
          place.list.slice(-1)[0]["this"].hide().remove();
          place.list.pop();
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
        this.elements.buttons.forward.show(500);
      } else {
        this.elements.buttons.forward.hide(500);
      }
      return void 0;
    };

    View.prototype.beforeGameUI = function() {
      var listById;
      this.nightMode.is = false;
      listById = this.model.players;
      this.elements.carousel["this"].hideControls();
      this.elements.carousel["this"].go(0);
      this.elements.carousel["this"].pause();
      this.elements.blocks.newPlayer.show(500);
      this.elements.buttons.daynight.text("Добавление игроков");
      this.placeTest();
      this.renderPlayers([listById]);
      return void 0;
    };

    View.prototype.dayUI = function() {
      var getSortF, listByHealth, listById, listBySolve, listByUnsolve;
      this.nightMode.is = false;
      this.nightMode.attack = -1;
      this.nightMode.selected = -1;
      this.elements.carousel["this"].showControls();
      this.elements.carousel["this"].overflow("hidden");
      this.elements.carousel["this"].go(0);
      this.elements.carousel["this"].start();
      this.elements.blocks.newPlayer.hide(500);
      ($(".sun")).show();
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
      this.renderPlayers([listById, listByHealth, listBySolve, listByUnsolve]);
      return void 0;
    };

    View.prototype.nightUI = function() {
      var listById;
      this.nightMode.is = true;
      this.elements.carousel["this"].hideControls();
      this.elements.carousel["this"].overflow("visible");
      this.elements.carousel["this"].go(0);
      this.elements.carousel["this"].pause();
      ($(".sun")).hide();
      this.elements.blocks.newPlayer.hide(500);
      listById = this.model.players;
      this.elements.buttons.daynight.text("Ночь");
      this.renderPlayers([listById]);
      return void 0;
    };

    View.prototype.renderPlayers = function(lists) {
      var attackLevel, l, list, listItem, p, place, player, _i, _j, _len, _len1;
      for (l = _i = 0, _len = lists.length; _i < _len; l = ++_i) {
        list = lists[l];
        place = this.elements.places[l];
        attackLevel = this.model.getLevel(this.nightMode.attack);
        for (p = _j = 0, _len1 = list.length; _j < _len1; p = ++_j) {
          player = list[p];
          listItem = place.list[p];
          listItem.id.text(player.id + 1);
          listItem.name.html(player.name + strCopy("*", player.penalties).fontcolor("red"));
          if (this.nightMode.is && (p === this.nightMode.selected)) {
            listItem.health.hide();
            listItem.attack.hide();
            listItem.tasks.hide();
            listItem.actions["this"].show();
          } else {
            listItem.health.show().text(((this.model.getHealth(player.id)) * 100).toFixed(0));
            listItem.attack.show().html(((this.model.getAttack(player.id)) * 100).toFixed(0) + "<lite>(" + ((this.model.getAttackWithoutTreat(player.id)) * 100).toFixed(0) + ")</lite>");
            listItem.tasks.show().text(player.solve + "/" + player.unsolve);
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
      var a, all_time, b, c, k, minutes, page_w, top_max, top_min;
      minutes = this.model.time % 60;
      minutes = minutes < 10 ? "0" + minutes : minutes;
      this.elements.buttons.daynight.text("День (" + (Math.floor(this.model.time / 60)) + ":" + minutes + ")");
      page_w = ($("html")).width();
      all_time = this.model.settings.stTime * 60;
      k = this.model.time / all_time;
      top_max = 70;
      top_min = 100;
      b = (top_max - top_min) * 4;
      a = -b;
      c = top_min;
      ($(".sun")).offset({
        top: a * k * k + b * k + c,
        left: (1 - k) * (page_w + 150) - 100
      });
      return void 0;
    };

    View.prototype.hit = function(plN1, plN2, atk) {
      this.nightMode.attack = -1;
      this.nightMode.selected = -1;
      this.updateUI();
      this.popup(plN2, "health", atk * 100);
      return void 0;
    };

    View.prototype.miss = function(plN) {
      this.nightMode.attack = -1;
      this.nightMode.selected = -1;
      this.updateUI();
      this.popup(plN, "name", "Мазила");
      return void 0;
    };

    View.prototype.treat = function(plN, inc, diffTreat) {
      this.nightMode.attack = -1;
      this.nightMode.selected = -1;
      this.updateUI();
      this.popup(plN, "health", inc * 100);
      return void 0;
    };

    View.prototype.penalty = function(plN) {
      this.nightMode.selected = -1;
      this.updateUI();
      this.popup(plN, "name", "Не делай так");
      return void 0;
    };

    View.prototype.popup = function(plN, selector, text) {
      var el, left, popup, top, _this;
      el = this.elements.places[0].list[plN][selector];
      left = el.offset().left + el.width() / 2;
      top = el.offset().top - el.height() / 2;
      if ($.isNumeric(text)) {
        text = text.toFixed(0);
        if (text >= 0) {
          text = "+" + text;
        }
      }
      el.append("<div id='popup' class='" + (text >= 0 ? 'green' : 'red') + "' style='opacity:0'>" + text + "</div>");
      popup = $("#popup");
      popup.offset({
        top: top,
        left: left
      });
      _this = this;
      return (popup.animate({
        opacity: [1, "swing"],
        top: ["-=20px", "linear"]
      }, 1000)).animate({
        opacity: [0, "swing"],
        top: ["-=20px", "linear"]
      }, 1000, "linear", function() {
        return popup.remove();
      });
    };

    View.prototype.attackMode = function(plN) {
      if (-1 === this.nightMode.attack) {
        this.nightMode.attack = plN;
      } else {
        this.nightMode.attack = -1;
        this.nightMode.selected = -1;
      }
      this.updateUI();
      return void 0;
    };

    View.prototype.selectMode = function(plN) {
      if (-1 !== this.nightMode.attack) {
        this.model.hit(this.nightMode.attack, plN);
      } else {
        this.nightMode.selected = plN === this.nightMode.selected ? -1 : plN;
        this.updateUI();
      }
      return void 0;
    };

    View.prototype.initStats = function() {
      var body, name, st, stats, _results;
      body = this.elements.stats;
      stats = this.model.stats;
      _results = [];
      for (name in stats) {
        st = stats[name];
        _results.push(body.append("<div class='row'>\n  <div class='col-lg-10'>\n    <p class='form-control-static'>" + st.title + "<number id='" + name + "'>" + st.value + "</number></p>\n  </div>\n</div>"));
      }
      return _results;
    };

    View.prototype.renderStats = function() {
      var name, st, stats, _results;
      stats = this.model.stats;
      _results = [];
      for (name in stats) {
        st = stats[name];
        _results.push(($("#" + name)).text("" + (st.value.toLocaleString())));
      }
      return _results;
    };

    return View;

  })();

  window.View = View;

}).call(this);

//# sourceMappingURL=view.js.map
