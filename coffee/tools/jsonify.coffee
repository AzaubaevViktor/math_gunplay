# Этот класс позволяет сериализовать классы (даже вложенные друг в друга).
# достаточно задать @JSONProperties как массив с именами параметров, которые
# надо сериализовать, @className -- имя класса и вызвать в конструкторе @register _class,
# где _class -- указатель на текущий класс.


define () ->
    window._JSONify_classes = {}

    isSerializable = (obj) ->
        obj? and obj.serialize?

    _serializeToObject = (obj) ->
        if isSerializable(obj)
            obj.serializeToObject()
        else if typeof obj == "object"
            res = new Object()
            for k, v of obj
                res[k] = switch isSerializable v
                    when true  then v.serializeToObject()
                    when false then _serializeToObject v
            res
        else
            obj

    serialize = (obj) ->
        console.info obj
        JSON.stringify _serializeToObject obj

    _deserializeFromObject = (obj) ->
        res = null
        return undefined if not obj?
        if obj._className? and obj._data?
            res = new window._JSONify_classes[obj._className]
            res.deserializeFromObject obj
        else if typeof obj == "object"
            res = new Object()
            for k, v of obj
                res[k] = _deserializeFromObject v
        else
            res = obj

        res

    deserialize = (jsonString) ->
        _deserializeFromObject JSON.parse jsonString


    class JSONify
        constructor: ->
            @JSONProperties = []
            @className = "JSONify"

        register: (_class) ->
            window._JSONify_classes[@className] = _class

        serializeToObject: ->
            obj = new Object()
            obj._className = @className
            obj._data = {}
            for prop in @JSONProperties
                obj._data[prop] = _serializeToObject this[prop]

            obj

        serialize: ->
            JSON.stringify @serializeToObject()

        deserializeFromObject: (obj) ->
            if obj._className? and obj._data?
                for prop in @JSONProperties
                    if isSerializable(this[prop])
                        this[prop].deserializeFromObject obj._data[prop]
                    else
                        this[prop] = _deserializeFromObject obj._data[prop]
            else
                throw "#{obj} is not serialized #{@className}"
            undefined

        deserialize: (jsonString) ->
            @deserializeFromObject JSON.parse jsonString

    return {
        serializeToobject: _serializeToObject
        deserializeFromObject: _deserializeFromObject
        serialize: serialize
        deserialize: deserialize
        JSONify: JSONify
    }