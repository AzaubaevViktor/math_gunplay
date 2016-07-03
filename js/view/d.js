Model.prototype.loadSave = function(id) {
      var i, save, _i, _players, _ref;
      save = JSON.parse(localStorage.getItem("save" + id));
      _players = save.players;
      this.stats = save.stats;
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
          selfDestroyResuscitation: false,
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
        wiki: {
          type: "text",
          before: "<a href='https://github.com/ktulhy-kun/math_gunplay/wiki'>Как играть</a>"
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
          after: "Самоубийство (Атака)"
        },
        selfDestroyTreat: {
          type: "checkbox",
          after: "Самоубийство (Лечение)"
        },
        selfDestroyResuscitation: {
          type: "checkbox",
          after: "Самоубийство (Реанимация)"
        },
        hospitalPlus10: {
          type: "checkbox",
          after: "Дополнительные +10 при лечении в госпитале"
        },
        nullResus: {
          type: "checkbox",
          after: "Обнуление количества лечений при лечении в реанимации"
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

    Model.prototype.joinView = function(_at_view) {
      this.view = _at_view;
    };

    Model.prototype.forwardSnapshot = function() {
      this.snapshotPoint += 1;
      this.loadSnapshot(this.snapshotPoint);
      return void 0;
    };

    Model.prototype.loadSnapshot = function(snapshotN) {
      var players, stats, _ref;
      if (snapshotN == null) {
        snapshotN = this.snapshotPoint - 1;
      }
      this.snapshotPoint = snapshotN;
      _ref = this.snapshots[this.snapshotPoint], this.isGame = _ref.isGame, this.isDay = _ref.isDay, players = _ref.players, stats = _ref.stats;
      this.players = deepCopy(players);
      this.stats = deepCopy(stats);
      this.view.updateUI();
      return void 0;
    };

    Model.prototype.addSnapshot = function() {
      this.snapshots = this.snapshots.slice(0, this.snapshotPoint + 1);
      this.snapshots = this.snapshots.concat({
        'isGame': this.isGame,
        'isDay': this.isDay,
        'players': deepCopy(this.players),
        'stats': deepCopy(this.stats)
      });
      this.snapshotPoint += 1;
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