getValScope = (val, scope) ->
  if scope[0] > val
    return scope[0]
  else if scope[1] < val
    return scope[1]
  (val)

strCopy = (s, n) ->
  res = ""
  i = 0
  while i < n
    i += 1
    res += s
  (res)

deepCopy = (v) ->
  ($.extend true, [], v)

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

window.getValScope = getValScope
window.strCopy = strCopy
window.deepCopy = deepCopy
window._Carousel = _Carousel
