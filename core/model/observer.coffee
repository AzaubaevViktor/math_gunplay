# Слежение за объектами

observer = new Object
observer._observeHandlers = {}
observer.observe = (object, property, callback) ->
  handler = (changes) =>
    for change in changes
      callback(change.type, change.oldValue, object[property]) if property is change.name
    undefined

  @_observeHandlers[property] = [] if not @_observeHandlers[property]?
  @_observeHandlers[property].push([object, handler])

  Object.observe(object, handler)

observer.unobserve = (object, property) ->
  if @_observeHandlers[property]?
    for [_object, _handler] in @_observeHandlers[property]
      Object.unobserve(_object, _handler) if object is _object
    delete @_observeHandlers[property] if @_observeHandlers[property].lenght is 0
  undefined

window.Model.observer = observer