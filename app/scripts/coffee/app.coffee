class Ruler.App

  el: null
  ruler: null

  precision: 5
  save: true

  current: null
  press: false

  options: null


  # Setup
  constructor: (selector)->
    @_initialize()
    @_events()

    @setSelector(selector)

    setTimeout(()=>
        @_restore()
    , 500)

  _initialize: ->
    ruler           = document.createElement('div')
    ruler.id        = 'ruler'
    ruler.innerHTML = Ruler.HTML.Content + Ruler.HTML.Panel
    document.body.appendChild(ruler)
    @ruler          = ruler

  _restore: ->
    saveData = JSON.parse(window.localStorage.getItem('ruler'))

    if saveData != null
      @_restoreOptions(saveData.options)
      Ruler.Guide.restore(saveData.data.guides)
    else
      @createSaveData()

  #######################
  ##  EVENTS
  #######################
  _events: ->
    $(window).on('resize', @calculate)

    # $(document).on('click', '#ruler .panel button', (e)=>
    #   e.preventDefault()
    #   @applyOptions(e.target.getAttribute('data-target'))
    # )

    @ruler.querySelector('.menu').addEventListener('click', @eMenuClick)

    for toggle in @ruler.querySelectorAll('.toggle')
      toggle.addEventListener('click', @eToggleClick)

    for input in @ruler.querySelectorAll('.options input')
      input.addEventListener('change', @eInputChange)

    $(document).on('click', '#ruler .panel .toggle', (e)->
      e.preventDefault()

      $(this).toggleClass('on off')
      $(this).find('input').click()
    )

    @ruler.addEventListener('mouseup',    @eMouseUp)
    @ruler.addEventListener('mouseleave', @eMouseUp)
    @ruler.addEventListener('mousedown',  @eMouseDown)
    @ruler.addEventListener('mousemove',  @eMouseMove)

  eMouseUp: (e)=>
    if @press and @current != null
      @ruler.style.cursor = 'inherit'
      document.querySelector('.infos').classList.add('hidden')
      @current = null
      @press   = false

      @save()

  eMouseDown: (e)=>
    target = if e.target.classList.contains('rule') then e.target else Ruler.parent(e.target, '.rule')
    if target and not @press
      direction = if target.classList.contains('vertical') then 'vertical' else 'horizontal'
      position  = new Ruler.Point(0, 0)
      guide     = new Ruler.Guide.create(position.locationInView(@el), direction)
      guide.appendTo(@ruler.querySelector('.guides'))

      @current  = guide
      @press    = true
    else
      target = if e.target.classList.contains('guide') then e.target else Ruler.parent(e.target, '.guide')

      if target
        @current = new Ruler.Guide.createFromElement(target)
        @press = true

    if @current and @press
      if @current.direction == 'vertical'
        @ruler.style.cursor = 'col-resize'
      else
        @ruler.style.cursor = 'row-resize'

  eMouseMove: (e)=>
    rect = @el.getBoundingClientRect()
    rct = @ruler.getBoundingClientRect()

    position = new Ruler.Point(e.clientX, e.clientY)
    position.x -= rect.left - 1
    position.y -= rect.top  - 1

    position.x = Ruler.range(position.x, 0, rect.width)
    position.y = Ruler.range(position.y, 0, rect.height)

    document.querySelector('.horizontal .indicator').style.left = position.pixels().x
    document.querySelector('.vertical   .indicator').style.top  = position.pixels().y

    if @press and @current != null
      document.querySelector('.infos').innerHTML = ''

      pos   = position
      pos.x += 1
      pos.y += 1
      @current.setPosition(pos)

      if @current.direction == 'vertical'
        document.querySelector('.infos').innerHTML  = position.pixels().x
        document.querySelector('.infos').style.top  = '0px'
        document.querySelector('.infos').style.left = position.pixels().x
      else
        document.querySelector('.infos').innerHTML  = position.pixels().y
        document.querySelector('.infos').style.top  = position.pixels().y
        document.querySelector('.infos').style.left = '0px'

      document.querySelector('.infos').classList.remove('hidden')
    else
      document.querySelector('.infos').classList.add('hidden')

  #######################
  ##  SETTERS
  #######################
  setSelector: (selector)->
    if @el != null
      @el.style.marginTop  = @el.getAttribute('data-original-marginTop')  if @el.getAttribute('data-original-marginTop') != null
      @el.style.marginLeft = @el.getAttribute('data-original-marginLeft') if @el.getAttribute('data-original-marginLeft') != null
      @el.removeAttribute('data-original-marginTop')
      @el.removeAttribute('data-original-marginLeft')

    @selector = selector
    @el       = document.querySelector(selector)
    rect      = @el.getBoundingClientRect()

    if selector != 'body'
      left = rect.left
      top  = rect.top
    else
      left = 0
      top  = 0

    left   += $(window).scrollLeft() - Ruler.CSS.ruleWidth
    top    += $(window).scrollTop()  - Ruler.CSS.ruleHeight

    if top < 0
      @el.setAttribute('data-original-marginTop', @el.style.marginTop)
      marginTop = if @el.style.marginTop.length then parseFloat(@el.style.marginTop) else 0
      marginTop += Math.abs(top)
      @el.style.marginTop = Ruler.toPixel(marginTop)
      top = 0
    if left < 0
      @el.setAttribute('data-original-marginLeft', @el.style.marginLeft)
      marginLeft = if @el.style.marginLeft.length then parseFloat(@el.style.marginLeft) else 0
      marginLeft += Math.abs(left)
      @el.style.marginLeft = Ruler.toPixel(marginLeft)
      left = 0

    @ruler.style.left   = Ruler.toPixel(left)
    @ruler.style.top    = Ruler.toPixel(top)
    @ruler.style.width  = Ruler.toPixel(rect.width  + Ruler.CSS.ruleWidth)
    @ruler.style.height = Ruler.toPixel(rect.height + Ruler.CSS.ruleHeight)

    @calculate()

  setPrecision: (precision)->
    @precision = precision
    @calculate()

  setToggleSave: (enable)->
    @toggleSave = enable

  setPositionFixed: (positionFixed)->
    @positionFixed = positionFixed
    if positionFixed then @ruler.classList.add('fixed')
    else @ruler.classList.remove('fixed')

  #######################
  ##  RULERS
  #######################
  calculate: =>
    document.querySelector('.horizontal').innerHTML = ''
    document.querySelector('.vertical').innerHTML   = ''

    rect = @el.getBoundingClientRect()

    if @selector != 'body'
      width  = rect.width
      height = rect.height
    else
      width  = window.innerWidth
      height = window.innerHeight

    gap = Math.max(width, height) / @precision

    createLIElement = (direction, position, measure)->
      li = document.createElement('li')
      li.className = clss
      li.setAttribute('data-measure', measure)

      if direction == 'vertical'
        li.style.top = Ruler.toPixel(position)
      else
        li.style.left = Ruler.toPixel(position)
      document.querySelector('.'+direction).appendChild(li)

    createPElement = (i, direction, position)=>
        p            = document.createElement('p')
        p.innerHTML  = @precision * i
        if direction == 'vertical'
          p.style.top  = (position + 2)+'px'
          p.style.left = '2px'
        else
          p.style.top  = '2px'
          p.style.left = (position + 2)+'px'
        document.querySelector('.'+direction).appendChild(p)

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

      if position < height then createLIElement('vertical',   position, measure)
      if position < width  then createLIElement('horizontal', position, measure)

      if measure % 100 == 0
        if position < height then createPElement(i, 'vertical',   position) if position+1 < height
        if position < width  then createPElement(i, 'horizontal', position) if position+1 < width
      i++

    indicator = document.createElement('li')
    indicator.className = 'indicator'
    document.querySelector('.horizontal').appendChild(indicator)
    document.querySelector('.horizontal').style.left  = Ruler.CSS.ruleWidth + 'px'
    document.querySelector('.horizontal').style.width = width + 'px'

    indicator = indicator.cloneNode(true)
    document.querySelector('.vertical').appendChild(indicator)
    document.querySelector('.vertical').style.top     = Ruler.CSS.ruleHeight + 'px'
    document.querySelector('.vertical').style.height  = height + 'px'

    return

  #######################
  ##  SAVEDATA
  #######################
  createSaveData: ->
    saveData =
      options:
        selector: @selector
        precision: @precision
        toggle_save: @toggleSave
        position_fixed: @positionFixed
      data:
        guides: []

    window.localStorage.setItem('ruler', JSON.stringify(saveData))
    return saveData

  _prepareData: ->
    data = {}
    data.guides = if @toggleSave then Ruler.Guide.prepare() else []
    return data

  save: ->
    console.log('PREPARE TO SAVE')

    @ready = false
    clearTimeout(@test)
    @test  = setTimeout(()=>
      @ready = true
    , 250)

    clearTimeout(@timer)
    @timer = setTimeout(()=>
      if @ready
        console.log('SAVE')
        data    = @_prepareData()
        options = @_prepareOptions()

        object         = JSON.parse(window.localStorage.getItem('ruler'))
        object.data    = data
        object.options = options
        window.localStorage.setItem('ruler', JSON.stringify(object))
      else
        @save()
    , 500)

  #######################
  ##  OPTIONS
  #######################
  _prepareOptions: ->
    options =
        selector: @selector
        precision: @precision
        toggle_save: @toggleSave
        position_fixed: @positionFixed

    return options

  _restoreOptions: (options)->
      @setSelector(options.selector)
      @ruler.querySelector('#selector').value = @selector

      @setPrecision(options.precision)
      @ruler.querySelector('#precision').value = @precision

      @setToggleSave(options.toggle_save)
      @ruler.querySelector('#toggle_save input').checked = @toggleSave
      if @toggleSave
        @ruler.querySelector('#toggle_save').classList.add('on')
      else
        @ruler.querySelector('#toggle_save').classList.remove('on')

      @setPositionFixed(options.position_fixed)
      @ruler.querySelector('#position_fixed input').checked = @positionFixed
      if @positionFixed
        @ruler.querySelector('#position_fixed').classList.add('on')
      else
        @ruler.querySelector('#position_fixed').classList.remove('on')

  eToggleClick: (e)=>
      t = if e.target.classList.contains('.toggle') then e.target else Ruler.parent(e.target, '.toggle')
      if t
        t.classList.toggle('on')
        t.querySelector('input[type=checkbox]').checked = t.classList.contains('on')

  eInputChange: (e)=>
    e.preventDefault()
    t = e.target
    t.blur()

    if t.name == 'selector'
      @setSelector(t.value)
    if t.name == 'precision'
      @setPrecision(t.value)
    if t.name == 'toggle_save'
      @setToggleSave(@ruler.querySelector('#toggle_save').classList.contains('on'))
    if t.name == 'position_fixed'
      @setPositionFixed(@ruler.querySelector('#position_fixed').classList.contains('on'))

    if (
      t.name == 'column_count' or
      t.name == 'row_count' or
      t.name == 'column_width' or
      t.name == 'row_height'
    )
      options =
        columnCount: parseInt(@ruler.querySelector('#column_count').value)
        rowCount: parseInt(@ruler.querySelector('#row_count').value)
        columnWidth: parseInt(@ruler.querySelector('#column_width').value)
        rowHeight: parseInt(@ruler.querySelector('#row_height').value)

      Ruler.Guide.generateWithOptions(options)

    @save()


  eMenuClick: (e)=>
    @ruler.querySelector('.panel').classList.toggle('hidden')

    # if optionName == 'general'
    #   precision        = parseInt(document.querySelector('#ruler .options #precision').value)
    #   save = document.querySelector('#ruler .options #save_guides').checked

    #   @setPrecision(precision)
    #   @setSave(save)

    # if optionName == 'generator'
    #   options =
    #     columnCount: parseInt(document.querySelector('#ruler .generator #column_count').value)
    #     columnWidth: parseFloat(document.querySelector('#ruler .generator #column_width').value)
    #     rowCount:    parseInt(document.querySelector('#ruler .generator #row_count').value)
    #     rowHeight:   parseFloat(document.querySelector('#ruler .generator #row_height').value)

    #   Ruler.Guide.generateWithOptions(options)

    # if optionName == 'clear_guides'
    #   Ruler.Guide.clearGuides()
