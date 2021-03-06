#### *module* sections/cache
#
# Кэш для загруженных секций, сохраняет в localStorage, используя
# в качестве ключа url и поле header, в котором сейчас передаются данные
# о секциях, при этом состояние не сохраняется, если в качестве значения
# поля method указано "post"
#
define ["config", "utils/storage/storageFactory"], (config, storageFactory) ->

  storage = storageFactory.getStorage config.storage

  helpers =
    # Генерирование ключа не основе url и header
    stateId: (url, header) ->
      return "#{url}|header:#{header}"


  #### save(state)
  #
  # Сохранение состояния
  #
  save: (state) ->
    return false if _.isString(state.method) and state.method.toLowerCase() is "post"
    storage.save "sectionsHistory", helpers.stateId(state.url, state.header), state


  #### get(url, header)
  #
  # Получение состояния по параметрам url и header
  #
  get: (url, header) ->
    storage.get "sectionsHistory", helpers.stateId(url, header)
    
  getStorage: ->
    storage

  #### setStorage(newStorage)
  #
  # Подмена storage. Используется в тестах.
  #
  setStorage: (newStorage) ->
    storage = newStorage