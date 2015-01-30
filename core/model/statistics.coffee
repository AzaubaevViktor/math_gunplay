# Статистика

settingsDesc =
  info:
    type: "text"
    before: "Помните: настройки обновляются <b>сразу</b>!"

  wiki:
    type: "text"
    before: "<a href='https://github.com/ktulhy-kun/math_gunplay/wiki'>Как играть</a>"

  stTime:
    type: "number"
    before: "Продолжительность дня"
    after: "мин"
    def: "20"
    help: "Если вы меняете это поле днём, то изменения вступят в силу только на <b>следующий</b> день"

  maxAttack:
    type: "number"
    before: "Максимальная атака"
    after: "%"
    def: "15"

  selfDestroyAttack:
    type: "checkbox"
    after: "Самоубийство (Атака)"
    def: true

  selfDestroyTreat:
    type: "checkbox"
    after: "Самоубийство (Лечение)"
    def: true

  selfDestroyResuscitation:
    type: "checkbox"
    after: "Самоубийство (Реанимация)"
    def: false

  hospitalPlus10:
    type: "checkbox"
    after: "Дополнительные +10 при лечении в госпитале"
    def: true

  nullTreatIfTreatResuscitation:
    type: "checkbox"
    after: "Обнуление количества лечений при лечении в реанимации"
    def: true

  attackFormula:
    type: "text"
    before: "Формула расчёта урона:<br>min (10 + Р - Н - 3 * Л, МАКСУРОН)"
    help: "Р -- кол-во решённых задач<br>
          Н -- кол-во нерешённых задач<br>
          Л -- кол-во попыток лечения<br>
          МАКСУРОН -- максимальный урон, см. выше"

  treatFormula:
    type: "text"
    before: "Формула расчёта лечения:<br>5 * У + Р - Н - 3 * Л - 5"
    help: "У -- кол-во решённых задач из 3-х, остальное см. выше"

  github:
    type: "text"
    before: "<a href='https://github.com/ktulhy-kun/math_gunplay'>Исходный код</a>"

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

  binds: ->
    @_bind_damage()

  _bind_damage: ->
    for id, player of @players
      console.log("-> Reobserve: #{player}")
      if "length" != id

        observer.observe(player, "health", (type, oldValue, newValue) =>
          dmg = getValScope oldValue - newValue, [0, +Infinity]
          @stats.all_damage.value += dmg
          console.log("#{player} Нанесли #{dmg} урона")
        )

window.Model.settingsDesc = settingsDesc
window.Model.Statistic = Statistic