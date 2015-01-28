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

observer = new Object
observer._observeHandlers = {}
observer.observe = (object, property, callback) ->
    handler = (changes) =>
      for change in changes
        callback(change.type, change.oldValue, object[property]) if property is change.name
      undefined

    @_observeHandlers[property] = [] if not @_observeHandlers[property]?
    @_observeHandlers[property].push([object, handler])

    Object.observe(object, handler)

observer.unobserve = (object, property) ->
  if @_observeHandlers[property]?
    for [_object, _handler] in @_observeHandlers[property]
      Object.unobserve(_object, _handler) if object is _object
    delete @_observeHandlers[property] if @_observeHandlers[property].lenght is 0
  undefined



window._Test_Observer = observer

storage =
  save: (key, val) ->
    localStorage.setItem key, JSON.stringify val
    key
  load: (key) ->
    JSON.parse localStorage.getItem key
  delete: (key) ->
    localStorage.removeItem(key)
    key

saveByStructure = (structure, isDeepCopy = false) ->
  # сюда нужно передавать массив структур, для нормального будущего копирования
#    {
#    object1:
#      obj: object1
#      fields: ["field1", "field2"]
#    object2:
#      obj: object2
#      fields: ["f23", "sss3", "yop"]
#    }
  backup = {}

  for objectName, element of structure
    for objectField in element.fields
      backup[objectName][objectField] = if isDeepCopy then deepCopy element.obj[objectField] else element.obj[objectField]

  backup

loadByStructure = (structure, savedData) ->
  for objectName, element of structure
    for objectField in element.fields
      element.obj[objectField] = savedData[objectName][objectField]


class Snapshot
  constructor: (@structure) ->
    @datas = []
    @current = -1
    @add()

  add: ->
    @datas = @datas.slice(0, @current + 1)

    saveByStructure(@structure, true)

    @current += 1

  clear: ->
    @current = -1
    @datas = []
    @add()

  load: (id = @current - 1) ->
    @current = getValScope id, [0, @data.length]
    loadByStructure(@structure, @datas[@current])


class Save
  @protocolVersion = 1
  constructor: (@structure) ->
    @saves = storage.load 'saves'
    @_setDefault() if @saves and @saves.version isnt @protocolVersion

  new: ->
    now = new Date

    id = 1488
    while id in @saves.ids
      id = Math.floor(Math.random() * 100000000000000000)

    @saves.ids[id] = "{#now}"
    _save()
    _save(id, saveByStructure(@structure))

  delete: (id) ->
    delete @saves.ids[id]
    _save()
    storage.delete("save#{id}")

  load: (id) ->
    loadByStructure(@structure, storage.load "save#{id}")

  _save: (id = -1, data = undefined ) ->
    switch id
      when -1 then storage.save 'saves', @saves
      else storage.save "save#{id}", data

  _setDefault: ->
    delete @saves
    @saves = {}
    @saves =
      version: @protocolVersion
      ids: {}

    @_save()



class Settings
  @protocolVersion = 1
  constructor: (@_settingsDesc) ->
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


class Player
  constructor: (@id, @name, @settings) ->
    @setHealth 1
    @solved = @unsolved = @treatment = @penalties = 0

  setHealth: (health) ->
    @health = getValScope health, [0, 1]

  getHealth: () ->
    @health

  incTreatment: () ->
    if ((@settings.nullTreatIfTreatResuscitation()) and (@getLevel() == "resuscitation"))
      @treatment = 0
    else
      @treatment += 1

  getLevel: () ->
    for level, scope of levels
      return level if scope[0] < @getHealth() <= scope[1]
    undefined

  _rawAttack: () ->
    # Функция подсчёта урона
    penalty = penalties_list[@penalties].attack
    10 + @solved - @unsolved - penalty - 3 * @treatment

  _rawTreat: (solved) ->
    # Функция подсчёта жизней
    5 * solved + @solved - @unsolved - 3 * @treatment - 5

  getAttackWithoutTreat: () ->
    #TODO: разобраться зачем мне эта функция
    (getValScope @_rawAttack() + 3 * @treatment, [0, @settings.maxAttack()]) / 100

  getAttack: () ->
    (getValScope @_rawAttack(), [0, @settings.maxAttack()]) / 100

  getAttackTo: (player) ->
    console.log(player)
    switch
      when 0 == @getHealth() then 0
      when @getLevel() != player.getLevel() then 0
      when (@id == player.id) and (@getLevel() == "resuscitation") and not @settings.selfDestroyResuscitation() then 0
      when (@id == player.id) and not @settings.selfDestroyAttack() then 0
      else @getAttack()

  getTreat: (solved) ->
    h = _rawTreat solved
    h += ("hospital" == @getLevel()) * (@settings.hospitalPlus10()) * 10
    h = getValScope h, [(if @settings.selfDestroyTreat() then -Infinity else 0),
                        1 - @getHealth()]

  treat: (solved) ->
    inc = getTreat solved
    @setHealth @getHealth() + inc
    @incTreatment()

  hit: (player) ->
    dmg = @getAttackTo player
    player.setHealth player.getHealth() - dmg
    @solved += 1

  miss: () ->
    @unsolved += 1

  penalty: () ->
    @penalty = getValScope @penalties += 1, [0, penalties_list.lenght() - 1]

  toString: () ->
    "Player##{@id}♥#{@getHealth()}/#{@solved}:#{@unsolved}"


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


class Model

  constructor: () ->
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



window.Model = Model
