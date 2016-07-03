

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
    $("tr.player").on 'click', (e) ->
      if !$(e.toElement).attr('class').includes 'btn'
        mgView.playerClick($ e.currentTarget)
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


window.mgController = new Controller()
