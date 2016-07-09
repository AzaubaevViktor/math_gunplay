window.MODE_ADD = 1
window.MODE_DAY = 2
window.MODE_NIGHT = 3

takeSnapshot = ->
  console.warn "Take Snapshot ещё не готов"


window.isMode = (gameModes) ->
  if Array.isArray gameModes
    return mgModelSettings.gameMode in gameModes
  else
    return mgModelSettings.gameMode == gameModes


window.setMode = (gameMode, isTakeSnapshot=true) ->
  console.group "Change mode to #{gameMode}"
  mgModelSettings.gameMode = gameMode
  if isMode MODE_DAY
    mgModel.setDayTimer()
  else
    clearInterval mgModelSettings.timer
  if isTakeSnapshot
    takeSnapshot()
  console.groupEnd()


restorePlayers = (players) ->
  console.group "Restore players"

  if !mgModel?
    console.log "Model not found. End"
    console.groupEnd()
    return
  mgModel.players = []

  for player in players
    console.log "Restore Player ##{player.id}: #{player.name}"

    mPlayer = new Player player.id, player.name
    mPlayer.apply player
    mgModel.players.push mPlayer

  console.groupEnd()
  return


class ModelSettings
  constructor: ->
    console.info "Create ModelSettings"
    @settingsVersion = 1
    @savesVersion = 2

    # Параметры игры
    @maxAttack = 15
    @selfDestroyAttack = true
    @selfDestroyTreat = true
    @selfDestroyResuscitation = false
    @hospitalPlus = 10
    @nullResus = true # обнуление количества лечений в реанимации
    @dayTime = 4
    @gameMode = MODE_ADD
    @time = 0
    @timer = null
    @endDayCallback = ->
    @daySecondCallback = ->

    @connectToStorage()
    @loadSettings()
    console.groupEnd()
    return

  connectToStorage: ->
    console.group "Connecting to local storage"
    @saves = Stor.get 'saves'
    if !@saves? || @saves.version != @savesVersion
      console.info "Обнаружена старая версия сохранений (#{@saves?.version}), они будут удалены"
      @saves = null

    if @saves == null
      console.info "Создаю новый каталог сохранений, протокол #{@savesVersion}"
      @saves = {
        version: @savesVersion
        ids: {}
      }

    Stor.set 'saves', @saves
    console.groupEnd()
    return

  findId: ->
    id = 1853;
    while id of this.saves.ids
      id = Math.floor(Math.random() * 100000000000000000)
    return id

  writeSave: (name) ->
    now = new Date()
    id = @findId()
    console.log "Write new save #{id}: #{name}"
    @saves.ids[id] = name
    Stor.set 'saves',  @saves
    Stor.set id, {
      settings: {
        maxAttack: @maxAttack
        selfDestroyAttack: @selfDestroyAttack
        selfDestroyTreat: @selfDestroyTreat
        selfDestroyResuscitation: @selfDestroyResuscitation
        hospitalPlus: @hospitalPlus
        nullResus: @nullResus
        dayTime: @dayTime
      }
      players: mgModel.players
      date: now
    }
    return

  deleteSave: (id) ->
    console.log "Delete save #{id}"
    delete @saves.ids[id]
    Stor.set 'saves', @saves
    Stor.remove id
    return

  loadSave: (id) ->
    console.group "Load save"
    save = Stor.get id
    # Restore Settings
    @maxAttack = save.settings.maxAttack
    @selfDestroyAttack = save.settings.selfDestroyAttack
    @selfDestroyTreat = save.settings.selfDestroyTreat
    @selfDestroyResuscitation = save.settings.selfDestroyResuscitation
    @hospitalPlus = save.settings.hospitalPlus
    @nullResus = save.settings.nullResus
    @dayTime = save.settings.dayTime

    setMode MODE_NIGHT, false

    @time = 0
    clearInterval @timer

    restorePlayers save.players
    console.groupEnd()
    return

  saveSettings: ->
    console.log "Save Settings"

    Stor.set 'settings', {
      version: @settingsVersion
      maxAttack: @maxAttack
      selfDestroyAttack: @selfDestroyAttack
      selfDestroyTreat: @selfDestroyTreat
      selfDestroyResuscitation: @selfDestroyResuscitation
      hospitalPlus: @hospitalPlus
      nullResus: @nullResus
      dayTime: @dayTime
    }
    return 

  loadSettings: ->
    console.group "Load settings"

    _sett = Stor.get 'settings'
    if !_sett? || _sett.version != @settingsVersion
      console.info "Обнаружена старая версия настроек (#{_sett?.version}), пересохраняю"
      @saveSettings()
      _sett = Stor.get 'settings'

    @maxAttack = _sett.maxAttack
    @selfDestroyAttack = _sett.selfDestroyAttack
    @selfDestroyTreat = _sett.selfDestroyTreat
    @selfDestroyResuscitation = _sett.selfDestroyResuscitation
    @hospitalPlus = _sett.hospitalPlus
    @nullResus = _sett.nullResus
    @dayTime = _sett.dayTime
    console.groupEnd()
    return

