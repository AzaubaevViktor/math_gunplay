

model = new Model()
window.model = model

A = {}
B = {}
A.a = 12
observer.observe A, "a", (a,b,c) -> console.log "Must see it once"
observer.observe B, "a", (a,b,c) -> console.log "Must see it twice"
A.a = 13
B.a = 44
observer.unobserve A, "a"
observer.unobserve A, "x"
f = () -> A.a = B.a = 333
setTimeout f, 100

console.log "==============STATISCTIC================"

Model.model.addPlayer("test1")
Model.model.addPlayer("test2")
Model.model.addPlayer("test3")

Model.model.startGame()

console.log(model.players)

Model.model.players[0].hit(Model.model.players[1])

console.groupEnd()
