// Generated by CoffeeScript 1.7.1
(function() {
  var Model, __savesVer__, __settingsVer__;

  __settingsVer__ = 0;

  __savesVer__ = 0;

  Model = (function() {
    function Model() {
      this.isDay = false;
      this.isGame = false;
      this.time = 0;
      this.timer = void 0;
      this.players = [];
      this.initSettings();
      this.initSaves();
      this.snapshots = [];
      this.snapshotPoint = -1;
      this.levels = {
        square: [0.6, 1],
        hospital: [0.3, 0.6],
        resuscitation: [0, 0.3],
        morgue: [-10000, 0]
      };
      this.view = void 0;
      this.addSnapshot();
      void 0;
    }

    Model.prototype.initSaves = function() {
      this.saves = JSON.parse(localStorage.getItem('saves'));
      if (this.saves && (this.saves.version !== __savesVer__)) {
        this.saves = null;
      }
      if (this.saves === null) {
        this.saves = {
          version: __savesVer__,
          ids: {}
        };
        return localStorage.setItem('saves', JSON.stringify(this.saves));
      }
    };

    Model.prototype.newSave = function() {
      var id;
      id = 1853;
      while (id in this.saves.ids) {
        id = Math.floor(Math.random() * 100000000000000000);
      }
      return this.writeSave(id);
    };

    Model.prototype.writeSave = function(id) {
      var now;
      now = new Date;
      this.saves.ids[id] = "" + now;
      localStorage.setItem("saves", JSON.stringify(this.saves));
      localStorage.setItem("save" + id, JSON.stringify(this.players));
      return this.view.updateSaves();
    };

    Model.prototype.deleteSave = function(id) {
      delete this.saves.ids[id];
      localStorage.setItem("save" + id, "");
      return this.view.updateSaves();
    };

    Model.prototype.loadSave = function(id) {
      var i, _i, _players, _ref;
      _players = JSON.parse(localStorage.getItem("save" + id));
      if ((!this.isGame) || (!this.isDay)) {
        this.changeDayNight();
      }
      this.players = [];
      for (i = _i = 0, _ref = _players.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.addPlayer("");
      }
      this.players = _players;
      return this.view.updateUI();
    };

    Model.prototype.initSettings = function() {
      this.settings = JSON.parse(localStorage.getItem('settings'));
      if (this.settings && (this.settings.version !== __settingsVer__)) {
        this.settings = null;
      }
      if (this.settings === null) {
        this.settings = {
          version: __settingsVer__,
          stTime: 15,
          maxAttack: 20,
          selfDestroyAttack: true,
          selfDestroyTreat: true,
          hospitalPlus10: true,
          nullResus: true
        };
        localStorage.setItem('settings', JSON.stringify(this.settings));
      }
      this.settingsDesc = {
        info: {
          type: "text",
          before: "Помните: настройки обновляются <b>сразу</b>!"
        },
        stTime: {
          type: "number",
          before: "Продолжительность дня",
          after: "мин",
          def: "20",
          help: "Если вы меняете это поле днём, то изменения вступят в силу только на <b>следующий</b> день"
        },
        maxAttack: {
          type: "number",
          before: "Максимальная атака",
          after: "%",
          def: "15"
        },
        selfDestroyAttack: {
          type: "checkbox",
          after: "Уничтожение самого себя (Атака)"
        },
        selfDestroyTreat: {
          type: "checkbox",
          after: "Уничтожение самого себя (Лечение)"
        },
        hospitalPlus10: {
          type: "checkbox",
          after: "Дополнительные +10 при лечении в госпитале"
        },
        nullResus: {
          type: "checkbox",
          after: "Обнуление количества решений при лечении в реанимации"
        },
        attackFormula: {
          type: "text",
          before: "Формула расчёта урона:<br>min (10 + Р - Н - 3 * Л, МАКСУРОН)",
          help: "Р -- кол-во решённых задач<br> Н -- кол-во нерешённых задач<br> Л -- кол-во попыток лечения<br> МАКСУРОН -- максимальный урон, см. выше"
        },
        treatFormula: {
          type: "text",
          before: "Формула расчёта лечения:<br>5 * У + Р - Н - 3 * Л - 5",
          help: "У -- кол-во решённых задач из 3-х, остальное см. выше"
        },
        github: {
          type: "text",
          before: "<a href='https://github.com/ktulhy-kun/math_gunplay'>Исходный код</a>"
        }
      };
      return void 0;
    };

    Model.prototype.setSettings = function(name, val) {
      this.settings[name] = val;
      localStorage.setItem('settings', JSON.stringify(this.settings));
      return void 0;
    };

    Model.prototype.joinView = function(view) {
      this.view = view;
    };

    Model.prototype.forwardSnapshot = function() {
      this.snapshotPoint += 1;
      this.loadSnapshot(this.snapshotPoint);
      return void 0;
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
      this.time = this.settings.stTime * 60;
      this.view.updateTime();
      this.timer = setInterval((function(_this) {
        return function() {
          _this.time -= 1;
          if (_this.time <= 0) {
            _this.changeDayNight();
          } else {
            _this.view.updateTime();
          }
          return void 0;
        };
      })(this), 1000);
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
      if ((!this.settings.selfDestroyAttack) && (plN === plN2)) {
        return 0;
      }
      return this.getAttack(plN);
    };

    Model.prototype.getTreat = function(plN, solved) {
      var h, pl;
      pl = this.players[plN];
      h = 5 * solved + pl.solve - pl.unsolve - 3 * pl.treatment - 5;
      if (this.settings.hospitalPlus10 && ((this.getLevel(plN)) === 'hospital')) {
        console.log("+10!");
        h += 10;
      }
      if (!this.settings.selfDestroyTreat) {
        h = getValScope(h, [0, Infinity]);
      }
      h = getValScope(h, [-Infinity, 1 - pl.health]);
      return (getValScope(h, [-Infinity, Infinity])) / 100;
    };

    Model.prototype.treat = function(plN, solved) {
      var inc, pl;
      pl = this.players[plN];
      inc = this.getTreat(plN, solved);
      this.setHealth(plN, pl.health + inc);
      if (this.settings.nullResus && ((this.getLevel(plN)) === "resuscitation")) {
        pl.treatment = 0;
      } else {
        pl.treatment += 1;
      }
      this.addSnapshot();
      this.view.treat(plN, inc);
      return void 0;
    };

    Model.prototype.hit = function(plN1, plN2) {
      var atk, pl1, pl2;
      pl1 = this.players[plN1];
      pl2 = this.players[plN2];
      atk = this.getAttackTo(plN1, plN2);
      this.setHealth(plN2, pl2.health - atk);
      pl1.solve += 1;
      this.view.hit(plN1, plN2, -atk);
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

  window.Model = Model;

}).call(this);

//# sourceMappingURL=model.map
