penalties = [
  "treat": 0,
  "attack": 0
,
  "treat": 1,
  "attack": 3
,
  "treat": 3,
  "attack": 6
,
  "treat": 5,
  "attack": 9
,
  "treat": 1,
  "attack": 12
]

window.SQUARE = "square"
window.HOSPITAL = "hospital"
window.RESUSCITATION = "resuscitation"
window.MORGUE = "morgue"

levels = {
  "#{SQUARE}": [60, 100]
  "#{HOSPITAL}": [30, 60]
  "#{RESUSCITATION}": [0, 30]
  "#{MORGUE}": [-100000, 0]
}

window.Player = class Player
  constructor: (@id, @name) ->
    @health = 100
    @solved = 0
    @unsolved = 0
    @treatment = 0
    @penalties = 0

  apply: (d) ->
    @name = d.name
    @health = d.health
    @solved = d.solved
    @unsolved = d.unsolved
    @treatment = d.treatment
    @penalties = d.penalties

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
    if !mgModelSettings.selfDestroyTreat && (value < 0)
      return 0
    if !mgModelSettings.selfDestroyResuscitation && (@getLevel() == RESUSCITATION) && (value < 0)
      return 0

    if (@getLevel() == HOSPITAL)
      value += mgModelSettings.hospitalPlus

    value

  dHealth: (delta) ->
    @health = getValScope @health + delta, [0, 100]

  addPenalty: ->
    @penalties = getValScope @penalties + 1, [0, penalties.length - 1]
