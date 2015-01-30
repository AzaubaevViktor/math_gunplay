# Массив структур выглядит так:
#    {
#    object1:
#      obj: object1
#      fields: ["field1", "field2"]
#    object2:
#      obj: object2
#      fields: ["f23", "sss3", "yop"]
#    }
# каждое поле должно быть сложным объектом, дабы была возможность отслеживать его изменения

saveByStructure = (structure, isDeepCopy = false) ->
  backup = {}

  for objectName, element of structure
    for objectField in element.fields
      backup[objectName][objectField] = if isDeepCopy then deepCopy element.obj[objectField] else element.obj[objectField]

  backup

loadByStructure = (structure, savedData) ->
  for objectName, element of structure
    for objectField in element.fields
      element.obj[objectField] = savedData[objectName][objectField]
  undefined


window.Model.saveByStructure = saveByStructure
window.Model.loadByStructure = loadByStructure