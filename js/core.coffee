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
    @isDay = false
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

  forwardSnapshot: () ->
    @snapshotPoint += 1
    @loadSnapshot @snapshotPoint

  loadSnapshot: (snapshotN = @snapshotPoint - 1) ->
    @snapshotPoint = snapshotN
    {@isGame, @isDay, @players} = @snapshots[@snapshotPoint]

    if !@isDay
      @time = 0

    @view.updateUI()
    undefined

  addSnapshot: () ->
    @snapshotPoint += 1
    @snapshots[@snapshotPoint..] = {
      'isGame': @isGame
      'isDay': @isDay
      'players': deepCopy @players
    }

    if @view
      @view.snapshotButtons()
    undefined

  # Day/Night

  setDayTimer: () ->
    @time = @stTime
    @timer = setInterval (_this) ->
      _this.time -= 1
      if _this.time <= 0
        _this.changeDayNight
      else
        _this.view.updateTime()
      undefined
    , 1000, @

  changeDayNight: () ->
    clearInterval @timer

    if not @isGame
      @isGame = true
      @isDay = true
    else
      @isDay = not @isDay

    if @isDay
      @setDayTimer()

    @addSnapshot()

    @view.updateUI()

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

    @view.updateUI()
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
      id: @players.length
      health: 1
      solve: 0
      unsolve: 0
      treatment: 0
    }

    @addSnapshot()

    @view.updateUI()
    undefined



class View
  constructor: ->
    @elements = {
      buttons: {
        backward: $ "#backward"
        forward: $ "#forward"
        daynight: $ "#daynight"
      }

      inputs: {
        newPlayer: $ "#addplayer"
      }

      blocks: {
        newPlayer: $ ".pl-addplayer"
      }

      carousel: {
        this: new _Carousel($ "#carousel")
        items: [($ "#item0"), ($ "#item1"), ($ "#item2"), ($ "#item3")]
      }

      tables: [($ "#table0")]

      places: [{
        this: $ "#table0 > .pl-list"
        list: []
        }]

      templates: {
        players: ($ "#players-template").html()
        place: ($ "#place-template").html()
      }
    }

    items = @elements.carousel.items

    for item, ind in items[1..]
      item.html("<table id=\"table#{ind+1}\" class=\"table\">
          #{@elements.templates.players}
        </table>")
      @elements.tables.push $ "#table#{ind+1}"
      @elements.places.push {
        this: $ "#table#{ind+1} > .pl-list"
        list: []
        }

  joinModel: (@model) ->

  updateUI: ->
    @placeTest()
    @snapshotButtons()
    if not @model.isGame
      @beforeGameUI()
    else
      if @model.isDay
        @dayUI()
      else
        @nightUI()
    undefined

  placeTest: ->
    places = @elements.places
    if places[0].list.length < @model.players.length
      for place in places
        place.this.append(@elements.templates.place)
        listItem = place.this.find "tr:last-child"
        listItem.hide()
        place.list.push {
          this: listItem
          id: listItem.find ".id"
          name: listItem.find ".name"
          health: listItem.find ".health"
          attack: listItem.find ".attack"
          tasks: listItem.find ".tasks"
        }
    else if places[0].list.length > @model.players.length
      if places[0].list.length
        for place in places
          place.list[-1..][0].this.hide(500, -> @.remove())
          place.list.pop()

    undefined

  snapshotButtons: ->
    if @model.snapshotPoint != 0
      @elements.buttons.backward.show(500)
    else
      @elements.buttons.backward.hide(500)

    if @model.snapshotPoint != (@model.snapshots.length - 1)
      @elements.buttons.forward.show(500)
    else
      @elements.buttons.forward.hide(500)

  beforeGameUI: ->
    listById = @model.players

    @elements.carousel.this.hideControls()
    @elements.carousel.this.go 0
    @elements.carousel.this.pause()

    @elements.blocks.newPlayer.show 500

    @elements.buttons.daynight.text "Начать игру!"

    @placePlayers([listById, [] , [], []])

  dayUI: ->

    @elements.carousel.this.showControls()
    @elements.carousel.this.go 0
    @elements.carousel.this.start()

    @elements.blocks.newPlayer.hide 500

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

  placePlayers: (lists) ->
    for list, l in lists
      place = @elements.places[l]
      for player, p in list
        listItem = place.list[p]

        listItem.id.text player.id
        listItem.name.text player.name
        listItem.health.text player.health * 100
        listItem.attack.text (@model.getAttack player.id) * 100
        listItem.tasks.text "#{player.solve}/#{player.unsolve}"
        listItem.this.removeClass().addClass @model.getLevel player.id
        listItem.this.show(500)
        undefined
      undefined
    undefined

  updateTime: ->
    minutes = @model.time % 60
    minutes = if minutes < 10 then "0" + minutes else minutes
    @elements.buttons.daynight.text "День (#{@model.time//60}:#{minutes})"

  hit: ->

  miss: ->



class Controller
  constructor: ->

  joinModel: (@model) ->

  joinView: (@view) ->

  bind: ->
    _this = @

    input = @view.elements.inputs.newPlayer
    input.keyup (e) ->
      if 13 == e.keyCode
        name = input.val()
        input.val ""
        _this.model.addPlayer name
      undefined

    @view.elements.buttons.daynight.click () ->
      _this.model.changeDayNight()

    @view.elements.buttons.forward.click ->
      _this.model.forwardSnapshot()

    @view.elements.buttons.backward.click ->
      _this.model.loadSnapshot()


class _Carousel
  constructor: (@elem) ->

  start: ->
    @elem.carousel "cycle"

  pause: ->
    @elem.carousel "pause"

  go: (num) ->
    @elem.carousel num

  next: ->
    @elem.carousel "next"

  prev: ->
    @elem.carousel "prev"

  hideControls: ->
    @elem.find(".carousel-control").hide()
    @elem.find(".carousel-indicators").hide()
    undefined

  showControls: ->
    @elem.find(".carousel-control").show()
    @elem.find(".carousel-indicators").show()
    undefined


($ document).ready ->
  console.log "I'm alive!"

  model = new Model()
  view = new View()
  controller = new Controller()

  model.joinView view
  view.joinModel model
  controller.joinView view
  controller.joinModel model

  controller.bind()

  window.Model = Model
  window.View = View
  window.Controller = Controller
  window._Carousel = _Carousel
  window.model = model
  window.view = view
  window.controller = controller

  ($ "#version").text __version__

  # Test
  model.addPlayer("test1")
  model.addPlayer("test2")
  model.addPlayer("test3")
  model.getTreat(1, 2)

  undefined
