class ViewSettings
  constructor: ->
    @fromPlId = -1
    @isAttack = false
    @currentLevel = null

mgViewSettings = new ViewSettings()
window.mgViewSettings = mgViewSettings

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
    @actionShowed = false

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
          $("<option value='-1'>"),
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
    @el.find("select").val(-1)
    for opt in @el.find("option")
      opt = $(opt)
      if opt.attr('value') == '-1'
        opt.text("Задач верно:")
      else
        opt.text("#{opt.attr('value')} верно (#{@player.getTreatValue opt.attr('value')})")
    @el.find(".plSolvedUnsolved").text("#{@player.solved}/#{@player.unsolved}")

    @show(1000)
    return

  showActions: (time) ->
    if !@actionShowed
      @el.find(".plHealth").hide()
      @el.find(".plDamage").hide()
      @el.find(".plTreat").hide()
      @el.find(".plSolvedUnsolved").hide()
      @el.find(".plActions").show(time)
      @actionShowed = true

  hideActions: (time) ->
    if @actionShowed
      @el.find(".plActions").hide()
      @el.find(".plHealth").show(time)
      @el.find(".plDamage").show(time)
      @el.find(".plTreat").show(time)
      @el.find(".plSolvedUnsolved").show(time)
      @actionShowed = false

  generateActionClickCallback: () ->
    return (e) =>
      target = $ e.currentTarget
      actName = target.attr('act')
      value = target.val()
      mgController.actionClick(actName, value)

  remove: ->
    @el.remove()


class View
  constructor: ->
    console.info "Create View"

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

    vPlayer.player = player
    vPlayer.update()

  updatePlayers: ->
    maxId = -1
    for player in mgModel.players
      @updatePlayer(player)
      maxId = Math.max maxId, player.id

    `
    // Длинна меняется во время исполнения цикла
    len = this.viewPlayers.length;
    for (id = maxId + 1; id < len; ++id) {
        var ref;
        if ((ref = this.viewPlayers.pop()) != null) {
            ref.remove();
        }
    }`

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
    
    checkShowHide $("#prevSnap"), snapshotter.isPrev()
    checkShowHide $("#nextSnap"), snapshotter.isNext()

  update: ->
    console.log "Update Screen"
    @updatePanel()
    @updatePlayers()
    @updateActions()

  showActionsOnlyFor: (plId) ->
    for vPl in @viewPlayers
      if vPl.player.id == plId
        vPl.showActions(300)
      else
        vPl.hideActions(0)
    return

  updateActions: ->
    if ! isMode MODE_NIGHT
      @showActionsOnlyFor(-1)
      return

    if mgViewSettings.fromPlId == -1
      @showActionsOnlyFor(-1)
    else
      if mgViewSettings.isAttack
        for vPlayer in @viewPlayers
          if vPlayer.player.getLevel() != mgViewSettings.currentLevel
            vPlayer.el.addClass "not"
      else
        @showActionsOnlyFor(mgViewSettings.fromPlId)
        $(".player").removeClass("not")




window.mgView = new View()
mgView.update()