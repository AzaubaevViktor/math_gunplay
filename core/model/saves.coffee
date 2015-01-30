# Сохранения в игре

saveByStructure = Tools.saveByStructure
loadByStructure = Tools.loadByStructure
storage = Tools.storage

class Saves
  constructor: (@structure) ->
    @protocolVersion = 1
    @saves = storage.load 'saves'
    @saves = {ids: {}} if not @saves?
    @_setDefault() if @saves? and @saves.version isnt @protocolVersion

  new: ->
    now = (new Date).toLocaleString()

    id = 1488
    while @saves.ids[id]?
      id = Math.floor(Math.random() * 100000000000000000)
      console.log(id)

    @saves.ids[id] = "#{now}"
    @_save()
    @_save(id, saveByStructure(@structure))
    "#{now}"

  delete: (id) ->
    delete @saves.ids[id]
    @_save()
    storage.delete("save#{id}")

  load: (id) ->
    loadByStructure(@structure, storage.load "save#{id}")

  getList: ->
    @saves.ids

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