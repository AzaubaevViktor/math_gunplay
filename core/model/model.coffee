class Model

  constructor: (@settings, @statistic) ->
    @isDay = false
    @isGame = false
    @time = 0
    @timer = undefined
    @players = "length": 0

    @settings = new Settings(settingsDesc)

    @statistic = new Statistic(@players)

    (undefined)

  addPlayer: (name) ->
    id = @players.length

    @players[id] = new Player(id, name, @settings)
    @players.length += 1

    (undefined)

  startGame: ->
    @statistic.binds()

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



window.Model.Model = Model
