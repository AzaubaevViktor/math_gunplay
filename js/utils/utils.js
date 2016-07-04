// Generated by CoffeeScript 1.10.0
(function() {
  var Stor;

  window.getValScope = function(val, scope) {
    if (scope[0] > val) {
      return scope[0];
    } else if (scope[1] < val) {
      return scope[1];
    } else {
      return val;
    }
  };

  window.deepCopy = function(v) {
    return $.extend(true, [], v);
  };

  window.btn = function(act, text, color, callback) {
    return $("<a act='" + act + "'>").addClass("waves-effect waves-light btn " + color).text(text).on('click', callback);
  };

  Stor = (function() {
    function Stor() {}

    Stor.prototype.get = function(key) {
      return JSON.parse(localStorage.getItem(key));
    };

    Stor.prototype.set = function(key, obj) {
      return localStorage.setItem(key, JSON.stringify(obj));
    };

    Stor.prototype.remove = function(key) {
      return localStorage.removeItem(key);
    };

    return Stor;

  })();

  window.Stor = new Stor();

}).call(this);

//# sourceMappingURL=utils.js.map
