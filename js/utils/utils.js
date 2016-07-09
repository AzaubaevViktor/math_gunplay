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

  window.MGDebug = function() {
    console.group('DEBUG');
    if (window.mgModelSettings != null) {
      console.info('window.mgModelSettings:');
      console.log(JSON.stringify(window.mgModelSettings));
    } else {
      console.warn('Model Settings not found');
    }
    if (window.mgModel != null) {
      console.info('window.mgModel:');
      console.log(JSON.stringify(window.mgModel));
    } else {
      console.warn('Model not found');
    }
    if (window.snapshotter != null) {
      console.info('window.snapshotter OK');
    } else {
      console.warn('Snapshotter not found');
    }
    if (window.mgViewSettings != null) {
      console.info('window.mgViewSettings:');
      console.log(JSON.stringify(window.mgViewSettings));
    } else {
      console.warn('ViewSettings not found');
    }
    if (window.mgView != null) {
      console.info('window.mgView:');
      console.log(JSON.stringify(window.mgView));
    } else {
      console.warn('View not found');
    }
    if (window.mgController != null) {
      console.info('window.mgController:');
      console.log(JSON.stringify(window.mgController));
    } else {
      console.warn('Controller not found');
    }
    return console.groupEnd();
  };

}).call(this);

//# sourceMappingURL=utils.js.map
