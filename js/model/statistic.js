// Generated by CoffeeScript 1.8.0
(function() {
  var __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  define(["tools/tools", "tools/jsonify"], function(Tools, JSONify) {
    var Statistic, getValScope;
    getValScope = Tools.getValScope;
    Statistic = (function(_super) {
      __extends(Statistic, _super);

      function Statistic(_at__players) {
        this._players = _at__players;
        this._statsText = {
          "all_damage": "Урона нанесено: ",
          "all_tasks": "Сыгранные задачи: ",
          "all_treat": "Вылеченно здоровья: ",
          "solve_percent": "Решённые/все задачи: "
        };
        this.stats = {
          "all_damage": 0,
          "all_tasks": 0,
          "all_treat": 0,
          "solve_percent": 0
        };
        this.solved = 0;
        this.unsolved = 0;
        this.className = "Statistic";
        this.JSONProperties = ["stats", "solved", "unsolved"];
        this.register(Statistic);
      }

      Statistic.prototype.binds = function() {
        return this._bind_damage();
      };

      Statistic.prototype._solved_update = function() {
        this.stats.all_tasks = this.solved + this.unsolved;
        return this.stats.solve_percent = this.solved / (this.solved + this.unsolved);
      };

      Statistic.prototype._bind_damage = function() {
        var id, player, _ref, _results;
        _ref = this._players;
        _results = [];
        for (id in _ref) {
          player = _ref[id];
          if ("length" !== id) {
            player.eventBind(["attack"], (function(_this) {
              return function(playerFrom, playerTo, value, type) {
                return _this.stats.all_damage += value;
              };
            })(this));
            player.eventBind(["solveChanged"], (function(_this) {
              return function(pF, pT, value, type) {
                console.log("hi " + value);
                _this.solved += value;
                return _this._solved_update();
              };
            })(this));
            player.eventBind(["unsolveChanged"], (function(_this) {
              return function(pF, pT, value, type) {
                _this.unsolved += value;
                return _this._solved_update();
              };
            })(this));
            _results.push(player.eventBind(["treat"], (function(_this) {
              return function(pF, pT, value, type) {
                return _this.stats.all_treat += value;
              };
            })(this)));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      return Statistic;

    })(JSONify.JSONify);
    return Statistic;
  });

}).call(this);

//# sourceMappingURL=statistic.js.map