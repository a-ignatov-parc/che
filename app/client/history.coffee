#### *module* history
#
# Надстройка над historyAPI, необходима для создания событий истории, это хорошо понижает связность модулей.
# Кроме событий, модуль возвращает false, если historyAPI недоступно, это используется другими модулями, которые зависят от этого,
# в дальнейшем такое поведение нужно бы реализовать с помощью requirejs loaderAPI (например так сделано с модулем dom)
#

define ['events'], (events) ->
  return false if not window.history or not window.history.pushState

  State = ->
    @index = 0
    @title = ""
    @sections = ""
    @sectionsHeader = []
    @scrollPos =
      top: 0
      left: 0
    @method = "GET"
    @url = window.location.href

  State.prototype =
    contructor: State
    rememberScroll: ->
      @scrollPos.top = window.pageYOffset or document.documentElement.scrollTop
      @scrollPos.left = window.pageXOffset or document.documentElement.scrollLeft

  ###
    Workaround with Chrome popsate on very first page load. Get idea from jquery.pjax
  ###
  initialUrl = window.location.href
  popped = 'state' of window.history
  window.history.CheState = State

  originOnpopstate = window.onpopstate
  window.onpopstate = (popStateEvent)->
    initialPop = !popped and location.href is initialUrl
    console.debug 5, window.pageYOffset
    popped = true
    return if initialPop

    console.debug 6, window.pageYOffset

    if originOnpopstate?
      originOnpopstate.apply window, arguments

    events.trigger "history:popState", popStateEvent.state if popStateEvent.state?
    console.debug 7, window.pageYOffset

  originPushState = window.history.pushState

  window.history.pushState = ->
    originPushState.apply window.history, arguments
    events.trigger "history:pushState", Array::slice.call arguments
    console.debug 3, window.pageYOffset

  originReplaceState = window.history.replaceState

  window.history.replaceState = ->
    originReplaceState.apply window.history, arguments
    events.trigger "history:replaceState", Array::slice.call Array, arguments
    console.debug 4, window.pageYOffset

  return window.history