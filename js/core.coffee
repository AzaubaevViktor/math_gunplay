getValScope = (val, scope) ->
  if scope[0] > val
    return scope[0]
  else if scope[1] < val
    return scope[1]
  (val)

deepCopy = (v) ->
  ($.extend true, [], v)



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

    (undefined)

  joinView: (@view) ->

  # Snapshots

  forwardSnapshot: () ->
    @snapshotPoint += 1
    @loadSnapshot @snapshotPoint

  loadSnapshot: (snapshotN = @snapshotPoint - 1) ->
    @snapshotPoint = snapshotN
    {@isGame, @isDay, @players} = @snapshots[@snapshotPoint]

    @view.updateUI()
    (undefined)

  addSnapshot: () ->
    @snapshotPoint += 1
    @snapshots[@snapshotPoint..] = {
      'isGame': @isGame
      'isDay': @isDay
      'players': deepCopy @players
    }

    if @view
      @view.snapshotButtons()
    (undefined)

  clearSnapshots: ->
    @snapshotPoint = -1
    @snapshots = []
    @addSnapshot()
    (undefined)

  # Day/Night

  setDayTimer: () ->
    @time = @stTime
    @view.updateTime()
    @timer = setInterval (_this) ->
      _this.time -= 1
      if _this.time <= 0
        _this.changeDayNight()
      else
        _this.view.updateTime()
      undefined
    , 1000, @
    (undefined)

  changeDayNight: ->
    clearInterval @timer

    if not @isGame
      @isGame = true
      @isDay = true
    else
      @isDay = not @isDay

    if @isDay
      @setDayTimer()

    @clearSnapshots()

    @view.updateUI()
    (undefined)

  # Players

  # sets

  setHealth: (plN, health) ->
    @players[plN].health = getValScope health, [0, 1]
    (undefined)

  # gets

  getLevel: (plN) ->
    if plN != -1
      h = @players[plN].health
      for level, scope of @levels
        if scope[0] < h <= scope[1]
          return level
    (undefined)

  getAttack: (plN) ->
    pl = @players[plN]
    (getValScope 10 + pl.solve - pl.unsolve - 3 * pl.treatment, [0, 20]) / 100

  getAttackTo: (plN, plN2) ->
    if (0 == @players[plN].health) or ((@getLevel plN) != (@getLevel plN2))
      return 0

    (@getAttack plN)

  getTreat: (plN, solved) ->
    pl = @players[plN]
    h = 5 * solved + pl.solve - pl.unsolve - 3 * pl.treatment - 5

    if (@getLevel plN) == 'hospital'
      h += 10
    ((getValScope h, [-Infinity, Infinity]) / 100)

  # actions

  treat: (plN, solved) ->
    pl = @players[plN]

    inc = @getTreat plN, solved

    @setHealth plN, pl.health + inc

    if (@getLevel plN) == "resuscitation"
      pl.treatment = 0
    else
      pl.treatment += 1

    @addSnapshot()

    @view.treat plN, inc
    (undefined)

  hit: (plN1, plN2) ->
    pl1 = @players[plN1]
    pl2 = @players[plN2]

    atk = @getAttackTo plN1, plN2

    @setHealth plN2, pl2.health - atk

    pl1.solve += 1

    @view.hit plN1, plN2, -atk

    @addSnapshot()

    (undefined)

  miss: (plN1) ->
    pl1 = @players[plN1].unsolve += 1

    @view.miss plN1

    @addSnapshot()

    (undefined)

  addPlayer: (name) ->
    @players.push {
      name: name
      id: @players.length
      health: 1
      solve: 0
      unsolve: 0
      treatment: 0
    }

    @view.updateUI()

    (undefined)



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

    @nightMode = {
      is: false
      selected: -1
      attack: -1
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
    (undefined)

  joinModel: (@model) ->

  joinController: (@controller) ->

  updateUI: ->
    @snapshotButtons()
    if not @model.isGame
      @beforeGameUI()
    else
      if @model.isDay
        @dayUI()
      else
        @nightUI()
    (undefined)

  placeTest: ->
    # Проверяет, появились ли новые игроки и нужны ли для них новые места. Если так, создаёт эти места и биндит нужные действия
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
          actions: {
            this: listItem.find ".actions"
            solve: listItem.find ".solve"
            unsolve: listItem.find ".unsolve"
            treat: [
              listItem.find ".treat0"
              listItem.find ".treat1"
              listItem.find ".treat2"
              listItem.find ".treat3"
            ]
          }
        }
        place.list[-1..][0].actions.this.hide()

    (undefined)

  snapshotButtons: ->
    if @model.snapshotPoint != 0
      @elements.buttons.backward.show(500)
    else
      @elements.buttons.backward.hide(500)

    if @model.snapshotPoint != (@model.snapshots.length - 1)
      @elements.buttons.forward.show(500)
    else
      @elements.buttons.forward.hide(500)

    (undefined)

  beforeGameUI: ->
    @nightMode.is = false
    listById = @model.players

    @elements.carousel.this.hideControls()
    @elements.carousel.this.go 0
    @elements.carousel.this.pause()

    @elements.blocks.newPlayer.show 500

    @elements.buttons.daynight.text "Начать игру!"

    @placeTest()
    @placePlayers [listById]
    (undefined)

  dayUI: ->
    @nightMode.is = false
    @nightMode.attack = -1
    @nightMode.selected = -1
    @elements.carousel.this.showControls()
    @elements.carousel.this.go 0
    @elements.carousel.this.start()

    @elements.blocks.newPlayer.hide 500

    getSortF = (item) ->
      (a, b) ->
        b[item] - a[item]

    listById = @model.players

    listByHealth = deepCopy(listById)
    listByHealth.sort(getSortF('health'))

    listBySolve = deepCopy(listById)
    listBySolve.sort(getSortF('solve'))

    listByUnsolve = deepCopy(listById)
    listByUnsolve.sort(getSortF('unsolve'))

    @placePlayers [listById, listByHealth, listBySolve, listByUnsolve]
    (undefined)

  nightUI: ->
    @nightMode.is = true
    @controller.bindNight()

    @elements.carousel.this.hideControls()
    @elements.carousel.this.go 0
    @elements.carousel.this.pause()

    @elements.blocks.newPlayer.hide 500

    listById = @model.players

    @elements.buttons.daynight.text "Ночь"

    @placePlayers [listById]
    (undefined)

  placePlayers: (lists) ->
    for list, l in lists
      place = @elements.places[l]

      attackLevel = @model.getLevel @nightMode.attack

      for player, p in list
        listItem = place.list[p]

        listItem.id.text (player.id + 1)
        listItem.name.text player.name
        if @nightMode.is and (p == @nightMode.selected)
          listItem.health.hide()
          listItem.attack.hide()
          listItem.tasks.hide()
          listItem.actions.this.show()
        else
          listItem.health.show().text (player.health * 100).toFixed(0)
          listItem.attack.show().text ((@model.getAttack player.id) * 100).toFixed(0)
          listItem.tasks.show().text "#{player.solve}/#{player.unsolve}"
          listItem.actions.this.hide()
        listItem.this.removeClass().addClass @model.getLevel player.id

        if (@nightMode.attack != -1) and (attackLevel != @model.getLevel p)
          listItem.this.addClass("not").prop("disabled":true)
        else
          listItem.this.removeClass("not")

        listItem.this.show(500)
        (undefined)
      (undefined)
    (undefined)

  updateTime: ->
    minutes = @model.time % 60
    minutes = if minutes < 10 then "0" + minutes else minutes
    @elements.buttons.daynight.text "День (#{@model.time//60}:#{minutes})"
    (undefined)

  hit: (plN1, plN2, atk) ->
    console.log "BADABOOM #{plN1} ====> #{plN2}"
    @nightMode.attack = -1
    @nightMode.selected = -1
    @updateUI()
    @popup plN2, "health", (atk * 100)
    (undefined)

  miss: (plN) ->
    console.log "PHAHAHA #{plN}"
    @nightMode.selected = -1
    @nightMode.attack = -1
    @updateUI()
    @popup plN, "name", "Мазила"
    (undefined)

  treat: (plN, inc) ->
    @nightMode.attack = -1
    @nightMode.selected = -1
    @updateUI()
    @popup plN, "health", (inc * 100)
    (undefined)

  popup: (plN, selector, text) ->
    el = @elements.places[0].list[plN][selector]
    left = el.offset().left + el.width() / 2
    top = el.offset().top - el.height() / 2

    if $.isNumeric text
      text = text.toFixed(0)
      if text >= 0
        text = "+" + text

    el.append "<div id='popup'
      class='#{if text >= 0 then 'green' else 'red'}'
      style='opacity:0'>#{text}</div>"
    popup = $ "#popup"
    popup.offset {top: top, left: left}

    # animation
    _this = @
    (popup.animate {
      opacity: [1, "swing"]
      top: ["-=20px", "linear"]
    }, 1000).animate {
        opacity: [0, "swing"]
        top: ["-=20px", "linear"]
      }, 1000, "linear", () ->
        popup.remove()


  attackMode: (plN) ->
    if (-1 == @nightMode.attack)
      @nightMode.attack = plN
    else
      @nightMode.attack = - 1
      @nightMode.selected = -1

    @updateUI()
    (undefined)

  selectMode: (plN) ->
    if -1 != @nightMode.attack
      @model.hit @nightMode.attack, plN
    else
      @nightMode.selected =
        if plN == @nightMode.selected then -1 else plN
      @updateUI()
    (undefined)



