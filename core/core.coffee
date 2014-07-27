($ document).ready ->
  console.log "I'm alive!"
  jQuery.fx.interval = 40

  #$("#settings-modal").modal()

  model = new Model()
  view = new View()
  controller = new Controller()

  model.joinView view
  view.joinModel model
  view.joinController controller
  controller.joinView view
  controller.joinModel model

  controller.bind()

  window.model = model
  window.view = view
  window.controller = controller

  ($ ".navbar-btn").tooltip()
  ($ ".with-tooltip").tooltip()

  ($ "#version").text __version__

  # Test
  view.updateUI()
  model.addPlayer("Математики")
  model.addPlayer("Лунатики")
  model.addPlayer("Пузатики")

  undefined
