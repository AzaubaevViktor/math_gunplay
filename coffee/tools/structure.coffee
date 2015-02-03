# Массив структур выглядит так:
#        {
#        object1:
#            obj: object1
#            fields: ["field1", "field2"]
#        object2:
#            obj: object2
#            fields: ["f23", "sss3", "yop"]
#        }
# каждое поле должно быть сложным объектом, дабы была возможность отслеживать его изменения

deepCopy = Tools.deepCopy
serializeToObject = Tools.serializeToobject
deserializeFromObject = Tools.deserializeFromObject

saveByStructure = (structure) ->
    backup = {}

    for objectName, element of structure
        for objectField in element.fields
            backup[objectName] = {} if not backup[objectName]?
            backup[objectName][objectField] = serializeToObject element.obj[objectField]

    backup

loadByStructure = (structure, rawData) ->
    for objectName, element of structure
        for objectField in element.fields
            element.obj[objectField] = deserializeFromObject rawData[objectName][objectField]
    undefined


window.Tools.saveByStructure = saveByStructure
window.Tools.loadByStructure = loadByStructure