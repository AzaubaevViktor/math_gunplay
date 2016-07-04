i = (name, color) ->
  $("<i class='material-icons' style=color:#{color}>").text(name)

asc = (id, name, color, callback) ->
  id = 1 * id
  name = name[..]

  $("<a href='#!' class='secondary-content'>").append(i name, color).on 'click', ->
    callback(id)

class SavesModal
  constructor: ->
    @modal = $ "#modalSavesBody"
    $("#saveModalBtn").on 'click', =>
      mgModelSettings.writeSave($("#save_name").val())
      @update()
    @update()

  update: ->
    saves = Stor.get 'saves'
    @modal.empty()
    @modal.append(
      for id, name of saves.ids
        @generateLine id, name
    )
    $("#save_name").val("")


  generateLine: (id, name) ->
    $("<li class='collection-item'>").append $("<div>").text(name).append [
      asc(id, 'delete_forever', 'red', (id) =>
        mgModelSettings.deleteSave id
        @update()
      ),
      asc(id, 'cloud_upload', 'green', (id) =>
        mgModelSettings.loadSave id
        @update()
        mgView.update()
        mgController.bindPlayersClick()
      )
    ]

window.mgSavesModal = new SavesModal()
