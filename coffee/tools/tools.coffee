define
    getValScope: (val, scope) ->
        switch
            when scope[0] > val then scope[0]
            when scope[1] < val then scope[1]
            else val

    strCopy: (s, n) ->
        res = ""
        i = 0
        while i < n
            i += 1
            res += s
        (res)

    deepCopy: (v) ->
        result = new Object
        for property, value of v
            if property[0] != "_"
                if typeof value == "object"
                    result[property] = deepCopy(value)
                else
                    result[property] = value
        result

    max: (a,b) ->
        if a > b then a else b

    min: (a,b) ->
        if a < b then a else b

    remove: (arr, element) ->
        index = arr.indexOf(element)
        arr.splice(index, 1) if index >= 0

    merge: (obj1, obj2) ->
        obj3 = {}
        for attrName of obj1
            obj3[attrName] = obj1[attrName]
        for attrName of obj2
            obj3[attrName] = obj2[attrName]
        obj3