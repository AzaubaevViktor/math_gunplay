# Игрок
getValScope = Tools.getValScope
observer = Tools.observer

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
  constructor: (@id, @name, @_settings) ->
    @setHealth 1
    @solved = @unsolved = @treatment = @penalties = 0

  setHealth: (health) ->
    @health = getValScope health, [0, 1]

  getHealth: () ->
    @health

  incTreatment: () ->
    if ((@_settings.nullTreatIfTreatResuscitation()) and (@getLevel() == "resuscitation"))
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
    (getValScope @_rawAttack() + 3 * @treatment, [0, @_settings.maxAttack()]) / 100

  getAttack: () ->
    (getValScope @_rawAttack(), [0, @_settings.maxAttack()]) / 100

  getAttackTo: (player) ->
    switch
      when 0 == @getHealth() then 0
      when @getLevel() != player.getLevel() then 0
      when (@id == player.id) and (@getLevel() == "resuscitation") and not @_settings.selfDestroyResuscitation() then 0
      when (@id == player.id) and not @_settings.selfDestroyAttack() then 0
      else @getAttack()

  getTreat: (solved) ->
    h = @_rawTreat solved
    h += ("hospital" == @getLevel()) * (@_settings.hospitalPlus10()) * 10
    h = getValScope h, [(if @_settings.selfDestroyTreat() then -Infinity else 0),
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

  setWatcher: (property, callback) ->
    if "_all" == property
      for prop in ["solved", "unsolved", "penalties", "treatment"]
#        health убрал отсюда из-за того, что когда 1 стреляет в 2, у 1 меняется solved, у 2 меняется health
        @setWatcher prop, callback
    else
      observer.observe this, property, callback


window.Model.Player = Player