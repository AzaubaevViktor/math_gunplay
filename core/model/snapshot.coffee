# Работает с историей изменений

saveByStructure = Tools.saveByStructure
loadByStructure = Tools.loadByStructure
getValScope = Tools.getValScope

class Snapshot
  constructor: (@obj) ->
    @datas = []
    @current = -1
    @add()

    undefined

  add: ->
    @datas = @datas.slice 0, @current + 1

    @datas.push @obj.serializeToObject()

    @current += 1

  clear: ->
    @current = -1
    @datas = []
    @add()

    undefined

  _load: (id = @current - 1) ->
    @current = getValScope id, [0, @data.length]
    @obj.deserializeFromObject @datas[@current]

    @current

  undo: ->
    @_load()

  redo: ->
    @current = getValScope @current + 1, [0, @data.length]
    _load @current


window.Model.Snapshot = Snapshot