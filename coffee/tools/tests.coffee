# REQUIRE

requirejs.config
    baseUrl: 'js',
    waitSeconds: 0
    paths:
        Model: 'model/model'

require ['tools/jsonify', 'model/settings', 'Model'], (JSONify, Settings, Model) ->

    # LOGIC
    _EQ = (a, b) -> a == b
    _NEQ = (a,b) -> a != b

    _TEST_ONCE = (variable, values, info, func) ->
        if func variable, values
        then console.info "OK:#{info}"
        else console.error "FAIL: `#{variable}` and `#{values}`"

    _TEST = (variables, values, func) ->
        if variables is undefined or variables is null or variables is NaN
            console.error "Bad value: #{variables}"
            return

        if typeof variables == "object"
            for v, i in variables
                _TEST_ONCE v, values[i], "#{v}, #{values[i]}", func
        else
            _TEST_ONCE variables, values, "#{variables}, #{values}", func

    TEST_EQ = (a,b) -> _TEST(a, b, _EQ)
    TEST_NEQ = (a,b) -> _TEST(a, b, _NEQ)


    console.group "TEST test"
    TEST_EQ(1,2)
    TEST_NEQ(1,2)
    TEST_EQ(1,1)
    TEST_NEQ([1,1,2,3],[2,3,2,3])
    TEST_EQ(undefined , 1)
    TEST_EQ(null , 1)
    TEST_EQ(NaN , 1)

    console.groupEnd()

    # ===========================================


    class JA extends JSONify.JSONify
        constructor: (@a) ->
            @b = {a:2, b:4, c: undefined}
            @className = "JA"
            @JSONProperties = ["b"]
            @register JA
        test: ->
            @b.a

    class JB extends JSONify.JSONify
        constructor: ->
            @x = [1,2,3]
            @y = new JA([1,2,3])
            @z = true
            @undef = undefined
            @a =
                1:'a',
                12:
                    b:
                        1:22

            @className = "JB"
            @JSONProperties = ["undef", "y", "a"]
            @register JB

    ja1 = new JA([1,2,3])
    ja1.a = [2,3,1]
    ja1.b.c = 123334
    serialized = ja1.serialize()
    ja2 = new JA([1,2,3])
    ja2.deserialize serialized
    TEST_EQ ja2.b.c, 123334
    TEST_EQ ja2.b.a, ja2.test()

    jb1 = new JB()
    jb1.y.b.c = -1234
    jb1.a[12].b.c = -4321
    serialized = jb1.serialize()
    jb2 = new JB()
    jb2.deserialize serialized
    TEST_EQ jb2.y.a, [1,2,3]
    TEST_EQ jb2.y.b.c, -1234
    TEST_EQ jb2.a[12].b.c, -4321
    TEST_EQ jb2.y.test(), jb2.y.b.a


    # ===========================================

    settings = new Settings.Settings()

    model = new Model(settings)

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
    model.players[2].miss()

    console.groupEnd()

    # ============================================

    console.group "Statistic And events Test"
    TEST_NEQ(model.statistic.stats.all_treat, 0)
    TEST_NEQ(model.statistic.stats.all_damage, 0)
    TEST_EQ(model.statistic.stats.all_tasks, 5)
    TEST_EQ(model.statistic.stats.solve_percent, 4/5)
    console.groupEnd()

    # ============================================


    console.group "Snapshot Test"

    model.players[0].hit(model.players[1])
    h1o = model.players[1].getHealth()
    [_, sid1] = model.save()
    model.players[0].hit(model.players[1])
    h1n = model.players[1].getHealth()
    [_, sid2] = model.save()

    model.load(sid1)
    TEST_EQ(model.players[1].getHealth(), h1o)
    model.load(sid2)
    TEST_EQ(model.players[1].getHealth(), h1n)

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

