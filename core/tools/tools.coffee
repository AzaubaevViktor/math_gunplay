getValScope = (val, scope) ->
  switch
    when scope[0] > val then scope[0]
    when scope[1] < val then scope[1]
    else val

strCopy = (s, n) ->
  res = ""
  i = 0
  while i < n
    i += 1
    res += s
  (res)

deepCopy = (v) ->
  result = new Object
  for property, value of v
    if property[0] != "_"
      if typeof value == "object"
        result[property] = deepCopy(value)
      else
        result[property] = value
  result

max = (a,b) ->
  if a > b then a else b

min = (a,b) ->
  if a < b then a else b

remove = (arr, element) ->
  index = arr.indexOf(element)
  arr.splice(index, 1) if index >= 0

class _Carousel
  constructor: (@elem) ->

  start: ->
    @elem.carousel "cycle"

  pause: ->
    @elem.carousel "pause"

  go: (num) ->
    @elem.carousel num

  next: ->
    @elem.carousel "next"

  prev: ->
    @elem.carousel "prev"

  hideControls: ->
    @elem.find(".carousel-control").fadeOut(500)
    @elem.find(".carousel-indicators").fadeOut(500)
    undefined

  showControls: ->
    @elem.find(".carousel-control").fadeIn(500)
    @elem.find(".carousel-indicators").fadeIn(500)
    undefined

  overflow: (st) ->
    @elem.css {
      "overflow": st
    }

window.Tools.getValScope = getValScope
window.Tools.strCopy = strCopy
window.Tools.deepCopy = deepCopy
window._Carousel = _Carousel
window.Tools.max = max
window.Tools.min = min
window.Tools.remove = remove
