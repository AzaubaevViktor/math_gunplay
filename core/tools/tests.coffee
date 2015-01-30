
settings = new Model.Settings()

model = new Model.Model(settings)
window.model = model

A = {}
B = {}
A.a = 12
Tools.observer.observe A, "a", (a,b,c) -> console.log "Must see it once"
Tools.observer.observe B, "a", (a,b,c) -> console.log "Must see it twice"
A.a = 13
B.a = 44
Tools.observer.unobserve A, "a"
Tools.observer.unobserve A, "x"
f = () -> A.a = B.a = 333
setTimeout f, 100

console.log "==============STATISCTIC================"

model.addPlayer("test1")
model.addPlayer("test2")
model.addPlayer("test3")

model.startGame()

console.log(model.players)

model.players[0].hit(model.players[1])

console.groupEnd()
