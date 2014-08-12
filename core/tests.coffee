class ViewNull
  constructor: ->

  updateUI: ->


model = new Model()
model.joinView(new ViewNull)

# Add player tests
console.groupCollapsed("Addplayer tests")
model.addPlayer("one player")
model.addPlayer("second player")
model.addPlayer("third player")
model.addPlayer("fourth player")
model.addPlayer("fifty player")




console.groupEnd()
