# Игрок


define ["tools/tools", "tools/jsonify", "model/settings"], (Tools, JSONify, Settings) ->
    getValScope = Tools.getValScope
    remove = Tools.remove
    settingsDesc = Settings.settingsDesc

    EVENTS_DEBUG = false

    levels =
        square: [0.6, 1]
        hospital: [0.3, 0.6]
        resuscitation: [0, 0.3]
        morgue: [-10000, 0]

    penalties_list = [
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

    class Player extends JSONify.JSONify
        constructor: (@id = -1, @name = "ERR", @settings = settingsDesc) ->
            # TODO: убрать settingsDesc
            @_eventInit()
            @setHealth 1
            @solved = @unsolved = @treatment = @penalties = 0
            @className = "Player"
            @JSONProperties = ["id", "name", "health", "solved", "unsolved", "treatment", "penalties"]
            @register Player

        _rawAttack: () ->
            # Функция подсчёта урона
            penalty = penalties_list[@penalties].attack
            10 + @solved - @unsolved - penalty - 3 * @treatment

        _rawTreat: (solved) ->
            # Функция подсчёта жизней
            5 * solved + @solved - @unsolved - 3 * @treatment - 5

        setHealth: (health) ->
            _health = getValScope health, [0, 1]
            diff = _health - @health
            @health = _health
            @_eventGenerate("healthChanged", undefined, diff)

        getHealth: () ->
            @health

        getLevel: () ->
            for level, scope of levels
                return level if scope[0] < @getHealth() <= scope[1]
            undefined

        getAttackWithoutTreat: () ->
            #TODO: разобраться зачем мне эта функция
            (getValScope @_rawAttack() + 3 * @treatment, [0, @settings.maxAttack()]) / 100

        getAttack: () ->
            (getValScope @_rawAttack(), [0, @settings.maxAttack()]) / 100

        getAttackTo: (player) ->
            switch
                when 0 == @getHealth() then 0
                when @getLevel() != player.getLevel() then 0
                when (@id == player.id) and (@getLevel() == "resuscitation") and not @settings.selfDestroyResuscitation() then 0
                when (@id == player.id) and not @settings.selfDestroyAttack() then 0
                else @getAttack()

        hit: (player) ->
            dmg = @getAttackTo player
            player.setHealth player.getHealth() - dmg
            @solved += 1
            @_eventGenerate("attack", player, dmg)
            @_eventGenerate("attacked", undefined, dmg)
            @_eventGenerate("solveChanged", undefined , 1)

        miss: () ->
            @unsolved += 1
            @_eventGenerate("unsolveChanged", undefined , 1)

        getTreat: (solved) ->
            h = @_rawTreat solved
            h += ("hospital" == @getLevel()) * (@settings.hospitalPlus10()) * 10
            h = getValScope h, [(if @settings.selfDestroyTreat() then -Infinity else 0),
                                                    1 - @getHealth()]

        incTreatment: () ->
            if ((@settings.nullTreatIfTreatResuscitation()) and (@getLevel() == "resuscitation"))
                _treatment = -@treatment
            else
                _treatment = 1

            @treatment += _treatment
            @_eventGenerate("treatChanged", undefined, _treatment)

        treat: (solved) ->
            inc = @getTreat solved
            @setHealth @getHealth() + inc
            @incTreatment()
            @solve += solved
            @unsolved += 3 - solved
            @_eventGenerate("treat", undefined, inc)
            @_eventGenerate("solveChanged", undefined , solved)
            @_eventGenerate("unsolveChanged", undefined , 3 - solved)

        penalty: () ->
            @penalty = getValScope @penalties += 1, [0, penalties_list.lenght() - 1]
            @_eventGenerate("penalty", undefined, 1)
            @_eventGenerate("penaltyChanged", undefined, 1)

        toString: () ->
            "Player##{@id}♥#{@getHealth()}/#{@solved}:#{@unsolved}"

        _eventInit: ->
            @callbacks = {}
            @callbackIdList = {}
            @metaEvents =
                smthChanged: ["healthChanged", "solveChanged", "unsolveChanged", "penaltyChanged", "treatChanged"]
                situations: ["attack", "miss", "treat", "penalty"]
            @metaEvents["all"] = ["attacked"].concat(@metaEvents["smthChanged"]).concat(@metaEvents["situations"])

        _eventGenerate: (eventName, playerTo, value) ->
            console.group "`#{eventName}` generate" if EVENTS_DEBUG
            if @callbacks[eventName]?
                console.info "Callbacks exist" if EVENTS_DEBUG
                for _, callback of @callbacks[eventName]
                    console.info "Callback id: #{_}" if EVENTS_DEBUG
                    console.info "#{this} -->(#{value}) #{playerTo}" if EVENTS_DEBUG
                    callback(this, playerTo, value)
                    for metaEventName, eventList of @metaEvents
                        console.info("Meta event `#{metaEventName}` generate") if EVENTS_DEBUG
                        @_eventGenerate(metaEventName, playerTo, value) if eventName in eventList

            console.groupEnd() if EVENTS_DEBUG

        eventBind: (eventsList, callback) ->
            if not eventsList?
                throw "Список событий не может быть #{eventsList}"

            id = 5
            while @callbackIdList[id]?
                id = Math.floor(Math.random() * 100000000000000000)

            for eventName in eventsList
                @callbacks[eventName] ?= {}

                @callbacks[eventName][id] = callback
                @callbackIdList[id] = eventName

            id

        eventUnbind: (callbackId) ->
            remove(@callbackIdList, callbackId)
            for eventName in @callbackIdList[callbackId]
                delete @callbacks[eventName]



    return Player