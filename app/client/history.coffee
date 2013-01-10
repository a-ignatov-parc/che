#### *module* history
#
# Модуль для поддержки истории переходов между страниц при помощи data-reload-sections
# 

# требует модули 'events', 'widgets', 'dom'

define ['events', 'widgets', 'dom', 'utils/destroyer'], (events, widgets, dom, destroyer) ->
  ### 
  data:
    <selector>: <plainHTML>
  ###

  #### Transition(@data, previousTransition)
  #
  # Конструктор переходов, переходы образуют между собой двусторонний связанный список
  # 

  depthTreshold = 10
  firstTransition = null
  lastTransition = null

  Transition = (@data, previousTransition) ->
    @prev = previousTransition or null
    @depth = if previousTransition then previousTransition.depth + 1 else 0

    if firstTransition is null
      firstTransition = @
    else if depthTreshold < @depth - firstTransition.depth?
      next = firstTransition.next
      next.prev = null
      destroyer firstTransition
      firstTransition = next

    if currentTransition is null
      currentTransition = @
    if @data?
      @_invoker = new Invoker(@data)
      @invoke()

  Transition:: =
    #### Transition.prototype.next([data])
    #
    # Переход вперед. Если переданы параметры перехода, то создается новый объект и ссылка на него записыватся в @next
    #
    next: (data) ->
      console.log data, "NEXT"
      if data?
        @next = new Transition data, @
      else if @next?
        @next.invoke()
        currentTransition = @next
      return @next

    #### Transition.prototype.prev()
    #
    # Переход назад
    #
    prev: () ->
      if @prev?
        @undo()
        currentTransition = @prev


    #### Transition.prototype.undo()
    #
    # Отмена действий при переходе
    #
    undo: () ->
      @_invoker?.undo()

    #### Transition.prototype.invoke()
    #
    # Применение действий перехода
    #
    invoke: () ->
      @_invoker?.run()
      

  #### Invoker(@reloadSections)
  #
  # Конструктор объекта действий при переходе, содежит в себе данные для переходов в обе стороны, используется в Transitions
  # 
  Invoker = (@reloadSections) ->
    @_back = null
    @_forward = null

  Invoker:: =

    #### Invoker.prototype.run()
    #
    # Применение действий перехода, а также генерация данных для обратного перехода
    #
    run: ->
      if not @_forward and not @_back
        self = @
        @_back = {}
        @_forward = {}
        _.each @reloadSections, (selector, html) ->
          self._reloadSectionInit selector, html

      @_insertSections(@_forward, @_back)

    #### Invoker.prototype.undo()
    #
    # Отмена действий перехода
    #
    undo: ->
      return false if not @_forward and not @_back
      @_insertSections(@_back, @_forward)


    #### Invoker.prototype._reloadSectionInit(selector, html)
    #
    # Инициализация секции для вставки в DOM (создаются данные перехода для секции, а также данные для отмены этого действия)
    #

    _reloadSectionInit: (selector, html) ->
      prevElement = dom selector

      @_back[selector] =
        widgets: []
        element: prevElement
        widgetsInitData: parser.getWidgets prevElement

      nextElement = parser html

      @_forward[selector] = 
        widgets: []
        element: nextElement
        widgetsInitData: parser.getWidgets nextElement


    #### Invoker.prototype._insertSections()
    #
    # вставка секций из forward и отключение секций из back
    #

    _insertSections: (forward, back) ->
      self = @
      _.each forward, (selector, data) ->
        newWidgetsInitData = parser.getWidgets(data.element)

        self._initWidgets newWidgetsInitData, (widgetsList) ->
          forward.widgets = widgetsList
          replaceableElement = back[selector].element

          if back.widgets
            for widget in back.widgets
              widget.turnOff()

          else if back.widgetsInitData
            for data in back.widgetsInitData
              widgets.get(data.name, data.element)?.turnOff()

          replaceableElement.replaceWith data.element


    #### Invoker.prototype._initWidgets(widgetsDataList, ready)
    #
    # инициализация виджетов
    #
    _initWidgets: (widgetsDataList, ready) ->
      widgetsCount = _.keys(widgetsDataList).length
      list = []
      for data in widgetsDataList
        widgets.create data.name, data.element, (widget) ->
          list.push widget
          widget.turnOn()
          widgetsCount -= 1
          if widgetsCount is 0
            ready(list)

  #### currentTransition
  #
  # ссылка на текущий переход
  #
  currentTransition = new Transition

  events.bind 'newSectionsLoaded', (sectionsData) ->
    console.log sectionsData, "Loaded"
    currentTransition.next sectionsData

  _getCurrentTransition: ->
    currentTransition
  _getFirstTransition: ->
    firstTransition
  _transition: Transition
  _invoker: Invoker