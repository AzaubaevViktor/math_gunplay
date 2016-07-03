window.getValScope = (val, scope) ->
  if scope[0] > val
    return scope[0]
  else if scope[1] < val
    return scope[1]
  else
    return val

window.deepCopy = (v) ->
  $.extend true, [], v


window.btn = (id, text, color) ->
  $("<a id='#{id}'>").addClass("waves-effect waves-light btn #{color}").text(text)
