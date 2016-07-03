class ViewSettings
  constructor: ->
    @fromPlId = -1
    @isAttack = false
    @attackTo = -1

viewSettings = new ViewSettings()

checkShowHide = (element, condition) ->
  if condition
    element.show(100)
  else
    element.hide(100)

checkShowHideGameMode = (element, gameModeList) ->
  checkShowHide element, isMode gameModeList


class ViewPlayer
  constructor: (@player) ->
    @el = null

  getEl: ->
    if @el?
      return @el
    else
      return @generatePlayer()

  hide: (time) ->
    @el.hide(time)

  show: (time) ->
    @el.show(time)

  generatePlayer: ->
    @el = $("<tr>").addClass("player").attr("id", "player#{@player.id}").append [
      $("<td>").addClass("plId"),
      $("<td>").addClass("plName"),
      $("<td>").addClass("plHealth"),
      $("<td>").addClass("plDamage"),
      $("<td>").addClass("plTreat"),
      $("<td>").addClass("plSolvedUnsolved"),
      $("<td colspan='4'>").hide().addClass("plActions").append [
        btn("solve", "Решена", "green darken-1", @generateActionClickCallback())
        btn("unsolve", "Не решена", "red darken-1", @generateActionClickCallback())
        $("<select act='treat'>").addClass("waves-effect waves-light btn blue darken-1").append([
          $("<option value='0'>"),
          $("<option value='1'>"),
          $("<option value='2'>"),
          $("<option value='3'>")
        ]).on('change', @generateActionClickCallback()),
        btn("penalty", "Штраф", "orange darken-1", @generateActionClickCallback())
      ]
    ]

  update: ->
    @el.removeClass().addClass(@player.getLevel()).addClass("player")

    penalties = ""
    `for (i = 0; i < this.player.penalties; i++) penalties += "*"`

    @el.find(".plId").text(@player.id)
    @el.find(".plName").text(@player.name + penalties)
    @el.find(".plHealth").text(@player.health)
    @el.find(".plDamage").text(@player.getAttackValue())
    @el.find(".plTreat").text(@player.getTreatValue(3))
    for opt in @el.find("option")
      opt = $(opt)
      opt.text("#{opt.attr('value')} верно (#{@player.getTreatValue opt.attr('value')})")
    @el.find(".plSolvedUnsolved").text("#{@player.solved}/#{@player.unsolved}")

    @show(1000)
    return

  showActions: (time) ->
    @el.find(".plHealth").hide()
    @el.find(".plDamage").hide()
    @el.find(".plTreat").hide()
    @el.find(".plSolvedUnsolved").hide()
    @el.find(".plActions").show(time)

  hideActions: (time) ->
    @el.find(".plActions").hide()
    @el.find(".plHealth").show(time)
    @el.find(".plDamage").show(time)
    @el.find(".plTreat").show(time)
    @el.find(".plSolvedUnsolved").show(time)

  generateActionClickCallback: () ->
    return (e) =>
      target = $ e.currentTarget
      actName = target.attr('act')
      value = target.val()
      mgView.actionClick(actName, value)



class View
  constructor: ->
    @table = $("#mainTable")
    @tbody = @table.find("tbody")
    @addPlayerButton = $('#addPlayerButton')
    @modeButtonText = $("#modeText")
    @viewPlayers = []

    mgModelSettings.daySecondCallback = =>
      @updateTime()

  updatePlayer: (player) ->
    vPlayer = null
    if @viewPlayers.length < player.id + 1
      vPlayer = new ViewPlayer(player)
      @viewPlayers.push(vPlayer)
      @tbody.append vPlayer.getEl()
      vPlayer.hide()
    else
      vPlayer = @viewPlayers[player.id]

    vPlayer.update()

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

  hideAllActions: ->
    for vPl in @viewPlayers
      vPl.hideActions(0)

  playerClick: (playerEl) ->
    id = 1 * playerEl.attr('id')[6..]
    console.log(id)
    vPlayer = @viewPlayers[id]

    if viewSettings.isAttack
      mgModel.hit viewSettings.fromPlId, id

      viewSettings.fromPlId = -1
      viewSettings.isAttack = false
      @hideAllActions()
      @update()
    else
      if viewSettings.fromPlId == -1
        vPlayer.showActions 300
        viewSettings.fromPlId = id
      else if viewSettings.fromPlId == id
        vPlayer.hideActions 300
        viewSettings.fromPlId = -1
      else
        @hideAllActions()

        vPlayer.showActions 300
        viewSettings.fromPlId = id

    return

  actionClick: (act, value) ->
    console.log act, value
    viewSettings.isAttack = false

    if viewSettings.isAttack
      return

    switch act
      when 'solve'
        viewSettings.isAttack = true
        #TODO: Засерить плохие комнады
      when 'unsolve'
        mgModel.miss(viewSettings.fromPlId)
        @hideAllActions()
        viewSettings.fromPlId = -1
      when 'treat'
        mgModel.treat(viewSettings.fromPlId, value)
        @hideAllActions()
        viewSettings.fromPlId = -1
      when 'penalty'
        mgModel.penalty(viewSettings.fromPlId)
        @hideAllActions()
        viewSettings.fromPlId = -1

    @update();



window.mgView = new View()
mgView.update()