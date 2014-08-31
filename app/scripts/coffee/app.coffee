class Ruler.App

  selector: null

  precision: 5
  enableSaveGuides: true

  guides: null

  current: null
  press: false

  options: null


  # Setup
  constructor: (selector)->
    @setSelector(selector)
    @_initialize()
    @_events()

    @calculate()

  _initialize: ->
    @restore()

  #######################
  ##  EVENTS
  #######################
  _events: ->
    $(window).on('resize', @calculate)

    $(document).on('click', '#ruler .panel button', (e)=>
      e.preventDefault()
      @applyOptions(e.target.getAttribute('data-target'))
    )

    $(document).on('click', '#ruler .panel .toggle', (e)->
      e.preventDefault()

      $(this).toggleClass('on off')
      $(this).find('input').click()
    )

    document.querySelector('#ruler').addEventListener('mouseup', @eMouseUp)
    document.querySelector('#ruler').addEventListener('mousedown', @eMouseDown)
    document.querySelector('#ruler').addEventListener('mousemove', @eMouseMove)

  eDblclick: (e)=>
    target = if /guide/.test(e.target.className) then e.target else e.target.parentNode
    @removeGuide(target)

  eMouseUp: (e)=>
    if @press and @current != null
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

  #######################
  ##  SETTERS
  #######################
  setSelector: (selector)->
    @selector = selector

    rect = document.querySelector(@selector).getBoundingClientRect()

    ruler           = document.createElement('div')
    ruler.id        = 'ruler'
    ruler.style.position = 'fixed'
    ruler.style.top      = rect.top + 'px'
    ruler.style.left     = rect.left + 'px'

    # HTML
    html = """
      <span></span>
      <ul class="rule horizontal"></ul>
      <ul class="rule vertical"></ul>
      <div class="infos"></div>
    """

    # Options
    html += """
    <div class="panel">
      <h1>Ruler</h1>

      <form action="" class="options">
        <h2>Options</h2>
        <div class="block">
          <label for="precision">Precision</label>
          <input type="text" name="precision" id="precision" value="5">
        </div>
        <div class="block">
          <label for="save_guides">Save guides</label>
          <input type="checkbox" name="save_guides" id="save_guides" style="display:none;">
          <div id="save_guides" class="toggle off">
            <div class="cursor"></div>
            <div class="actions">
              <span class="off">OFF</span>
              <span class="on">ON</span>
              <div class="clear"></div>
            </div>
          </div>
        </div>
        <div class="clear"></div>
        <button data-target="general">Apply</button>
        <div class="clear"></div>
      </form>

      <form action="" class="generator">
        <h2>Guide generator</h2>
        <div class="block">
          <label for="column_count">Col. count</label>
          <input type="text" name="column_count" id="column_count">
        </div>
        <div class="block">
          <label for="row_count">Row count</label>
          <input type="text" name="row_count" id="row_count">
        </div>
        <div class="block">
          <label for="column_width">Col. width</label>
          <input type="text" name="column_width" id="column_width">
        </div>
        <div class="block">
          <label for="row_height">Row height</label>
          <input type="text" name="row_height" id="row_height">
        </div>
        <div class="clear"></div>
        <button data-target="generator">Generate</button>
        <button data-target="clear_guides">Clear guides</button>
      </form>
    </div>
    """

    ruler.innerHTML = html

    document.querySelector('body').appendChild(ruler)

    if @selector == 'body'
      document.querySelector('body').style.position   = 'absolute'
      document.querySelector('body').style.top        = '18px'
      document.querySelector('body').style.left       = '18px'
    else
      document.querySelector(@selector).style.marginTop = '18px'
      document.querySelector(@selector).style.marginLeft = '18px'

  setPrecision: (precision)->
    @precision = precision
    @calculate()

  setEnableSaveGuides: (enable)->
    @enableSaveGuides = enable
    @save()

  #######################
  ##  GUIDES
  #######################
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
    @save()

    # Reset dblclick event
    for guide in @guides
      guide.removeEventListener('dblclick', null)
      guide.addEventListener('dblclick', @eDblclick)

    return div

  removeGuide: (guide)->
    @guides.pop(guide)
    guide.remove()
    @save()

  clearGuides: ->
    for guide in document.querySelectorAll('#ruler .guide')
      @removeGuide(guide)

  _prepareGuides: ->
    # data = '['
    guides = []

    for guide in document.querySelectorAll('#ruler .guide')
      g =
        direction: guide.className.split('guide ')[1]
        position:
          top: parseInt(guide.style.top)
          left: parseInt(guide.style.left)

      guides.push(g)
      # data += JSON.stringify(d)

    # data = data.substr(0, data.length-1)
    # data += ']'

    # object = JSON.parse(window.localStorage.getItem('ruler'))
    # object.data.guides = data
    # window.localStorage.setItem('ruler', JSON.stringify(object))

    return guides


  restoreGuides: (guides)->
    unless guides.length == 0 then return
    for guide in guides
      position = if guide.direction == 'vertical' then guide.position.left else guide.position.top
      @createGuide(guide.direction, position)

  generateGuidesWithOptions: (options)->
    winwidth  = window.innerWidth
    winheight = window.innerHeight

    generate = (direction, count, width)=>
      i = 0
      while i < count
        if width > 0
          position = i * width
        else
          position = i / count * winwidth
        @createGuide(direction, position + 16)
        i++

    generate('vertical',   options.columnCount, options.columnWidth)
    generate('horizontal', options.rowCount,    options.rowHeight)


  #######################
  ##  RULERS
  #######################
  calculate: =>
    document.querySelector('.horizontal').innerHTML = ''
    document.querySelector('.vertical').innerHTML   = ''

    console.log(@selector)
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

  #######################
  ##  SAVEDATA
  #######################
  createSaveData: ->
    saveData =
      options:
        precision: @precision
        enableSaveGuides: @enableSaveGuides
      data:
        guides: []

    window.localStorage.setItem('ruler', JSON.stringify(saveData))
    return saveData

  restore: ->
    saveData = JSON.parse(window.localStorage.getItem('ruler'))
    @setPrecision(saveData.options.precision)
    @setEnableSaveGuides(saveData.options.enableSaveGuides)
    @restoreGuides(saveData.data.guides)

  _prepareData: ->
    data = {}
    data.guides  = if @enableSaveGuides then @_prepareGuides() else []
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
        precision: @precision
        enableSaveGuides: @enableSaveGuides

    return options

  applyOptions: (optionName)->
    if optionName == 'general'
      @setPrecision(document.querySelector('#ruler .options #precision').value)
      @setEnableSaveGuides(document.querySelector('#ruler .options #save_guides').checked)

    if optionName == 'generator'
      options =
        columnCount: document.querySelector('#ruler .generator #column_count').value
        columnWidth: document.querySelector('#ruler .generator #column_width').value
        rowCount:    document.querySelector('#ruler .generator #row_count').value
        rowHeight:   document.querySelector('#ruler .generator #row_height').value

      @generateGuidesWithOptions(options)

    if optionName == 'clear_guides'
      @clearGuides()
