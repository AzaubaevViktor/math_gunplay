
define ["tools/jsonify"], (JSONify) ->
    class History extends JSONify.JSONify
        constructor: (@_players) ->
            @datas = []
            @className = "History"
            @JSONProperties = ["datas"]
            @register History

        binds: ->
            for id, player of @_players
                if "length" != id
                    player.eventBind ["situations"], @_create_point

        _create_point: (plFr, plTo, value, type) =>
            point =
                type: type
                playerFrom:
                    name: plFr.name
                    level: plFr.getLevel()
                playerTo:
                    name: if plTo then plTo.name else undefined
                    level: if plTo then plTo.getLevel() else undefined
                value: value

            @datas.push point

    return History



