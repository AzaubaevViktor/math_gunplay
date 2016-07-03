

class Controller
  constructor: ->
    # addPlayer
    $("#modalAddPlayerAgreeBtn").on "click", =>
      @addPlayer()
    $("#newPlayerName").keyup (e) =>
      if 13 == e.keyCode
        @addPlayer()

    # changeGameMode
    $("#modeButton").on "click", =>
      @changeGameMode()

    mgModelSettings.endDayCallback = =>
      @changeGameMode()

    return

  addPlayer:  ->
    name = $("#newPlayerName").val()
    $("#newPlayerName").val("")
    if name.length
      mgModel.addPlayer(name)
      mgView.update()

    # playerClick
    $("tr.player").unbind 'click'
    $("tr.player").on 'click', (e) =>
      if !$(e.toElement).attr('class').includes 'btn'
        @playerClick($ e.currentTarget)
    return

  changeGameMode: ->
    if isMode MODE_ADD
      if mgModel.players.length == 0
        Materialize.toast("Вы не добавили ни одного игрока. Нажмите на + на верхней панели, чтобы добавить игроков", 4000, "red darken-4" );
      else
        setMode MODE_DAY
    else if isMode MODE_DAY
      setMode MODE_NIGHT
    else if isMode MODE_NIGHT
      setMode MODE_DAY
    mgView.update()
    return

  playerClick: (playerEl) ->
    id = 1 * playerEl.attr('id')[6..]
    console.log(id)

    if mgViewSettings.isAttack
      mgModel.hit mgViewSettings.fromPlId, id

      mgViewSettings.fromPlId = -1
      mgViewSettings.isAttack = false
      mgViewSettings.currentLevel = null
    else
      if mgViewSettings.fromPlId == -1
        mgViewSettings.fromPlId = id
      else if mgViewSettings.fromPlId == id
        mgViewSettings.fromPlId = -1
      else
        mgViewSettings.fromPlId = id

    mgView.update()
    return

  actionClick: (act, value) ->
    console.log act, value

    if mgViewSettings.isAttack
      if act == 'solve'
        mgViewSettings.isAttack = false
        mgViewSettings.currentLevel = null
        mgView.update()
        return
      else
        return

    mgViewSettings.isAttack = false

    switch act
      when 'solve'
        mgViewSettings.isAttack = true
        mgViewSettings.currentLevel = mgModel.players[mgViewSettings.fromPlId].getLevel()
      when 'unsolve'
        mgModel.miss(mgViewSettings.fromPlId)
        mgViewSettings.fromPlId = -1
      when 'treat'
        mgModel.treat(mgViewSettings.fromPlId, value)
        mgViewSettings.fromPlId = -1
      when 'penalty'
        mgModel.penalty(mgViewSettings.fromPlId)
        mgViewSettings.fromPlId = -1

    mgView.update()
    return


window.mgController = new Controller()
