// Generated by CoffeeScript 1.7.1
(function() {
  var Controller;

  Controller = (function() {
    function Controller() {
      this.isBindNight = 0;
    }

    Controller.prototype.joinModel = function(model) {
      this.model = model;
      return this.bindSaves();
    };

    Controller.prototype.joinView = function(view) {
      this.view = view;
    };

    Controller.prototype.bind = function() {
      var els, input, place;
      els = this.view.elements;
      input = els.inputs.newPlayer;
      input.keyup((function(_this) {
        return function(e) {
          var name;
          if (13 === e.keyCode) {
            name = input.val();
            input.val("");
            _this.model.addPlayer(name);
          }
          return void 0;
        };
      })(this));
      els.buttons.daynight.click((function(_this) {
        return function() {
          _this.model.changeDayNight();
          return void 0;
        };
      })(this));
      els.buttons.forward.click((function(_this) {
        return function() {
          _this.model.forwardSnapshot();
          return void 0;
        };
      })(this));
      els.buttons.backward.click((function(_this) {
        return function() {
          _this.model.loadSnapshot();
          return void 0;
        };
      })(this));
      place = this.view.elements.places[0];
      place["this"].on('click', "td:not(.actions)", this.view, function(event) {
        var plN, view;
        view = event.data;
        plN = parseInt(($(this)).parent().attr("plN"));
        view.selectMode(plN);
        return void 0;
      });
      place["this"].on('click', ".btn, a", {
        "view": this.view,
        "model": this.model
      }, function(event) {
        var act, model, plN, solved, view, _ref;
        _ref = event.data, view = _ref.view, model = _ref.model;
        act = ($(this)).attr("act");
        plN = parseInt(($(this)).attr("plN"));
        solved = parseInt(($(this)).attr("solved"));
        switch (act) {
          case "solve":
            return view.attackMode(plN);
          case "unsolve":
            return model.miss(plN);
          case "treat":
            return model.treat(plN, solved);
        }
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
          item.actions.unsolve.on('click', plN, (function(_this) {
            return function(event) {
              plN = event.data;
              return _this.model.miss(plN);
            };
          })(this));
          item.actions.solve.on('click', plN, (function(_this) {
            return function(event) {
              plN = event.data;
              return _this.view.attackMode(plN);
            };
          })(this));
          _ref1 = item.actions.treat;
          for (solved = _j = 0, _len1 = _ref1.length; _j < _len1; solved = ++_j) {
            tr = _ref1[solved];
            tr.on('click', {
              plN: plN,
              solved: solved
            }, (function(_this) {
              return function(event) {
                var _ref2;
                _ref2 = event.data, plN = _ref2.plN, solved = _ref2.solved;
                return _this.model.treat(plN, solved);
              };
            })(this));
            void 0;
          }
          item["this"].on('click', "td:not(.actions)", plN, (function(_this) {
            return function(event) {
              plN = event.data;
              return _this.view.selectMode(plN);
            };
          })(this));
          item.id.css('cursor', 'pointer');
          item.name.css('cursor', 'pointer');
          _results.push(void 0);
        }
        return _results;
      }
    };

    Controller.prototype.bindSaves = function() {
      return this.view.elements.saves.on('click', '.btn', this.model, function(event) {
        var el, model;
        model = event.data;
        el = $(this);
        switch (el.attr("act")) {
          case "new":
            return model.newSave();
          case "load":
            return model.loadSave(el.attr("id"));
          case "delete":
            return model.deleteSave(el.attr("id"));
        }
      });
    };

    Controller.prototype.bindSettingsGenerate = function(name, type) {
      switch (type) {
        case "number":
          return (function(_this) {
            return function() {
              return _this.model.setSettings(name, _this.view.elements.settings[name].value);
            };
          })(this);
        case "checkbox":
          return (function(_this) {
            return function() {
              return _this.model.setSettings(name, _this.view.elements.settings[name].checked);
            };
          })(this);
        default:
          return (function(_this) {
            return function() {};
          })(this);
      }
    };

    Controller.prototype.bindSettings = function(elem, name, type, def) {
      elem = $("#" + name);
      switch (type) {
        case "number":
          elem.val(def);
          elem.keyup(this.bindSettingsGenerate(name, type));
          break;
        case "checkbox":
          elem[0].checked = def;
          elem.on('click', this.bindSettingsGenerate(name, type));
          break;
      }
      return void 0;
    };

    return Controller;

  })();

  window.Controller = Controller;

}).call(this);

//# sourceMappingURL=controller.map
