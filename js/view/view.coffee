class ViewSettings
  constructor: ->

checkShowHide = (element, condition) ->
  if condition
    element.show(100)
  else
    element.hide(100)

checkShowHideGameMode = (element, gameModeList) ->
  checkShowHide element, isMode gameModeList

class View
  constructor: ->
    @table = $("table")
    @tbody = @table.find("tbody")
    @addPlayerButton = $('#addPlayerButton')
    @modeButtonText = $("#modeText")

  generatePlayer: (player) ->
    $("<tr>").addClass("player").attr("id", "player#{player.id}").append [
      $("<td>").addClass("plId"),
      $("<td>").addClass("plName"),
      $("<td>").addClass("plHealth"),
      $("<td>").addClass("plDamage"),
      $("<td>").addClass("plSolvedUnsolved")
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
    playerEl.find(".plSolvedUnsolved").text("#{player.solved}/#{player.unsolved}")
    playerEl.show(1000)
    return

  redrawPlayers: ->
    for player in mgModel.players
      @updatePlayer(player)
    return

  redrawPanel: ->
    if isMode MODE_ADD
      @modeButtonText.text "Добавление игроков"
    else if isMode MODE_DAY
      @modeButtonText.text "День (ВРЕМЯ)"
    else if isMode MODE_NIGHT
      @modeButtonText.text "Ночь"

    checkShowHideGameMode @addPlayerButton, MODE_ADD

    

  update: ->
    @redrawPlayers()
    @redrawPanel()

window.mgView = new View()
mgView.update()