# Этот класс позволяет сериализовать классы (даже вложенные друг в друга).
# достаточно задать @JSONProperties как массив с именами параметров, которые
# надо сериализовать, @className -- имя класса и вызвать в конструкторе @register _class,
# где _class -- указатель на текущий класс.

window.Tools._JSONify_classes = {}

isSerializable = (obj) ->
  obj.serialize?

serialize2object = (obj) ->
  if isSerializable(obj)
    obj._serialize()
  else if typeof obj == "object"
    res = new Object()
    for k, v of obj
      res[k] = switch isSerializable(v)
        when true  then v._serialize()
        when false then serialize2object(v)
    res
  else
    obj

serialize = (obj) ->
  console.info(obj)
  JSON.stringify serialize2object obj

deserializeFromObject = (datas) ->
  obj = null
  if datas._className? and datas._data?
    obj = new window.Tools._JSONify_classes[datas._className]
    obj._deserialize(datas)
  else if typeof datas == "object"
    obj = new Object()
    for k, v of datas
      obj[k] = deserializeFromObject(v)
  else
    obj = datas

  obj

deserialize = (jsonString) ->
  deserializeFromObject JSON.parse jsonString


class JSONify
  constructor: ->
    @JSONProperties = []
    @className = "JSONify"

  register: (_class) ->
    window.Tools._JSONify_classes[@className] = _class

  _serialize: ->
    res = new Object()
    res._className = @className
    res._data = {}
    for prop in @JSONProperties
      res._data[prop] = serialize2object(this[prop])

    res

  serialize: ->
    JSON.stringify @_serialize()

  _deserialize: (datas) ->
    if datas._className? and datas._data?
      for prop in @JSONProperties
        this[prop] = deserializeFromObject(datas._data[prop])
    else
      throw "#{datas} is not serialized #{@className}"
    undefined

  deserialize: (jsonString) ->
    @_deserialize JSON.parse jsonString

window.Tools.serialize2object = serialize2object
window.Tools.deserializeFromObject = deserializeFromObject
window.Tools.serialize = serialize
window.Tools.deserialize = deserialize
window.Tools.JSONify = JSONify