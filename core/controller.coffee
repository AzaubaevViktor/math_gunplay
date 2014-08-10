class Controller
  constructor: ->
    @isBindNight = 0

  joinModel: (@model) ->
    @bindSaves()

  joinView: (@view) ->

  bind: ->
    els = @view.elements

    input = els.inputs.newPlayer
    input.keyup (e) =>
      if 13 == e.keyCode
        name = input.val()
        input.val ""
        @model.addPlayer name
      (undefined)

    # Кнопка, сменяющая день/ночь вручную и начинающая игру
    els.buttons.daynight.click =>
      @model.changeDayNight()
      (undefined)

    els.buttons.forward.click =>
      @model.forwardSnapshot()
      (undefined)

    els.buttons.backward.click =>
      @model.loadSnapshot()
      (undefined)

    place = @view.elements.places[0]

    place.this.on 'click', "td:not(.actions)", @view, (event) ->
      view = event.data
      plN = parseInt ($ @).parent().attr("plN")
      view.selectMode plN
      (undefined)

    place.this.on 'click', ".btn, a", {"view":@view, "model":@model}, (event) ->
      {view, model} = event.data
      act = ($ @).attr("act")
      plN = parseInt ($ @).attr("plN")
      solved = parseInt ($ @).attr("solved")

      switch act
        when "solve"
          view.attackMode plN
        when "unsolve"
          model.miss plN
        when "treat"
          model.treat plN, solved
          
    (undefined)

  bindNight: ->
    if not @isBindNight
      @isBindNight = 1
      place = @view.elements.places[0]
      for item, plN in place.list

        item.actions.unsolve.on 'click', plN, (event) =>
          plN = event.data
          @model.miss(plN)

        item.actions.solve.on 'click', plN, (event) =>
          plN = event.data
          @view.attackMode plN

        for tr, solved in item.actions.treat
          tr.on 'click', {plN: plN, solved: solved}, (event) =>
            {plN, solved} = event.data
            @model.treat(plN, solved)
          (undefined)

        item.this.on 'click', "td:not(.actions)", plN, (event) =>
          plN = event.data

          @view.selectMode plN

        item.id.css('cursor','pointer')
        item.name.css('cursor','pointer')
        (undefined)


  bindSaves: () ->
    @view.elements.saves.on 'click', '.btn', @model, (event) ->
      model = event.data
      el = ($ @)
      switch el.attr("act")
        when "new"
          model.newSave()
        when "load"
          model.loadSave(el.attr("id"))
        when "delete"
          model.deleteSave(el.attr("id"))

  bindSettingsGenerate: (name, type) ->
    switch type
      when "number"
        return =>
          @model.setSettings name, @view.elements.settings[name].value
      when "checkbox"
        return  =>
          @model.setSettings name, @view.elements.settings[name].checked
      else
        return =>


  bindSettings: (elem, name, type, def) ->
    elem = $("##{name}")

    switch type
      when "number"
        elem.val(def)
        elem.keyup @bindSettingsGenerate name, type
      when "checkbox"
        elem[0].checked = def
        elem.on 'click', @bindSettingsGenerate name, type
      else

    (undefined)


window.Controller = Controller
