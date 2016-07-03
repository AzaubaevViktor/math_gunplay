checkShowHide = (element, condition) ->
  if condition
    element.show(100)
  else
    element.hide(100)

checkShowHideGameMode = (element, gameModeList) ->
  checkShowHide element, isMode gameModeList

class View
  constructor: ->
    @table = $("#mainTable")
    @tbody = @table.find("tbody")
    @addPlayerButton = $('#addPlayerButton')
    @modeButtonText = $("#modeText")

    mgModelSettings.daySecondCallback = =>
      @updateTime()

  generatePlayer: (player) ->
    $("<tr>").addClass("player").attr("id", "player#{player.id}").append [
      $("<td>").addClass("plId"),
      $("<td>").addClass("plName"),
      $("<td>").addClass("plHealth"),
      $("<td>").addClass("plDamage"),
      $("<td>").addClass("plTreat"),
      $("<td>").addClass("plSolvedUnsolved"),
      $("<td colspan='3'>").addClass("plActions").append [
        btn("solve#{player.id}", "Решена", "green darken-1")
        btn("unsolve#{player.id}", "Не решена", "red darken-1")
        $("<select id='treat#{player.id}'>").addClass("waves-effect waves-light btn blue darken-1").append([
          $("<option value='0'>"),
          $("<option value='1'>"),
          $("<option value='2'>"),
          $("<option value='3'>")
        ]),
        btn("penalty#{player.id}", "Штраф", "orange darken-1")
      ]
    ]

  updatePlayer: (player) ->
    playerEl = $("#player#{player.id}")
    if !playerEl.length
      playerEl = @generatePlayer(player)
      @tbody.append playerEl
      playerEl.hide()

    playerEl.removeClass().addClass(player.getLevel())

    playerEl.find(".plId").text(player.id)
    playerEl.find(".plName").text(player.name)
    playerEl.find(".plHealth").text(player.health)
    playerEl.find(".plDamage").text(player.getAttackValue())
    playerEl.find(".plTreat").text(player.getTreatValue(3))
    for opt in playerEl.find("option")
      opt = $(opt)
      opt.text("#{opt.val()} верно (#{player.getTreatValue opt.val()})")
    playerEl.find(".plSolvedUnsolved").text("#{player.solved}/#{player.unsolved}")
    playerEl.show(1000)
    return

  updatePlayers: ->
    for player in mgModel.players
      @updatePlayer(player)
    return

  updateTime: ->
    time = mgModelSettings.time
    min = Math.floor(time / 60)
    min = if min < 10 then "0" + min else min
    sec = time % 60
    sec = if sec < 10 then "0" + sec else sec
    @modeButtonText.text "День (#{min}:#{sec})"

  updatePanel: ->
    if isMode MODE_ADD
      @modeButtonText.text "Добавление игроков"
    else if isMode MODE_DAY
      @updateTime()
    else if isMode MODE_NIGHT
      @modeButtonText.text "Ночь"

    checkShowHideGameMode @addPlayerButton, MODE_ADD

  update: ->
    @updatePlayers()
    @updatePanel()

window.mgView = new View()
mgView.update()