class ViewSettings
  constructor: ->


class View
  constructor: ->
    @table = $("table")
    @tbody = @table.find("tbody")

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
      playerEl = @generatePlayer(player).insertAfter(".#{player.getLevel()}")

    playerEl.find(".plId").text(player.id)
    playerEl.find(".plName").text(player.name)
    playerEl.find(".plHealth").text(player.health)
    playerEl.find(".plDamage").text(player.getAttackValue())
    playerEl.find(".plSolvedUnsolved").text("#{player.solved}/#{player.unsolved}")

#    playerEl.detach().prependTo(".#{player.getLevel()}")

  redrawPlayers: ->
    for player in mgModel.players
      @updatePlayer(player)

window.mgView = new View()