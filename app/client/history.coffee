#### *module* history
#
# Надстройка над historyAPI, необходима для создания событий истории, это хорошо понижает связность модулей.
# Кроме событий, модуль возвращает false, если historyAPI недоступно, это используется другими модулями, которые зависят от этого,
# в дальнейшем такое поведение нужно бы реализовать с помощью requirejs loaderAPI (например так сделано с модулем dom)
#

define ['events'], (events) ->
  return false if not window.history or not window.history.pushState

  ###
    Workaround with Chrome popsate on very first page load. Get idea from jquery.pjax
  ###
  initialUrl = window.location.href
  popped = 'state' of window.history

  originOnpopstate = window.onpopstate
  window.onpopstate = (popStateEvent)->
    initialPop = !popped and location.href is initialUrl
    popped = true
    return if initialPop

    console.debug 1, popStateEvent, popStateEvent.state

    if originOnpopstate?
      originOnpopstate.apply window, arguments

    if 'state' of popStateEvent
      events.trigger "history:popState", (popStateEvent.state if popStateEvent.state?)

  originPushState = window.history.pushState

  window.history.pushState = ->
    console.debug 2, arguments
    originPushState.apply window.history, arguments
    events.trigger "history:pushState", Array::slice.call arguments

  originReplaceState = window.history.replaceState

  window.history.replaceState = ->
    console.debug 3, arguments
    originReplaceState.apply window.history, arguments
    events.trigger "history:replaceState", Array::slice.call Array, arguments

  return window.history