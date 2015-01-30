# Статистика

observer = Tools.observer
getValScope = Tools.getValScope
JSONify = Tools.JSONify

class Statistic extends JSONify
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

        player.setWatcher "health", (type, oldValue, newValue) =>
          dmg = getValScope oldValue - newValue, [0, +Infinity]
          @stats.all_damage += dmg
          treat = getValScope newValue - oldValue, [0, +Infinity]
          @stats.all_treat += treat


        player.setWatcher "solved", (t, o, n) =>
          @solved += n - o
          @_solved_update()


        player.setWatcher "unsolved", (t, o ,n) =>
          @unsolved += n - o
          @_solved_update()


window.Model.Statistic = Statistic