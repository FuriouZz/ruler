class Ruler.Point
  x: 0
  y: 0

  constructor: (x, y)->
    @x = x
    @y = y

  pixels: ->
    return {
      x: Ruler.toPixel(@x)
      y: Ruler.toPixel(@y)
    }

  locationInView: (view)->
    rect = document.querySelector('.plouf').getBoundingClientRect()
    x = Math.max(@x - rect.left + Ruler.CSS.ruleWidth, 0)
    y = Math.max(@y - rect.top + Ruler.CSS.ruleHeight, 0)
    return new Ruler.Point(x, y)
