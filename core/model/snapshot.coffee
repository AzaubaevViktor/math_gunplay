# Работает с историей изменений

class Snapshot
  constructor: (@structure) ->
    @datas = []
    @current = -1
    @add()

    undefined

  add: ->
    @datas = @datas.slice(0, @current + 1)

    saveByStructure(@structure, true)

    @current += 1

  clear: ->
    @current = -1
    @datas = []
    @add()

    undefined

  load: (id = @current - 1) ->
    @current = getValScope id, [0, @data.length]
    loadByStructure(@structure, @datas[@current])

    undefined


window.Model.Snapshot = Snapshot