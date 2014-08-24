class Ruler.App

  precision: 10
  selector: null

  current: null
  press: false


  constructor: (selector)->
    @_initialize()
    @_events()

    @setElement(selector)
    @calculate()

  _initialize: ->
    ruler           = document.createElement('div')
    ruler.id        = 'ruler'
    ruler.innerHTML = '<span></span><ul class="rule horizontal"></ul><ul class="rule vertical"></ul>'
    document.querySelector('body').appendChild(ruler)

  _events: ->
    $(window).on('resize', @calculate)

    document.querySelector('#ruler').addEventListener('mouseup', @eMouseUp)
    document.querySelector('#ruler').addEventListener('mousedown', @eMouseDown)
    document.querySelector('#ruler').addEventListener('mousemove', @eMouseMove)

  eDblclick: (e)=>
    target = if /guide/.test(e.target.className) then e.target else e.target.parentNode
    target.remove()

  eMouseUp: (e)=>
    document.querySelector('#ruler').style.cursor = 'inherit'
    @current = null
    @press   = false

  eMouseDown: (e)=>
    unless /rule/.test(e.target.className)
      target = if /guide/.test(e.target.className) then e.target else e.target.parentNode

      if /guide/.test(target.className)
        @current = target
        @press   = true
      return

    div = document.createElement('div')
    div.innerHTML = '<div></div>'
    div.className = 'guide ' + if /vertical/.test(e.target.className) then 'vertical' else 'horizontal'
    if /vertical/.test(e.target.className)
      div.style.left = e.clientX+'px'
      document.querySelector('#ruler').style.cursor = 'col-resize'
    else
      div.style.top = e.clientY+'px'
      document.querySelector('#ruler').style.cursor = 'row-resize'
    document.querySelector('#ruler').appendChild(div)

    document.querySelector('#ruler .guide').removeEventListener('dblclick')
    document.querySelector('#ruler .guide').addEventListener('dblclick', @eDblclick)

    @current = div
    @press   = true

  eMouseMove: (e)=>
    document.querySelector('.horizontal .indicator').style.left = Math.max((e.clientX - 17), 0)+'px'
    document.querySelector('.vertical .indicator').style.top    = Math.max((e.clientY - 17), 0)+'px'

    if @press and @current != null
      if /vertical/.test(@current.className)
        @current.style.left = e.clientX+'px'
      else
        @current.style.top  = e.clientY+'px'

  setElement: (selector)->
    @selector = selector

    rect = document.querySelector(selector).getBoundingClientRect()

    document.querySelector('#ruler').style.position = 'fixed'
    document.querySelector('#ruler').style.top  = rect.top + 'px'
    document.querySelector('#ruler').style.left = rect.left + 'px'

    document.querySelector('body').style.position = 'absolute'
    document.querySelector('body').style.top = '18px'
    document.querySelector('body').style.left = '18px'

  calculate: =>
    document.querySelector('.horizontal').innerHTML = ''
    document.querySelector('.vertical').innerHTML   = ''

    rect   = document.querySelector(@selector).getBoundingClientRect()

    if @selector != 'body'
      width  = rect.width  - 1
      height = rect.height - 1
    else
      width  = window.innerWidth  - 1
      height = window.innerHeight - 1

    gap = Math.max(width, height) / @precision

    i = 0
    while i < gap
      position = (i * @precision - 1)
      clss     = if (i * @precision) % 100 == 0 then 'gap' else if (i * @precision) % 50 == 0 then 'mid-gap' else ''

      li           = document.createElement('li')
      li.className = clss
      li.style.top = position+'px'

      document.querySelector('.vertical').appendChild(li) if position < height

      li            = li.cloneNode(true)
      li.style.top  = 'inherit'
      li.style.left = position+'px'
      document.querySelector('.horizontal').appendChild(li) if position < width

      if (i * @precision) % 100 == 0
        p            = document.createElement('p')
        p.innerHTML  = 10 * i
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
