window.getValScope = (val, scope) ->
  if scope[0] > val
    return scope[0]
  else if scope[1] < val
    return scope[1]
  else
    return val

window.deepCopy = (v) ->
  $.extend true, [], v


window.btn = (act, text, color, callback) ->
  $("<a act='#{act}'>").addClass("waves-effect waves-light btn #{color}").text(text).on('click', callback)


class Stor
  constructor: ->

  get: (key) ->
    JSON.parse localStorage.getItem(key)

  set: (key, obj) ->
    localStorage.setItem key, JSON.stringify obj

  remove: (key) ->
    localStorage.removeItem key

window.Stor = new Stor()

window.MGDebug = () ->
  console.group 'DEBUG'
  if window.mgModelSettings?
    console.info 'window.mgModelSettings:'
    console.log JSON.stringify window.mgModelSettings
  else
    console.warn 'Model Settings not found'

  if window.mgModel?
    console.info 'window.mgModel:'
    console.log JSON.stringify window.mgModel
  else
    console.warn 'Model not found'

  if window.snapshotter?
    console.info 'window.snapshotter OK'
  else
    console.warn 'Snapshotter not found'


  if window.mgViewSettings?
    console.info 'window.mgViewSettings:'
    console.log JSON.stringify window.mgViewSettings
  else
    console.warn 'ViewSettings not found'

  if window.mgView?
    console.info 'window.mgView:'
    console.log JSON.stringify window.mgView
  else
    console.warn 'View not found'

  if window.mgController?
    console.info 'window.mgController:'
    console.log JSON.stringify window.mgController
  else
    console.warn 'Controller not found'
  console.groupEnd()