# Игрок
getValScope = Tools.getValScope

levels =
  square: [0.6, 1]
  hospital: [0.3, 0.6]
  resuscitation: [0, 0.3]
  morgue: [-10000, 0]

penalties_list = [
  {
    "treat": 0
    "attack": 0
  },
  {
    "treat": 0.01
    "attack": 3
  },
  {
    "treat": 0.03
    "attack": 6
  },
  {
    "treat": 0.05
    "attack": 9
  },
  {
    "treat": 0.1
    "attack": 12
  }
]

class Player
  constructor: (@id, @name, @settings) ->
    @setHealth 1
    @solved = @unsolved = @treatment = @penalties = 0

  setHealth: (health) ->
    @health = getValScope health, [0, 1]

  getHealth: () ->
    @health

  incTreatment: () ->
    if ((@settings.nullTreatIfTreatResuscitation()) and (@getLevel() == "resuscitation"))
      @treatment = 0
    else
      @treatment += 1

  getLevel: () ->
    for level, scope of levels
      return level if scope[0] < @getHealth() <= scope[1]
    undefined

  _rawAttack: () ->
    # Функция подсчёта урона
    penalty = penalties_list[@penalties].attack
    10 + @solved - @unsolved - penalty - 3 * @treatment

  _rawTreat: (solved) ->
    # Функция подсчёта жизней
    5 * solved + @solved - @unsolved - 3 * @treatment - 5

  getAttackWithoutTreat: () ->
    #TODO: разобраться зачем мне эта функция
    (getValScope @_rawAttack() + 3 * @treatment, [0, @settings.maxAttack()]) / 100

  getAttack: () ->
    (getValScope @_rawAttack(), [0, @settings.maxAttack()]) / 100

  getAttackTo: (player) ->
    switch
      when 0 == @getHealth() then 0
      when @getLevel() != player.getLevel() then 0
      when (@id == player.id) and (@getLevel() == "resuscitation") and not @settings.selfDestroyResuscitation() then 0
      when (@id == player.id) and not @settings.selfDestroyAttack() then 0
      else @getAttack()

  getTreat: (solved) ->
    h = @_rawTreat solved
    h += ("hospital" == @getLevel()) * (@settings.hospitalPlus10()) * 10
    h = getValScope h, [(if @settings.selfDestroyTreat() then -Infinity else 0),
                        1 - @getHealth()]

  treat: (solved) ->
    inc = @getTreat solved
    @setHealth @getHealth() + inc
    @incTreatment()

  hit: (player) ->
    dmg = @getAttackTo player
    player.setHealth player.getHealth() - dmg
    @solved += 1

  miss: () ->
    @unsolved += 1

  penalty: () ->
    @penalty = getValScope @penalties += 1, [0, penalties_list.lenght() - 1]

  toString: () ->
    "Player##{@id}♥#{@getHealth()}/#{@solved}:#{@unsolved}"


window.Model.Player = Player