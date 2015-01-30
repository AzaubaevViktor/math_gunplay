# Работа с хранилищем строковых данных

storage =
  save: (key, val) ->
    localStorage.setItem key, JSON.stringify val
    key

  load: (key) ->
    JSON.parse localStorage.getItem key

  delete: (key) ->
    localStorage.removeItem(key)
    key

window.Tools.storage = storage