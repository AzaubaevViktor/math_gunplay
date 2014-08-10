
class View
  constructor: ->
    @elements = {
      buttons: {
        backward: $ "#backward"
        forward: $ "#forward"
        daynight: $ "#daynight"
      }

      inputs: {

      }

      blocks: {

      }

      carousel: {
        this: new _Carousel($ "#carousel")
        items: [($ "#item0"), ($ "#item1"), ($ "#item2"), ($ "#item3")]
      }

      tables: []

      places: []

      templates: {
        players: ($ "#players-template").html()
        place: ($ "#place-template").html()
        addplayer: ($ "#addplayer-template").html()
      }

      settings: $ "#settings-modal .modal-body"
      saves: $ "#saves-modal .modal-body"
    }

    @nightMode = {
      is: false
      selected: -1
      attack: -1
    }

    items = @elements.carousel.items

    for item, ind in items
      item.html("<table id=\"table#{ind}\" class=\"table\">
          #{@elements.templates.players}
        </table>")
      @elements.tables.push $ "#table#{ind}"
      @elements.places.push {
        this: $ "#table#{ind} > .pl-list"
        list: []
        }

    @elements.tables[0].append @elements.templates.addplayer
    @elements.inputs.newPlayer = $ "#addplayer"
    @elements.blocks.newPlayer = $ ($ ".pl-addplayer")[0]

    console.log @elements.tables[0]
    (undefined)

  joinModel: (@model) ->
    @updateSaves()
    (undefined)

  joinController: (@controller) ->
    @generateSettings()
    (undefined)

  updateSaves: ->
    @elements.saves.html("")

    for id, time of @model.saves.ids
      @elements.saves.append("
        <button type='button' id='#{id}' act='load' class='btn btn-default'>#{time}</button>
        <button type='button' id='#{id}' act='delete' class='btn btn-default'>&times;</button><br>
        ")
    @elements.saves.append("
      <button type='button' act='new' class='btn btn-default'>Сохранить</button>
        ")

  generateSettings: ->
    sett = @model.settings
    settDesc = @model.settingsDesc
    body = @elements.settings

    for name, desc of settDesc
      help = if desc.help then "<p class='help-block'>#{desc.help}</p>" else ""

      switch desc.type
        when "text"
          body.append "
          <div class='row'>
            <div class='col-lg-10'>
              <p class='form-control-static' id='#{name}'>#{desc.before}</p>
              #{help}
            </div>
          </div>"
        when "number"
          body.append "
          <div class='row'>
            <div class='col-lg-10'>
              <div class='input-group'>
                <span class='input-group-addon'>#{desc.before}</span>
                <input id='#{name}' type='number' class='form-control' placeholder='#{if desc.def then desc.def else ''}'>
                <span class='input-group-addon'>#{desc.after}</span>
              </div>
              #{help}
            </div>
          </div>"
        when "checkbox"
          body.append "
          <div class='row'>
            <div class='col-lg-10'>
              <div class='checkbox'>
                <label>
                  <input id='#{name}' type='checkbox'>#{desc.after}
                </label>
                #{help}
              </div>
            </div>
          </div>"
        else

      elem = ($ "##{name}")
      @elements.settings[name] = elem[0]

      def = @model.settings[name]

      @controller.bindSettings(elem, name, desc.type, def)

      (undefined)

  updateUI: ->
    @placeTest()
    @snapshotButtons()
    if not @model.isGame
      @beforeGameUI()
    else
      if @model.isDay
        @dayUI()
      else
        @nightUI()
    (undefined)

  placeTest: ->
    # Проверяет, появились ли новые игроки и нужны ли для них новые места.
    places = @elements.places

    while places[0].list.length < @model.players.length
      for place in places
        place.this.append(@elements.templates.place)
        listItem = place.this.find "tr:last-child"
        listItem.hide()
        place.list.push {
          this: listItem
          id: listItem.find ".id"
          name: listItem.find ".name"
          health: listItem.find ".health"
          attack: listItem.find ".attack"
          tasks: listItem.find ".tasks"
          actions: {
            this: listItem.find ".actions"
            solve: listItem.find ".solve"
            unsolve: listItem.find ".unsolve"
            treat: [
              listItem.find ".treat0"
              listItem.find ".treat1"
              listItem.find ".treat2"
              listItem.find ".treat3"
            ]
          }
        }
        place.list[-1..][0].actions.this.hide()

      listItem = places[0].list[-1..][0]
      plN = places[0].list.length - 1
      listItem.this.attr "plN", "#{plN}"
      listItem.actions.solve.attr {
        "act":"solve"
        "plN":"#{plN}"
      }
      listItem.actions.unsolve.attr {
        "act":"unsolve"
        "plN":"#{plN}"
      }
      for tr, ind in listItem.actions.treat
        tr.attr {
          "plN": "#{plN}"
          "act":"treat"
          "solved": "#{ind}"
        }


    while places[0].list.length > @model.players.length
      for place in places
        place.list[-1..][0].this.hide().remove()
        place.list.pop()

    (undefined)

  snapshotButtons: ->
    if @model.snapshotPoint != 0
      @elements.buttons.backward.show(500)
    else
      @elements.buttons.backward.hide(500)

    if @model.snapshotPoint != (@model.snapshots.length - 1)
      @elements.buttons.forward.show(500)
    else
      @elements.buttons.forward.hide(500)

    (undefined)

  beforeGameUI: ->
    @nightMode.is = false
    listById = @model.players

    @elements.carousel.this.hideControls()
    @elements.carousel.this.go 0
    @elements.carousel.this.pause()

    @elements.blocks.newPlayer.show 500

    @elements.buttons.daynight.text "Добавление игроков"

    @placeTest()
    @placePlayers [listById]
    (undefined)

  dayUI: ->
    @nightMode.is = false
    @nightMode.attack = -1
    @nightMode.selected = -1
    @elements.carousel.this.showControls()
    @elements.carousel.this.overflow "hidden"
    @elements.carousel.this.go 0
    @elements.carousel.this.start()

    @elements.blocks.newPlayer.hide 500

    ($ ".sun").show()

    getSortF =
    (item) ->
      (a, b) ->
        b[item] - a[item]

    listById = @model.players

    listByHealth = deepCopy(listById)
    listByHealth.sort(getSortF('health'))

    listBySolve = deepCopy(listById)
    listBySolve.sort(getSortF('solve'))

    listByUnsolve = deepCopy(listById)
    listByUnsolve.sort(getSortF('unsolve'))

    @placePlayers [listById, listByHealth, listBySolve, listByUnsolve]
    (undefined)

  nightUI: ->
    @nightMode.is = true

    @elements.carousel.this.hideControls()
    @elements.carousel.this.overflow "visible"
    @elements.carousel.this.go 0
    @elements.carousel.this.pause()

    ($ ".sun").hide()

    @elements.blocks.newPlayer.hide 500

    listById = @model.players

    @elements.buttons.daynight.text "Ночь"

    @placePlayers [listById]
    (undefined)

  placePlayers: (lists) ->
    for list, l in lists
      place = @elements.places[l]

      attackLevel = @model.getLevel @nightMode.attack

      for player, p in list
        listItem = place.list[p]

        listItem.id.text (player.id + 1)
        listItem.name.text player.name
        if @nightMode.is and (p == @nightMode.selected)
          listItem.health.hide()
          listItem.attack.hide()
          listItem.tasks.hide()
          listItem.actions.this.show()
        else
          listItem.health.show().text (player.health * 100).toFixed(0)
          listItem.attack.show().text ((@model.getAttack player.id) * 100).toFixed(0)
          listItem.tasks.show().text "#{player.solve}/#{player.unsolve}"
          listItem.actions.this.hide()
        listItem.this.removeClass().addClass @model.getLevel player.id

        if (@nightMode.attack != -1) and (attackLevel != @model.getLevel p)
          listItem.this.addClass("not").prop("disabled":true)
        else
          listItem.this.removeClass("not")

        listItem.this.show(500)
        (undefined)
      (undefined)
    (undefined)

  updateTime: ->
    minutes = @model.time % 60
    minutes = if minutes < 10 then "0" + minutes else minutes
    @elements.buttons.daynight.text "День (#{@model.time//60}:#{minutes})"

    page_w = ($ "html").width();
    all_time = @model.settings.stTime * 60

    k = @model.time / all_time

    top_max = 70
    top_min = 100

    b = (top_max - top_min) * 4
    a = -b
    c = top_min

    ($ ".sun").offset {
      top: a*k*k + b*k + c
      left: (1-k)*(page_w+150) - 100
      }
    (undefined)

  hit: (plN1, plN2, atk) ->
    console.log "BADABOOM #{plN1} ====> #{plN2}"
    @nightMode.attack = -1
    @nightMode.selected = -1
    @updateUI()
    @popup plN2, "health", (atk * 100)
    (undefined)

  miss: (plN) ->
    console.log "PHAHAHA #{plN}"
    @nightMode.selected = -1
    @nightMode.attack = -1
    @updateUI()
    @popup plN, "name", "Мазила"
    (undefined)

  treat: (plN, inc) ->
    @nightMode.attack = -1
    @nightMode.selected = -1
    @updateUI()
    @popup plN, "health", (inc * 100)
    (undefined)

  popup: (plN, selector, text) ->
    el = @elements.places[0].list[plN][selector]
    left = el.offset().left + el.width() / 2
    top = el.offset().top - el.height() / 2

    if $.isNumeric text
      text = text.toFixed(0)
      if text >= 0
        text = "+" + text

    el.append "<div id='popup'
      class='#{if text >= 0 then 'green' else 'red'}'
      style='opacity:0'>#{text}</div>"
    popup = $ "#popup"
    popup.offset {top: top, left: left}

    # animation
    _this = @
    (popup.animate {
      opacity: [1, "swing"]
      top: ["-=20px", "linear"]
    }, 1000).animate {
        opacity: [0, "swing"]
        top: ["-=20px", "linear"]
      }, 1000, "linear", () ->
        popup.remove()

  attackMode: (plN) ->
    if (-1 == @nightMode.attack)
      @nightMode.attack = plN
    else
      @nightMode.attack = - 1
      @nightMode.selected = -1

    @updateUI()
    (undefined)

  selectMode: (plN) ->
    if -1 != @nightMode.attack
      @model.hit @nightMode.attack, plN
    else
      @nightMode.selected =
        if plN == @nightMode.selected then -1 else plN
      @updateUI()
    (undefined)


window.View = View
