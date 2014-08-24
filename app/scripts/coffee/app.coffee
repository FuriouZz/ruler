class Ruler.App

  precision: 5
  selector: null

  current: null
  press: false

  generator: null

  constructor: (selector)->
    @_initialize()
    @_events()

    @setElement(selector)
    @calculate()

  _initialize: ->
    ruler           = document.createElement('div')
    ruler.id        = 'ruler'
    ruler.innerHTML = '<span></span><ul class="rule horizontal"></ul><ul class="rule vertical"></ul>'
    ruler.innerHTML += '<div class="infos"></div>'
    document.querySelector('body').appendChild(ruler)

    @restoreGuides()

    @generator =
      columnCount: 5
      rowCount: 5
      columnWidth: 10
      rowHeight: 10

  generate: ->
    winwidth  = window.innerWidth
    winheight = window.innerHeight

    generateGuides = (direction, count, width)=>
      i = 0
      while i < count
        if width > 0
          position = i * width
        else
          position = i / count * winwidth
        @createGuide(direction, position + 16)
        i++

    generateGuides('vertical',   @generator.columnCount, @generator.columnWidth)
    generateGuides('horizontal', @generator.rowCount,    @generator.rowHeight)

    @save()

  _events: ->
    $(window).on('resize', @calculate)

    document.querySelector('#ruler').addEventListener('mouseup', @eMouseUp)
    document.querySelector('#ruler').addEventListener('mousedown', @eMouseDown)
    document.querySelector('#ruler').addEventListener('mousemove', @eMouseMove)

  restoreGuides: ->
    guides = JSON.parse(window.localStorage.getItem('ruler'))
    unless guides then return
    for guide in guides
      position = if guide.direction == 'vertical' then guide.position.left else guide.position.top
      @createGuide(guide.direction, position)

  clearGuides: ->
    guides = document.querySelectorAll('#ruler .guide')
    for guide in guides
      guide.remove()

      @save()
    return

  save: ->
    if window.localStorage
      data = '['

      guides = document.querySelectorAll('#ruler .guide')
      for guide in guides
        data += '{"position":{"top":"'+parseInt(guide.style.top)+'", "left":"'+parseInt(guide.style.left)+'"},'
        data += '"direction":"'+guide.className.split('guide ')[1]+'"},'

      data = data.substr(0, data.length-1)
      data += ']'

      if guides.length
        window.localStorage.setItem('ruler', data)
      else
        window.localStorage.removeItem('ruler')

  eDblclick: (e)=>
    target = if /guide/.test(e.target.className) then e.target else e.target.parentNode
    target.remove()
    @save()

  eMouseUp: (e)=>
    document.querySelector('#ruler').style.cursor = 'inherit'
    document.querySelector('.infos').classList.add('hidden')
    @current = null
    @press   = false

    @save()

  eMouseDown: (e)=>
    # If the target is a rule, enable move
    unless /rule/.test(e.target.className)
      target = if /guide/.test(e.target.className) then e.target else e.target.parentNode

      if /guide/.test(target.className)
        @current = target
        @press   = true
      return

    # Else get direction and position, then create a guide
    direction = if /vertical/.test(e.target.className) then 'vertical' else 'horizontal'
    position  = if /vertical/.test(e.target.className) then e.clientX  else e.clientY

    @current  = @createGuide(direction, position)
    @press    = true

  eMouseMove: (e)=>
    document.querySelector('.horizontal .indicator').style.left = Math.max((e.clientX - 17), 0)+'px'
    document.querySelector('.vertical .indicator').style.top    = Math.max((e.clientY - 17), 0)+'px'

    if @press and @current != null
      document.querySelector('.infos').innerHTML = ''

      position = 0
      if /vertical/.test(@current.className)
        position = e.clientX+'px'
        @current.style.left = position
      else
        position = e.clientY+'px'
        @current.style.top  = position

      document.querySelector('.infos').classList.remove('hidden')
      document.querySelector('.infos').innerHTML  = (parseInt(position) - 16)+'px'
      document.querySelector('.infos').style.top  = e.clientY+'px'
      document.querySelector('.infos').style.left = e.clientX+'px'
    else
      document.querySelector('.infos').classList.add('hidden')

  createGuide: (direction, position)->
    div = document.createElement('div')
    div.innerHTML = '<div></div>'
    div.className = 'guide ' + direction

    if direction == 'vertical'
      div.style.top  = '0px'
      div.style.left = position+'px'
      document.querySelector('#ruler').style.cursor = 'col-resize'
    else
      div.style.top  = position+'px'
      div.style.left = '0px'
      document.querySelector('#ruler').style.cursor = 'row-resize'

    document.querySelector('#ruler').appendChild(div)

    # Reset dblclick event
    guides = document.querySelectorAll('#ruler .guide')
    for guide in guides
      guide.removeEventListener('dblclick', null)
      guide.addEventListener('dblclick', @eDblclick)

    return div

  setElement: (selector)->
    @selector = selector

    rect = document.querySelector(selector).getBoundingClientRect()

    document.querySelector('#ruler').style.position = 'fixed'
    document.querySelector('#ruler').style.top  = rect.top + 'px'
    document.querySelector('#ruler').style.left = rect.left + 'px'

    document.querySelector('body').style.position = 'absolute'
    document.querySelector('body').style.top = '18px'
    document.querySelector('body').style.left = '18px'

  setPrecision: (precision)->
    @precision = precision
    @calculate()

  calculate: =>
    document.querySelector('.horizontal').innerHTML = ''
    document.querySelector('.vertical').innerHTML   = ''

    rect = document.querySelector(@selector).getBoundingClientRect()

    if @selector != 'body'
      width  = rect.width  - 1
      height = rect.height - 1
    else
      width  = window.innerWidth  - 1
      height = window.innerHeight - 1

    gap = Math.max(width, height) / @precision

    i = 0
    while i < gap
      measure  = i * @precision
      position = measure - 1

      condition = (
        ((measure - 75) % 100 == 0 and @precision % 5 == 0) or
        ((measure - 25) % 100 == 0 and @precision % 5 == 0) or
        ((measure - 80) % 100 == 0 and @precision % 2 == 0) or
        ((measure - 60) % 100 == 0 and @precision % 2 == 0) or
        ((measure - 40) % 100 == 0 and @precision % 2 == 0) or
        ((measure - 20) % 100 == 0 and @precision % 2 == 0)
      )

      clss = 'gap-25'
      if measure % 100 == 0
        clss = 'gap-100'
      else if (measure - 50) % 100 == 0 and @precision % 5 == 0
        clss = 'gap-75'
      else if condition
        clss = 'gap-50'

      li           = document.createElement('li')
      li.className = clss
      li.style.top = position+'px'
      li.setAttribute('data-measure', measure)

      document.querySelector('.vertical').appendChild(li) if position < height

      li            = li.cloneNode(true)
      li.style.top  = 'inherit'
      li.style.left = position+'px'
      document.querySelector('.horizontal').appendChild(li) if position < width

      if measure % 100 == 0
        p            = document.createElement('p')
        p.innerHTML  = @precision * i
        p.style.top  = (position + 2)+'px'
        p.style.left = '2px'
        document.querySelector('.vertical').appendChild(p)

        p            = p.cloneNode(true)
        p.style.top  = '2px'
        p.style.left = (position + 2)+'px'
        document.querySelector('.horizontal').appendChild(p)

      i++

    indicator = document.createElement('li')
    indicator.className = 'indicator'
    document.querySelector('.horizontal').appendChild(indicator)
    document.querySelector('.horizontal').style.left  = 18    + 'px'
    document.querySelector('.horizontal').style.width = width + 'px'

    indicator = indicator.cloneNode(true)
    document.querySelector('.vertical').appendChild(indicator)
    document.querySelector('.vertical').style.top     = 18    + 'px'
    document.querySelector('.vertical').style.height  = height + 'px'

    return
