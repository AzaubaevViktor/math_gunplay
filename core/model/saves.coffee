# Сохранения в игре

class Saves
  @protocolVersion = 1
  constructor: (@structure) ->
    @saves = storage.load 'saves'
    @_setDefault() if @saves and @saves.version isnt @protocolVersion

  new: ->
    now = new Date

    id = 1488
    while id in @saves.ids
      id = Math.floor(Math.random() * 100000000000000000)

    @saves.ids[id] = "{#now}"
    _save()
    _save(id, saveByStructure(@structure))

  delete: (id) ->
    delete @saves.ids[id]
    _save()
    storage.delete("save#{id}")

  load: (id) ->
    loadByStructure(@structure, storage.load "save#{id}")

  _save: (id = -1, data = undefined ) ->
    switch id
      when -1 then storage.save 'saves', @saves
      else storage.save "save#{id}", data

  _setDefault: ->
    delete @saves
    @saves = {}
    @saves =
      version: @protocolVersion
      ids: {}

    @_save()


window.Model.Saves = Saves