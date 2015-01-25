__settingsVer__ = 0
__savesVer__ = 0

levels =
  square: [0.6, 1]
  hospital: [0.3, 0.6]
  resuscitation: [0, 0.3]
  morgue: [-10000, 0]

penalties = [
  {
    "treat": 0
    "attack": 0
  },
  {
    "treat": 0.01
    "attack": 3
  },
  {
    "treat": 0.03
    "attack": 6
  },
  {
    "treat": 0.05
    "attack": 9
  },
  {
    "treat": 0.1
    "attack": 12
  }
]


class Player
  constructor: (@id, @name, @settings, @statistic) ->
    @health = 1
    @solved = @unsolved = @treatment = penalties = 0

  setHealth: (health) ->
    @health = getValScope health [0, 1]

  incTreatment: () ->
    if ((@settings.get nullResus) and (@getLevel == "resuscitation"))
      @treatment = 0
    else
      @treatment += 1

  getHealth: () ->
    @health

  getLevel: () ->
    for level, scope of levels
      if scope[0] < @health <= scope[1]
        return level
    undefined

  _rawAttack: () ->
    # Функция подсчёта урона
    penalty = penalties[pl.penalties].attack
    10 + @solved - @unsolved - penalty - 3 * @treatment

  getAttackWithoutTreat: () ->
    #TODO: разобраться зачем мне эта функция
    (getValScope @_rawAttack + 3 * @treatment, [0, @settings.get maxAttack]) / 100

  getAttack: () ->
    (getValScope @_rawAttack, [0, @settings.get maxAttack]) / 100

  getAttackTo: (player) ->
    switch
      when 0 == @health then 0
      when @getLevel != player.getLevel then 0
      when (@id == player.id) and (@getlevel == "resuscitation") and not @settings.selfDestroyResuscitation then 0
      when (@id == player.id) and not @settings.selfDestroyAttack then 0
      else @getAttack

  _rawTreat: (solved) ->
    # Функция подсчёта жизней
    5 * solved + @solved - @unsolved - 3 * @treatment - 5

  getTreat: (solved) ->
    h = _rawTreat solved
    h += ("hospital" == @getLevel) * (@settings.get hospitalPlus10) * 10
    h = getValScope h, [(if @settings.selfDestroyTreat then -Infinity else 0),
                        1 - @health]

  treat: (solved) ->
    inc = getTreat solved
    @setHealth @health + inc
    @incTreatment()

    #TODO: Statistic

  hit: (player) ->
    dmg = @getAttackTo player
    player.setHealth player.health - dmg
    @solved += 1

    #TODO: Statistic

  miss: () ->
    @unsolved += 1
    #TODO: Statistic

  penalty: () ->
    @penalty = getValScope @penalties += 1, [0, penalties.lenght - 1]




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

    @stats = {
      "all_damage": {
        "title": "Урона нанесено: "
        "value": 0
      }
      "all_tasks": {
        "title": "Сыгранные задачи: "
        "value": 0
      }
      "all_treat": {
        "title": "Вылеченно здоровья: "
        "value": 0
      }
      "solve_percent": {
        "title": "Решённые/все задачи: "
        "value": 0
      }
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
    localStorage.setItem "save#{id}", JSON.stringify {
      "players": @players
      "stats": @stats
    }

    @view.updateSaves()

  deleteSave: (id) ->
    delete @saves.ids[id]
    localStorage.setItem "saves", JSON.stringify @saves
    localStorage.setItem "save#{id}", ""

    @view.updateSaves()

  loadSave: (id) ->
    save = JSON.parse localStorage.getItem "save#{id}"
    _players = save.players
    @stats = save.stats

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
        after: "Обнуление количества лечений при лечении в реанимации"
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
    {@isGame, @isDay, players, stats} = @snapshots[@snapshotPoint]
    @players = deepCopy players
    @stats = deepCopy stats

    @view.updateUI()
    (undefined)

  addSnapshot: () ->

    @snapshots = @snapshots.slice(0, @snapshotPoint+1)

    @snapshots = @snapshots.concat({
      'isGame': @isGame
      'isDay': @isDay
      'players': deepCopy @players
      'stats': deepCopy @stats
    })

    @snapshotPoint += 1

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


  addPlayer: (name) ->
    @players.push {
      name: name
      id: @players.length
      health: 1
      solve: 0
      unsolve: 0
      treatment: 0
      penalties: 0
    }

    @view.updateUI()

    (undefined)

  changeName: (plN, newname) ->
    @players[plN].name = newname

    @view.updateUI()

    (undefined)


window.Model = Model
