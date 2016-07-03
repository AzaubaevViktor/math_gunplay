class Controller
  constructor: ->
    $("#modalAddPlayerAgreeBtn").on "click", =>
      @addPlayer()
    $("#newPlayerName").keyup (e) =>
      if 13 == e.keyCode
        @addPlayer()

  addPlayer: () ->
    name = $("#newPlayerName").val()
    $("#newPlayerName").val("")
    if name.length
      mgModel.addPlayer(name)
      mgView.redrawPlayers()

window.mgController = new Controller()
