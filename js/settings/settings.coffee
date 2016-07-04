desc =
  info:
    type: "text",
    label: "Помните: настройки обновляются <b>сразу</b>!"
  ,
  wiki:
    type: "text",
    label: "<a href='https://github.com/ktulhy-kun/math_gunplay/wiki'>Как играть</a>"
  ,
  dayTime:
    type: "number",
    label: "Продолжительность дня",
    after: "мин",
    help: "Если вы меняете это поле днём, то изменения вступят в силу только на <b>следующий</b> день"
  ,
  maxAttack:
    type: "number",
    label: "Максимальная атака",
    after: "%"
  ,
  selfDestroyAttack:
    type: "checkbox",
    after: "Самоубийство (Атака)"
  ,
  selfDestroyTreat:
    type: "checkbox",
    after: "Самоубийство (Лечение)"
  ,
  selfDestroyResuscitation:
    type: "checkbox",
    after: "Самоубийство (Реанимация)"
  ,
  nullResus:
    type: "checkbox",
    after: "Обнуление количества лечений при лечении в реанимации"
  ,
  hospitalPlus:
    type: "number",
    label: "Дополнительные очки при лечении в госпитале"
  ,
  attackFormula:
    type: "text",
    label: "Формула расчёта урона:<br>min (10 + Р - Н - 3 * Л, МАКСУРОН)",
    help: "Р -- кол-во решённых задач<br> Н -- кол-во нерешённых задач<br> Л -- кол-во попыток лечения<br> МАКСУРОН -- максимальный урон, см. выше"
  ,
  treatFormula:
    type: "text",
    label: "Формула расчёта лечения:<br>5 * У + Р - Н - 3 * Л - 5",
    help: "У -- кол-во решённых задач из 3-х, остальное см. выше"
  ,
  github:
    type: "text",
    label: "<a href='https://github.com/ktulhy-kun/math_gunplay'>Исходный код</a>"


row = ->
  $("<div class='row'>")
colText = ->
  $("<div class='col s12'>")
colIF = ->
  $("<div class='col s12 input-field'>")


bindSettingsGenerate = (name, type) ->
  elem = $("##{name}-#{type}")
  switch type
    when 'number'
      return ->
        mgModelSettings[name] = 1 * elem.val()
        mgModelSettings.saveSettings()
    when 'checkbox'
      return ->
        mgModelSettings[name] = elem.prop 'checked'
        mgModelSettings.saveSettings()

bindSettings = (name, type) ->
  elem = $("##{name}-#{type}")
  switch type
    when "number"
      elem.on 'change', bindSettingsGenerate name, type
    when "checkbox"
      elem.on 'change', bindSettingsGenerate name, type
  return

class ViewSettingsModal
  constructor: ->
    @modal = $("#modalSettingsBody")
    @modal.append @modalInit()
    for name, param of desc
      bindSettings name, param.type

  modalInit: ->
    for name, param of desc
      switch param.type
        when "text"
          row().append colText().append [
            $("<p>").append(param.label),
            $("<p style='color:gray'>").append(param.help) if param.help?
          ]
        when "number"
          row().append colIF().append [
              "<input value='#{mgModelSettings[name]}' id='#{name}-number' type='number' class='validate'>
              <label class='active' for='first_name2'>#{param.label}, #{param.after if param.after?}</label>",
            $("<p style='color:gray'>").append(param.help) if param.help?
          ]

        when "checkbox"
          checked = mgModelSettings[name]
          row().append $("<p>").append("
            <input type='checkbox' id='#{name}-checkbox' #{"checked" if checked}/>
            <label for='#{name}-checkbox'>#{param.after}</label>
          ")
        else
          ""

$(document).ready ->
  vsm = new ViewSettingsModal()
