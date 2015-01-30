# Статистика

observer = Tools.observer
getValScope = Tools.getValScope

class Statistic
  constructor: (@players) ->
    @stats =
      "all_damage":
        "title": "Урона нанесено: "
        "value": 0

      "all_tasks":
        "title": "Сыгранные задачи: "
        "value": 0

      "all_treat":
        "title": "Вылеченно здоровья: "
        "value": 0

      "solve_percent":
        "title": "Решённые/все задачи: "
        "value": 0

    @solved = 0
    @unsolved = 0

  binds: ->
    @_bind_damage()

  _solved_update: ->
    @stats.all_tasks.value = @solved + @unsolved
    @stats.solve_percent.value = @solved / (@solved + @unsolved)

  _bind_damage: ->
    for id, player of @players
      if "length" != id

        player.setWatcher "health", (type, oldValue, newValue) =>
          dmg = getValScope oldValue - newValue, [0, +Infinity]
          @stats.all_damage.value += dmg
          treat = getValScope newValue - oldValue, [0, +Infinity]
          @stats.all_treat.value += treat
          console.log(dmg, treat)


        player.setWatcher "solved", (t, o, n) =>
          @solved += n - o
          @_solved_update()


        player.setWatcher "unsolved", (t, o ,n) =>
          @unsolved += n - o
          @_solved_update()


window.Model.Statistic = Statistic