window.mgModelSettings = new ModelSettings()

class Model
  constructor: ->
    console.info "Create Model"
    @players = []
    return

  addPlayer: (name) ->
    console.log "Был добавлен пользователь #{name}"
    @players.push(new Player(@players.length, name))
    takeSnapshot()
    return

  getPlayer: (id) ->
    @players[id]

  hit: (fromId, toId) ->
    playerFrom = @getPlayer(fromId)
    playerTo = @getPlayer(toId)

    attackValue = playerFrom.getAttackValue()
    playerFrom.solved += 1

    if (playerTo.health == 0) || (playerFrom.getLevel() != playerTo.getLevel())
      takeSnapshot()
      return 0

    if fromId == toId
      if playerFrom.level == RESUSCITATION
        if mgModelSettings.selfDestroyResuscitation
          takeSnapshot()
          return 0
      if !mgModelSettings.selfDestroyAttack
        takeSnapshot()
        return 0

    console.log "Попадание игрока #{playerFrom.name} в #{playerTo.name}, урон #{attackValue}"

    newLife = playerTo.dHealth(-attackValue)
    takeSnapshot()
    return newLife

  miss: (plId) ->
    player = @getPlayer(plId)
    console.log "Промах игрока #{player.name}"
    player.unsolved += 1
    takeSnapshot()
    return 0

  treat: (plId, correct) ->
    player = @getPlayer(plId)
    value = player.getTreatValue(correct)

    player.solved += 1 * correct
    player.unsolved += 3 - 1 * correct

    if (player.getLevel() == RESUSCITATION) && mgModelSettings.nullResus
      player.treatment = 0
    else
      player.treatment += 1

    console.log "Игрок #{player.name} лечится с #{correct} решёнными задачи, восстанавливает #{value} здоровья"

    newLife = player.dHealth(value)
    takeSnapshot()
    newLife

  penalty: (plId) ->
    player = @getPlayer(plId)
    console.log "Игрок #{player.name} оштрафован"
    player.addPenalty()
    takeSnapshot()

  setDayTimer: ->
    clearInterval mgModelSettings.timer
    mgModelSettings.time = Math.max 1, mgModelSettings.dayTime * 60

    mgModelSettings.timer = setInterval ->
      mgModelSettings.time -= 1
      if mgModelSettings.time <= 0
        mgModelSettings.endDayCallback()
        clearInterval mgModelSettings.timer
        mgModelSettings.timer = null
      else
        mgModelSettings.daySecondCallback()
    , 1000


window.mgModel = new Model()


class Snapshotter
  constructor: ->
    console.info "Create Snapshotter"
    @loadSnapshot()

  saveSnapshot: ->
    console.group "Saving Snapshot"

    snapshots = Stor.get 'snapshots'
    id = snapshots.currentId += 1
    snapshots.maxId = Math.max(id, snapshots.maxId)
    for _id in [id..snapshots.maxId]
      Stor.remove "snap_#{_id}"

    Stor.set "snap_#{id}", {
      players: if mgModel? then mgModel.players else []
      gameMode: mgModelSettings.gameMode
    }
    Stor.set "snapshots", snapshots
    console.groupEnd()
    return

  loadSnapshot: ->
    console.group("Load Snapshot")
    snapshots = Stor.get 'snapshots'
    if !snapshots? || snapshots.maxId == -1
      console.log("Create new game")
      Stor.set 'snapshots', {
        currentId: -1
        maxId: -1
      }
      @saveSnapshot()
      snapshots = Stor.get 'snapshots'

    snapshot = Stor.get "snap_#{snapshots.currentId}"
    Stor.set 'snapshots', snapshots

    restorePlayers snapshot.players
    setMode snapshot.gameMode, false
    console.groupEnd()

  prevSnapshot: ->
    console.group "Take previous snapshot"
    snapshots = Stor.get 'snapshots'
    if @isPrev()
      snapshots.currentId -= 1
    Stor.set 'snapshots', snapshots
    @loadSnapshot()
    console.groupEnd()

  nextSnapshot: ->
    console.group "Take next snapshot"
    snapshots = Stor.get 'snapshots'
    if @isNext()
      snapshots.currentId += 1
    Stor.set 'snapshots', snapshots
    @loadSnapshot()
    console.groupEnd()

  removeSnapshots: ->
    console.group "NEW GAME"
    snapshots = Stor.get 'snapshots'
    for id in [0..snapshots.maxId]
      Stor.remove "snap_#{id}"
    Stor.remove 'snapshots'
    mgModel.players = []
    setMode(MODE_ADD, false)
    @loadSnapshot()
    console.groupEnd()

  isPrev: ->
    snapshots = Stor.get 'snapshots'
    snapshots? && snapshots.currentId != 0

  isNext: ->
    snapshots = Stor.get 'snapshots'
    snapshots? && snapshots.currentId != snapshots.maxId


window.snapshotter = new Snapshotter()
takeSnapshot = snapshotter.saveSnapshot