class Controller
  constructor: ->
    @isBindNight = 0

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
      (undefined)

    # Кнопка, сменяющая день/ночь вручную и начинающая игру
    @view.elements.buttons.daynight.click ->
      _this.model.changeDayNight()

    @view.elements.buttons.forward.click ->
      _this.model.forwardSnapshot()

    @view.elements.buttons.backward.click ->
      _this.model.loadSnapshot()

    (undefined)

  bindNight: ->
    if not @isBindNight
      @isBindNight = 1
      place = @view.elements.places[0]
      for item, plN in place.list

        item.actions.unsolve.on 'click', {plN: plN, _this: @}, (event) ->
          {plN, _this: {model}} = event.data
          model.miss(plN)

        item.actions.solve.on 'click', {plN: plN, _this: @}, (event) ->
          {plN, _this: {view}} = event.data
          view.attackMode plN

        for tr, solved in item.actions.treat
          tr.on 'click', {plN: plN, _this: @, solved: solved}, (event) ->
            {plN, _this: {model}, solved} = event.data
            model.treat(plN, solved)
          (undefined)

        item.this.on 'click', "td:not(.actions)", {plN: plN, _this: @}, (event) ->
          {plN, _this: {view, model}} = event.data

          view.selectMode plN

        item.id.css('cursor','pointer')
        item.name.css('cursor','pointer')
        (undefined)


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
    @elem.find(".carousel-control").fadeOut(500)
    @elem.find(".carousel-indicators").fadeOut(500)
    undefined

  showControls: ->
    @elem.find(".carousel-control").fadeIn(500)
    @elem.find(".carousel-indicators").fadeIn(500)
    undefined


($ document).ready ->
  console.log "I'm alive!"
  jQuery.fx.interval = 40

  model = new Model()
  view = new View()
  controller = new Controller()

  model.joinView view
  view.joinModel model
  view.joinController controller
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

  ($ ".navbar-btn").tooltip()
  ($ ".with-tooltip").tooltip()

  ($ "#version").text __version__

  # Test
  view.updateUI()
  model.addPlayer("Математики")
  model.addPlayer("Лунатики")
  model.addPlayer("Пузатики")

  undefined
