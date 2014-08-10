__settingsVer__ = 0
__savesVer__ = 0

class Model

  constructor: () ->
    @isDay = false
    @isGame = false
    @time = 0
    @timer = undefined
    @players = []

    @initSettings()
    @initSaves()

    @snapshots = []
    @snapshotPoint = -1

    @levels = {
      square: [0.6, 1]
      hospital: [0.3, 0.6]
      resuscitation: [0, 0.3]
      morgue: [-10000, 0]
    }

    @view = undefined

    @addSnapshot()

    (undefined)


  # Saves
  initSaves: () ->
    @saves = JSON.parse localStorage.getItem 'saves'

    if @saves and (@saves.version != __savesVer__)
      @saves = null

    if @saves == null
      @saves = {
        version: __savesVer__
        ids: {}
      }
      localStorage.setItem 'saves', JSON.stringify @saves

  newSave: () ->
    id = 1853
    while id of @saves.ids
      id = Math.floor(Math.random() * 100000000000000000)

    @writeSave(id)

  writeSave: (id) ->
    now = new Date

    @saves.ids[id] = "#{now}"
    localStorage.setItem "saves", JSON.stringify @saves
    localStorage.setItem "save#{id}", JSON.stringify @players

    @view.updateSaves()

  deleteSave: (id) ->
    delete @saves.ids[id]
    localStorage.setItem "saves", JSON.stringify @saves
    localStorage.setItem "save#{id}", ""

    @view.updateSaves()


  loadSave: (id) ->
    _players = JSON.parse localStorage.getItem "save#{id}"

    if (not @isGame) or (not @isDay)
      @changeDayNight()

    @players = []

    for i in [0.._players.length-1]
      @addPlayer("")

    @players = _players

    # нужно, чтобы все перехуячивалось. :(

    @view.updateUI()

  # Settings

  initSettings: () ->
    @settings = JSON.parse localStorage.getItem 'settings'

    if @settings and (@settings.version != __settingsVer__)
      @settings = null

    if @settings == null
      @settings = {
        version: __settingsVer__
        stTime: 15
        maxAttack: 20
        selfDestroyAttack: true
        selfDestroyTreat: true
        selfDestroyResuscitation: false
        hospitalPlus10: true
        nullResus: true
      }
      localStorage.setItem 'settings', JSON.stringify @settings

    @settingsDesc = {
      info: {
        type: "text"
        before: "Помните: настройки обновляются <b>сразу</b>!"
      }
      wiki: {
        type: "text"
        before: "<a href='https://github.com/ktulhy-kun/math_gunplay/wiki'>Как играть</a>"
      }
      stTime: {
        type: "number"
        before: "Продолжительность дня"
        after: "мин"
        def: "20"
        help: "Если вы меняете это поле днём, то изменения вступят в силу только на <b>следующий</b> день"
      }
      maxAttack: {
        type: "number"
        before: "Максимальная атака"
        after: "%"
        def: "15"
      }
      selfDestroyAttack: {
        type: "checkbox"
        after: "Самоубийство (Атака)"
      }
      selfDestroyTreat: {
        type: "checkbox"
        after: "Самоубийство (Лечение)"
      }
      selfDestroyResuscitation: {
        type: "checkbox"
        after: "Самоубийство (Реанимация)"
      }
      hospitalPlus10: {
        type: "checkbox"
        after: "Дополнительные +10 при лечении в госпитале"
      }
      nullResus: {
        type: "checkbox"
        after: "Обнуление количества решений при лечении в реанимации"
      }
      attackFormula: {
        type: "text"
        before: "Формула расчёта урона:<br>min (10 + Р - Н - 3 * Л, МАКСУРОН)"
        help: "Р -- кол-во решённых задач<br>
        Н -- кол-во нерешённых задач<br>
        Л -- кол-во попыток лечения<br>
        МАКСУРОН -- максимальный урон, см. выше"
      }
      treatFormula: {
        type: "text"
        before: "Формула расчёта лечения:<br>5 * У + Р - Н - 3 * Л - 5"
        help: "У -- кол-во решённых задач из 3-х, остальное см. выше"
      }
      github: {
        type: "text"
        before: "<a href='https://github.com/ktulhy-kun/math_gunplay'>Исходный код</a>"
      }
    }

    (undefined)

  setSettings: (name, val) ->
    @settings[name] = val
    localStorage.setItem 'settings', JSON.stringify @settings
    (undefined)

  joinView: (@view) ->

  # Snapshots

  forwardSnapshot: () ->
    @snapshotPoint += 1
    @loadSnapshot @snapshotPoint
    (undefined)

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
    @time = @settings.stTime * 60
    @view.updateTime()
    @timer = setInterval =>
      @time -= 1
      if @time <= 0
        @changeDayNight()
      else
        @view.updateTime()
      undefined
    , 1000
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

  getAttackWithoutTreat: (plN) ->
    pl = @players[plN]
    (getValScope 10 + pl.solve - pl.unsolve, [0, @settings.maxAttack]) / 100

  getAttack: (plN) ->
    pl = @players[plN]
    (getValScope 10 + pl.solve - pl.unsolve - 3 * pl.treatment, [0, @settings.maxAttack]) / 100

  getAttackTo: (plN, plN2) ->
    if (0 == @players[plN].health) or ((@getLevel plN) != (@getLevel plN2))
      return 0

    if (plN == plN2)
      if (@getLevel plN) == "resuscitation"
        if not @settings.selfDestroyResuscitation
          return 0

      if (not @settings.selfDestroyAttack)
        return 0

    (@getAttack plN)

  getTreat: (plN, solved) ->
    pl = @players[plN]
    h = 5 * solved + pl.solve - pl.unsolve - 3 * pl.treatment - 5
    h /= 100

    if ((@settings.hospitalPlus10) and ((@getLevel plN) == 'hospital'))
      console.log "+10!"
      h += 0.1

    if (not @settings.selfDestroyTreat)
      h = getValScope h, [0, Infinity]

    h = getValScope h, [-Infinity, 1 - pl.health]

    (h)

  # actions

  treat: (plN, solved) ->
    pl = @players[plN]

    inc = @getTreat plN, solved

    @setHealth plN, pl.health + inc

    if ((@settings.nullResus) and ((@getLevel plN) == "resuscitation"))
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


window.Model = Model
