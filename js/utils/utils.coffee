window.getValScope = (val, scope) ->
  if scope[0] > val
    return scope[0]
  else if scope[1] < val
    return scope[1]
  else
    return val

window.deepCopy = (v) ->
  $.extend true, [], v

  