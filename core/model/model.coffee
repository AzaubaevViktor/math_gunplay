storage = Tools.storage
JSONify = Tools.JSONify
Player = Model.Player
Statistic = Model.Statistic
Snapshot = Model.Snapshot
Saves = Model.Saves

class _Model extends JSONify

  constructor: (@settings) ->
    @className = "_Model"
    @JSONProperties = ["players", "statistic", "isGame"]
    @register _Model

    @isDay = 0
    @isGame = 0
    @time = 0
    @timer = undefined
    @players = "length": 0

    @statistic = new Statistic(@players)
    @snapshots = new Snapshot(this)
    @saves = new Saves(this)

    (undefined)

  addPlayer: (name) ->
#    Добавляет игрока в игру
    if @isGame then throw "Нельзя добавлять игроков во время игры"

    id = @players.length

    @players[id] = new Player(id, name, @settings)
    @players.length += 1

    (undefined)

  save: ->
#    Создаёт сохранение
    @saves.new()


  load: (id) ->
#    Загружает сохранение
    @saves.load id


  savesList: ->
#    Список сохранений
    @saves.getList()

  startGame: ->
#     Запускаем снапшоты
    for player in @players
      player.eventBind ["all"], (pF, pT, v) =>
        @snapshots.add()

#     Запускаем сбор сттистики
    @statistic.binds()

  undo: ->
#    На шаг назад
    @snapshots.undo()

  redo: ->
#    На шаг вперёд
    @snapshots.redo()

  # Day/Night

  setDayTimer: () ->
    @time = @settings.stTime * 60

    @timer = setInterval =>
      @time -= 1
      if @time <= 0
        @changeDayNight()
      else
        undefined
      undefined
    , 1000
    (undefined)

  changeDayNight: ->
    clearInterval @timer

    if not @isGame
      @isGame = 1
      @isDay = 1
    else
      @isDay = not @isDay

    if @isDay
      @setDayTimer()

    @snapshots.clear()
    (undefined)



window.Model.Model = _Model
