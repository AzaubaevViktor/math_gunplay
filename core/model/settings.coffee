# Настройки игры

storage = Tools.storage

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

class Settings
  @protocolVersion = 1
  constructor: (@_settingsDesc = settingsDesc) ->
    @datas = storage.load 'settings'
    @datas = @_setDefault() if @datas and @datas.version isnt @protocolVersion

    for k,v of @_settingsDesc
      console.log(k,v.def)
      (this[k] = () => @_settingsDesc[k].def) if @_settingsDesc[k].def?

  _save: ->
    storage.save 'settings', @datas

  _setDefault: ->
    delete @datas
    @datas = {}
    for k,v of @_settingsDesc
      @datas[k] = v.def if @_settingsDesc[k].def?
    @_save()

  set: (name, value) ->
    @datas[name] = value
    @_save()


window.Model.settingsDesc = settingsDesc
window.Model.Settings = Settings