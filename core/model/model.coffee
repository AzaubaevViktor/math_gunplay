Player = Model.Player
Statistic = Model.Statistic
Snapshot = Model.Snapshot

class _Model

  constructor: (@settings) ->
    @isDay = false
    @isGame = false
    @time = 0
    @timer = undefined
    @players = "length": 0

    @statistic = new Statistic(@players)

    structure_snapshot =
      model:
        obj: this
        fields: ['players', 'statistic']

    @snapshots = new Snapshot(structure_snapshot)


    (undefined)

  addPlayer: (name) ->
    id = @players.length

    @players[id] = new Player(id, name, @settings)
    @players.length += 1

    (undefined)

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
      @isGame = true
      @isDay = true
    else
      @isDay = not @isDay

    if @isDay
      @setDayTimer()

    @snapshots.clear()
    (undefined)



window.Model.Model = _Model
