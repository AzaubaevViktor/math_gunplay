_EQ = (a, b) -> a == b
_NEQ = (a,b) -> a != b


_TEST_ONCE = (variable, values, info, func) ->
  if func(variable, values)
  then console.info("OK:#{info}")
  else console.error("FAIL: `#{variable}` and `#{values}`")

_TEST = (variables, values, func) ->
  if typeof variables == "object"
  then for v, i in variables
    _TEST_ONCE(v, values[i], i, func)
  else _TEST_ONCE(variables, values, variables, func)

TEST_EQ = (a,b) -> _TEST(a, b, _EQ)
TEST_NEQ = (a,b) -> _TEST(a, b, _NEQ)


console.group "TEST test"
TEST_EQ(1,2)
TEST_NEQ(1,2)
TEST_EQ(1,1)
TEST_NEQ([1,1,2,3],[2,3,2,3])
console.groupEnd()


settings = new Model.Settings()

model = new Model.Model(settings)
window.model = model

A = {counter: 0}
B = {counter: 0}
A.a = 12
Tools.observer.observe A, "a", (a,b,c) -> A.counter += 1
Tools.observer.observe B, "a", (a,b,c) -> B.counter += 1
A.a = 13
B.a = 44
Tools.observer.unobserve A, "a"
Tools.observer.unobserve A, "x"
f = () -> A.a = B.a = 333
setTimeout f, 100
f = () ->
  console.group "ObserveTest"
  TEST_EQ([A.counter, B.counter], [1,2])
  console.groupEnd()
setTimeout f, 200

# ===========================================

console.group "Player Test"

model.addPlayer("test1")
model.addPlayer("test2")
model.addPlayer("test3")

TEST_EQ(model.players.length, 3)

console.groupEnd()

# ============================================

model.startGame()

# ============================================

console.group "Hit & Treat"

model.players[0].hit(model.players[1])
ho = model.players[1].health
model.players[1].treat(3)
hn = model.players[1].health
TEST_NEQ(ho - hn, 0)

console.groupEnd()

# ============================================

f = ->
  console.group "Statistic Test"
  TEST_NEQ(model.statistic.stats.all_treat.value, 0)
  console.groupEnd()

setTimeout f, 100

# ============================================

console.group "Snapshot Test"



console.groupEnd()


# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================
# ============================================

