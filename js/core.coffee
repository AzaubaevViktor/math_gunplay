getValScope = (val, scope) ->
  if scope[0] > val
    return scope[0]
  else if scope[1] < val
    return scope[1]
  val

deepCopy = (v) ->
  $.extend true, [], v

class Model

  constructor: () ->
    @isDay = true
    @isGame = false
    @stTime = 15 * 60
    @time = 0
    @timer = undefined
    @players = []
    @snapshots = []
    @snapshotPoint = -1
    @levels = {
      square: [0.8, 1]
      hospital: [0.3, 0.8]
      resuscitation: [0, 0.3]
      morgue: [-10000, 0]
    }
    @view = undefined

    @addSnapshot()

    undefined

  joinView: (@view) ->

  # Snapshots

  addSnapshot: () ->
    @snapshotPoint += 1
    @snapshots[@snapshotPoint..] = {
      'isDay': @isDay,
      'players': deepCopy @players
    }
    undefined

  loadSnapshot: (snapshotN = @snapshotPoint - 1) ->
    @snapshotPoint = snapshotN
    {@isDay, @players} = @snapshots[@snapshotPoint]

    @view.updateUi()
    undefined

  forwardSnapshot: () ->
    @snapshotPoint += 1
    @loadSnapshot @snapshotPoint

  # Day/Night

  setDayTimer: () ->
    @time = @stTime
    @timer = setInterval (_this) ->
      _this.time -= 1
      if ! _this.time
        clearTimeout _this.timer
        _this.changeDayNight
      else
        _this.view.updateTime()
      undefined
    , 1000, @

  changeDayNight: () ->
    if not @isGame
      @isGame = true
      @isDay = true
    else
      @isDay = not @isDay

    if @isDay
      @setDayTimer()

    @view.updateUi()

  # Players

  # sets

  setHealth: (plN, health) ->
    pl = @players[plN]
    pl.health = getValScope health, [0, 1]
    undefined

  # gets

  getLevel: (plN) ->
    h = @players[plN].health
    for level, scope of @levels
      if scope[0] < h <= scope[1]
        return level

  getAttack: (plN) ->
    pl = @players[plN]
    (getValScope 10 + pl.solve - pl.unsolve - 3 * pl.treatment, [0, 20]) / 100

  getTreat: (plN, solved) ->
    pl = @players[plN]
    h = 5 * solved + pl.solve - pl.unsolve - 3 * pl.treatment - 5

    if (@getLevel plN) == 'hospital'
      h += 10
    (getValScope h, [-Infinity, Infinity]) / 100

  # actions

  treat: (plN, solved) ->
    pl = @players[plN]
    @setHealth pl, pl.health + @getTreat plN, solved

    if @getLevel plN == "resuscitation"
      pl.treatment = 0
    else
      pl.treatment += 1

    @addSnapshot()

    @view.updateUi()
    undefined

  attack: (plN1, plN2) ->
    pl1 = @players[plN1]
    pl2 = @players[plN2]

    @setHealth plN2, pl2.health - @getAttack plN1

    pl1.solve += 1

    @view.hit plN1, plN2

    @addSnapshot()

  miss: (plN1) ->
    pl1 = @players[plN1]
    pl1.unsolve += 1

    @view.miss plN1

    @addSnapshot()

  addPlayer: (name) ->
    @players.push {
      name: name
      health: 1
      solve: 0
      unsolve: 0
      treatment: 0
    }

    @addSnapshot()

    @view.addPlayer()
    undefined



class View
  constructor: ->
    @elements = {
      buttons: {
        backward: $ "#backward"
        forward: $ "#forward"
        daynight: $ "#daynight"
      }
      objects: {
        plList: $ "#pl-list"
        plAddplayer: $ "#pl-addplayer"
        addPlayerInput: $ "#addplayer"
      }
      placeTemplate: ($ "#place-template").html()
    }
    @places = []

  joinModel: (@model) ->

  addPlayer: ->
    plList = @elements.objects.plList
    plList.append("
    <td id=\"place#{@places.length}>\"
      #{@elements.placeTemplate.replace}
    </td>")
    place = plList.find "#place#{@places.length}"
    placeObj = {
      this: place
      id: place.find "#id"
      name: place.find "#name"
      health: place.find "#health"
      attack: place.find "#attack"
      tasks: place.find "#tasks"
    }
    @places.push(placeObj)

    @placePlayers()

  placePlayers: (lists) ->
    for list, index in lists

  beforeGameUI: ->

  dayUI: ->
    getSortF = (a, b, item) ->
      (a, b) ->
        b['item'] - a['item']

    listById = @model.players
    listByHealth = deepCopy(listById)
    listByHealth.sort(getSortF('health'))
    listBySolve = deepCopy(listById)
    listBySolve.sort(getSortF('solve'))
    listByUnsolve = deepCopy(listById)
    listByUnsolve.sort(getSortF('unsolve'))
    @placePlayers([listById, listByHealth, listBySolve, listByUnsolve])


  nightUi: ->

  updateUi: ->
    if not isGame
      @beforeGameUI()
    else
      if isDay
        @dayUI()
      else
        @nightUI()

  updateTime: ->
    console.log("time: #{@model.time}")

  hit: ->

  miss: ->




($ document).ready ->
  console.log "I'm alive!"

  model = new Model()
  view = new View()

  model.joinView view
  view.joinModel model
  window.Model = Model
  window.View = View
  window.model = model
  window.view = view

  ($ "#version").text __version__

  # Test
  model.addPlayer("test1")
  model.addPlayer("test2")
  model.addPlayer("test3")
  model.getTreat(1, 2)

  undefined
