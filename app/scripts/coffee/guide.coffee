class Ruler.Guide
  el: null

  position: null
  direction: 'vertical'

  padding: 2

  constructor: (position, direction)->
    @direction = direction
    @setPosition(position)

  eDblclick: (e)=>
    target = if e.target.classList.contains('guide') then e.target else Ruler.parent(e.target, '.guide')
    guide = Ruler.Guide.createFromElement(target)
    guide.remove()

  appendTo: (parent)->
    @el = document.createElement('div')
    @el.innerHTML = '<div></div>'
    @el.className = 'guide ' + @direction

    rect = Ruler.app.el.getBoundingClientRect()
    if @direction == 'vertical'
      @el.style.height = Ruler.toPixel(rect.height)
    else
      @el.style.width  = Ruler.toPixel(rect.width)

    @setPosition(@position)

    @el.addEventListener('dblclick', @eDblclick)

    parent.appendChild(@el)

  setPosition: (position)->
    @position = position

    unless @el != null then return

    if @direction == 'vertical'
      @el.style.top  = '0px'
      @el.style.left = Ruler.toPixel(@position.x - @padding)
    else
      @el.style.top  = Ruler.toPixel(@position.y - @padding)
      @el.style.left = '0px'

  remove: ->
    @el.removeEventListener('dblclick', null)
    @el.remove()

  @create: (position, direction)->
    return new Ruler.Guide(position, direction)

  @createFromElement: (el)->
    position  = new Ruler.Point(parseInt(el.style.left), parseInt(el.style.top))
    direction = if el.classList.contains('vertical') then 'vertical' else 'horizontal'
    guide     = new Ruler.Guide(position, direction)
    guide.el  = el
    return guide

  @clearGuides: ->
    for guide in Ruler.app.ruler.querySelectorAll('.guide')
      guide.removeEventListener('dblclick', null)
      guide.remove()
    return

  @restore: (guides)->

    if guides.length == 0 then return
    for guide in guides
      position = new Ruler.Point(guide.position.x, guide.position.y)
      guide = @create(position, guide.direction)
      guide.appendTo(Ruler.app.ruler.querySelector('.guides'))

  @generateWithOptions: (options)->
    rect = Ruler.app.el.getBoundingClientRect()

    elWidth  = rect.width
    elHeight = rect.height

    generate = (direction, count, width, max)=>
      i = 0
      while i < count
        if width > 0
          position = i * width
        else
          position = i / count * max

        if direction == 'vertical'
          pos = new Ruler.Point(position, 0)
          console.log pos
          guide = @create(pos, direction)
        else
          pos = new Ruler.Point(0, position)
          guide = @create(pos, direction)

        guide.appendTo(Ruler.app.ruler.querySelector('.guides'))
        i++

    generate('vertical',   options.columnCount, options.columnWidth, elWidth)
    generate('horizontal', options.rowCount,    options.rowHeight,   elHeight)

  @prepare: ->
    guides = []

    for guide in Ruler.app.ruler.querySelectorAll('.guide')
      guid = Ruler.Guide.createFromElement(guide)
      g =
        direction: guid.direction
        position:
          x: guid.position.x + guid.padding
          y: guid.position.y + guid.padding

      guides.push(g)

    return guides
