# Настройки игры

class Settings
  @protocolVersion = 1
  constructor: (@_settingsDesc) ->
    @datas = storage.load 'settings'
    @datas = @_setDefault() if @datas and @datas.version isnt @protocolVersion

    for k,v of @_settingsDesc
      console.log(k,v.def)
      (this[k] = () => @_settingsDesc[k].def) if @_settingsDesc[k].def?

  _save: ->
    storage.save 'settings', @datas

  _setDefault: ->
    delete @datas
    @datas = {}
    for k,v of @_settingsDesc
      @datas[k] = v.def if @_settingsDesc[k].def?
    @_save()

  set: (name, value) ->
    @datas[name] = value
    @_save()


window.Model.Settings = Settings