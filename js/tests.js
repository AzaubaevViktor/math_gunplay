// Generated by CoffeeScript 1.8.0
(function() {
  var ViewNull, model;

  ViewNull = (function() {
    function ViewNull() {}

    ViewNull.prototype.updateUI = function() {};

    return ViewNull;

  })();

  model = new Model();

  model.joinView(new ViewNull);

  console.groupCollapsed("Addplayer tests");

  model.addPlayer("one player");

  model.addPlayer("second player");

  model.addPlayer("third player");

  model.addPlayer("fourth player");

  model.addPlayer("fifty player");

  console.groupEnd();

}).call(this);

//# sourceMappingURL=tests.js.map
