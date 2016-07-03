penalties = [
    "treat": 0,
    "attack": 0
  ,
    "treat": 0.01,
    "attack": 3
  ,
    "treat": 0.03,
    "attack": 6
  ,
    "treat": 0.05,
    "attack": 9
  ,
    "treat": 0.1,
    "attack": 12
]

class ModelSettings
  constructor: ->
    @settingsVersion = 1
    @savesVersion = 1

    # Параметры игры
    @maxAttack = 15
    @selfDestroyAttack = true
    @selfDestroyTreat = true
    @selfDestroyResuscitation = false
    @hospitalPlus = 10
    @nullResus = true # обнуление количества лечений в реанимации
    @gameTime = 15


window.mgModelSettings = new ModelSettings()

SQUARE = 0
HOSPITAL = 1
RESUSCITATION = 2
MORGUE = 3
levels = {
  SQUARE: [60, 100]
  HOSPITAL: [30, 60]
  RESUSCITATION: [0, 30]
  MORGUE: [-100000, 0]
}

class Model
  constructor: ->
    @players = []
    return

  addPlayer: (name) ->
    @players.push(new Player(@players.length, name))
    return

  getPlayer: (id) ->
    @players[id]

  hit: (fromId, toId) ->
    playerFrom = @getPlayer(fromId)
    playerTo = @getPlayer(toId)

    attackValue = playerFrom.getAttackValue()
    playerFrom.solved += 1

    if (playerTo.health == 0) || (playerFrom.level != playerTo.level)
      return 0

    if fromId == toId
      if playerFrom.level == RESUSCITATION
        if mgModelSettings.selfDestroyResuscitation
          return 0
      if !mgModelSettings.selfDestroyAttack
        return 0

    return playerTo.dHealth(-attackValue)

  miss: (plId) ->
    player = @getPlayer(plId)
    player.unsolved += 1
    return 0

  treat: (plId, correct) ->
    player = @getPlayer(plId)
    value = player.getTreatValue(correct)

    player.solved += correct
    player.unsolved += 3 - correct

    if (player.getLevel() == RESUSCITATION) && mgModelSettings.nullResus
      player.treatment = 0
    else
      player.treatment += 1

    player.dHealth(value)

  penalty: (plId) ->
    player = @getPlayer(plId)
    player.addPenalty()


window.mgModel = Model()


class Player
  constructor: (@id, @name) ->
    @health = 100
    @solved = 0
    @unsolved = 0
    @treatment = 0
    @penalties = 0

  getLevel: ->
    for level, scope of levels
      if scope[0] < @health <= scope[1]
        return level

  getAttackValue: ->
    penalty = penalties[@penalties]["attack"]
    getValScope 10 + @solved - @unsolved - penalty - 3 * @treatment, [0, mgModelSettings.maxAttack]

  getTreatValue: (correct) ->
    penalty = penalties[@penalties]["treat"]
    value = 5 * correct + @solved - @unsolved - 3 * @treatment - 5 - penalty
    if mgModelSettings.selfDestroyTreat && (value < 0)
      return 0
    if mgModelSettings.selfDestroyResuscitation && (@getLevel() == RESUSCITATION) && (value < 0)
      return 0

    if (@getLevel() == HOSPITAL)
      value += mgModelSettings.hospitalPlus

    value

  dHealth: (delta) ->
    @health = getValScope @health - delta, [0, 100]

  addPenalty: ->
    @penalties = getValScope @penalties + 1, [0, penalties.length - 1]
