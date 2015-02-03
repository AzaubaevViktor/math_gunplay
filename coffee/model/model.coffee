define ["tools/storage",
        "tools/jsonify",
        "model/player",
        "model/statistic",
        "model/snapshot",
        "model/saves"], (storage, JSONify, Player, Statistic, Snapshot, Saves) ->

    class Model extends JSONify.JSONify

        constructor: (@settings) ->
            @className = "Model"
            @JSONProperties = ["players", "statistic", "isGame"]
            @register Model

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
    #        Добавляет игрока в игру
            if @isGame then throw "Нельзя добавлять игроков во время игры"

            id = @players.length

            @players[id] = new Player(id, name, @settings)
            @players.length += 1

            (undefined)

        save: ->
    #        Создаёт сохранение
            @saves.new()


        load: (id) ->
    #        Загружает сохранение
            @saves.load id


        savesList: ->
    #        Список сохранений
            @saves.getList()

        startGame: ->
    #         Запускаем снапшоты
            for player in @players
                player.eventBind ["all"], (pF, pT, v) =>
                    @snapshots.add()

    #         Запускаем сбор сттистики
            @statistic.binds()

        undo: ->
    #        На шаг назад
            @snapshots.undo()

        redo: ->
    #        На шаг вперёд
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


    return Model
