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
