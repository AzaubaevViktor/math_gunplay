Player = Model.Player
Statistic = Model.Statistic
Snapshot = Model.Snapshot
Saves = Model.Saves

class _Model

  constructor: (@settings) ->
    @isDay = 0
    @isGame = 0
    @time = 0
    @timer = undefined
    @players = "length": 0

    @statistic = new Statistic(@players)

    structure_snapshot =
      model:
        obj: this
        fields: ['players', 'statistic']

    @snapshots = new Snapshot(structure_snapshot)

    structure_save =
      model:
        obj: this
        fields: ['players', 'statistic', 'isGame']

    @saves = new Saves(structure_save)

    (undefined)

  addPlayer: (name) ->
    id = @players.length

    @players[id] = new Player(id, name, @settings)
    @players.length += 1

    (undefined)

  save: () ->
    @saves.new()

  load: (id) ->
    @saves.load(id)

  savesList: ->
    @saves.getList()

  startGame: ->
#   Запускаем сбор сттистики
    @statistic.binds()
#   Запускаем снапшоты
    for player in @players
      player.setWatcher "_all", (t, o, n) =>
        @snapshots.add()

  undo: ->
    @snapshots.undo()

  redo: ->
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