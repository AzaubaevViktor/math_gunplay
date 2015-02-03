# Статистика

define ["tools/tools", "tools/jsonify"], (Tools, JSONify) ->
    getValScope = Tools.getValScope

    class Statistic extends JSONify.JSONify
        constructor: (@_players) ->
            @_statsText =
                "all_damage": "Урона нанесено: "
                "all_tasks": "Сыгранные задачи: "
                "all_treat": "Вылеченно здоровья: "
                "solve_percent": "Решённые/все задачи: "

            @stats =
                "all_damage": 0
                "all_tasks": 0
                "all_treat": 0
                "solve_percent": 0

            @solved = 0
            @unsolved = 0

            @className = "Statistic"
            @JSONProperties = ["stats", "solved", "unsolved"]
            @register(Statistic)

        binds: ->
            @_bind_damage()

        _solved_update: ->
            @stats.all_tasks = @solved + @unsolved
            @stats.solve_percent = @solved / (@solved + @unsolved)

        _bind_damage: ->
            for id, player of @_players
                if "length" != id

                    player.eventBind ["attack"], (playerFrom, playerTo, value) =>
                        @stats.all_damage += value

                    player.eventBind ["solveChanged"], (pF, pT, value) =>
                        @solved += value
                        @_solved_update()

                    player.eventBind ["unsolveChanged"], (pF, pT, value) =>
                        @unsolved += value
                        @_solved_update()

                    player.eventBind ["treat"], (pF, pT, value) =>
                        @stats.all_treat += value

    return Statistic