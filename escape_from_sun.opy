#!disableOptimizations
#!extension spawnMoreDummyBots
#!extension beamEffects
#!extension beamSounds
#!suppressWarnings w_ow2_rule_condition_chase
#!obfuscate

settings {
    "main": {
        "modeName": "Escape from the Star",
        "description": "Share Code: T8AVY\n\nA killer star is consuming its fuel to expand and destroy everything around it in a horrible way, you have to do anything to save yourself or you will be swallowed by the massive star!\n\nCreated by FRNathan13#1826 - This mode was played a lot during Overwatch 1 (formerly known as \"escape from sun\") as i couldn't recover the old code, i just decided to rewrite it instead.\n\nSource code you can find on github:\nhttps://github.com/nathan130200/OW-Escape-From-Star"
    },
    "lobby": {
        "ffaSlots": 10,
        "mapRotation": "afterGame",
        "returnToLobby": "afterGame"
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps":[
                "workshopExpanse",
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableRandomHeroes": true,
            "enableKillCam": false,
            "enableKillFeed": false,
            "spawnHealthPacks": "disabled",
        }
    }
}

# ====================================================================================================================================================== #

#!define clamp(min, max, value) min if value < min else max if value > max else value
#!define randomizeTarget() target = random.choice(random.shuffle([p for p in getLivingPlayers(Team.ALL) if p != target and not p.isDummy()]))

enum Stage:
    NONE = -1,
    NEBULOSA = 0,
    SUN = 1,
    GIANT_RED = 2,
    WHITE_DWARF = 3,
    BLACK_HOLE = 4

# ====================================================================================================================================================== #

globalvar currentStage = Stage.NONE
globalvar size = 0.016
globalvar maxSize = 0.016
globalvar damage = 0.016
globalvar maxDamage = 0.016
globalvar speed = 0.016
globalvar maxSpeed = 0.016
globalvar target = hostPlayer
globalvar cooldown = 9999
globalvar rates = [0.016, 0.016, 0.016]

subroutine resetStage
subroutine setupStage
subroutine updateStage

globalvar posX = 0
globalvar posY = 0
globalvar posZ = 0
globalvar finalPos = vect(0, 0, 0)
globalvar destPos = vect(0, 0, 0)

# ====================================================================================================================================================== #

subroutine configNebulosa
subroutine configSun
subroutine configGiantRed
subroutine configWhiteDwarf
subroutine configBlackHole

# ====================================================================================================================================================== #

#!define starPhasePrimaryColor {\
    Stage.NEBULOSA: Color.LIME_GREEN,\
    Stage.SUN: Color.ORANGE,\
    Stage.GIANT_RED: Color.RED,\
    Stage.WHITE_DWARF: Color.SKY_BLUE,\
    Stage.BLACK_HOLE: Color.PURPLE,\
}[currentStage]

#!define starPhaseSecondaryColor {\
    Stage.NEBULOSA: Color.GREEN,\
    Stage.SUN: Color.YELLOW,\
    Stage.GIANT_RED: Color.ROSE,\
    Stage.WHITE_DWARF: Color.BLUE,\
    Stage.BLACK_HOLE: Color.BLACK,\
}[currentStage]

#!define getStartPos() vect(posX, posY, posZ)
#!define getDynamicStarPos() updateEveryTick(getStartPos())

globalvar _stringTable
#!define localizeString(key) _stringTable[key][getCurrentLanguage()]

enum Key:
    CURRENT_PHASE,
    CHANGE_PHASE_NOTIFCATION,
    NOT_IMPLEMENTED_NOTIFICATION,
    TOO_RISK_ACTION,
    KIND_POINTS,
    STARTING_MATCH_IN,
    TIME_SEC,
    WAITING_PLAYERS,

    NEBULA_PHASE,
    SUN_PHASE,
    GIANT_RED_PHASE,
    WHITE_DWARF_PHASE,
    BLACK_HOLE_PHASE,

    NEBULA_PHASE_DESCRIPTION,
    SUN_PHASE_DESCRIPTION,
    GIANT_RED_PHASE_DESCRIPTION,
    WHITE_DWARF_PHASE_DESCRIPTION,
    BLACK_HOLE_PHASE_DESCRIPTION,

#!define getCurrentPhaseKey() {\
    Stage.NEBULOSA: Key.NEBULA_PHASE,\
    Stage.SUN: Key.SUN_PHASE,\
    Stage.GIANT_RED: Key.GIANT_RED_PHASE,\
    Stage.WHITE_DWARF: Key.WHITE_DWARF_PHASE,\
    Stage.BLACK_HOLE: Key.BLACK_HOLE_PHASE,\
}[currentStage]

#!define getCurrentPhaseMessageKey() {\
    Stage.NEBULOSA: Key.NEBULA_PHASE_DESCRIPTION,\
    Stage.SUN: Key.SUN_PHASE_DESCRIPTION,\
    Stage.GIANT_RED: Key.GIANT_RED_PHASE_DESCRIPTION,\
    Stage.WHITE_DWARF: Key.WHITE_DWARF_PHASE_DESCRIPTION,\
    Stage.BLACK_HOLE: Key.BLACK_HOLE_PHASE_DESCRIPTION,\
}[currentStage]

playervar locale = 0

#!define getCurrentLanguage() localPlayer.locale if entityExists(localPlayer) else 0
#!define detectCurrentPlayerLanguage(player) player.locale = 1 if "{}".format(Map.PRACTICE_RANGE).strIndex("Campo de Treinamento") != -1 else 0

rule "init: translation table":
    @Event global
    _stringTable = [
        
        # Misc Texts

        [ "CURRENT PHASE", "FASE ATUAL" ],
        [ "PHASE CHANGED TO", "FASE MUDOU PARA" ],
        [ "PHASE NOT IMPLEMENTED", "FASE AINDA NÃO IMPLEMENTADA" ],
        [ "TOO RISK MOVEMENT", "JOGADA CRÍTICA REALIZADA" ],
        [ "POINTS", "PONTOS" ],
        [ "STARTING MATCH IN", "INICIANDO PARTIDA EM" ],
        [ "SECONDS...", "SEGUNDOS..." ],
        [ "WAITING PLAYERS TO START!", "AGUARDANDO JOGADORES PARA COMEÇAR!" ],


        # Phase Names

        [ "NEBULOSA", "NEBULOSA" ],
        [ "SUN", "SOL" ],
        [ "GIANT RED", "GIGANTE VERMELHA" ],
        [ "WHITE DWARF", "ANÃ BRANCA" ],
        [ "SUPER MASSIVE STAR", "ESTELA SUPER MASSIVA" ],

        # Phase Descriptions
        
        [ 
            "A CLOUD OF COSMIC GAS HAS BEEN SIGHTED THROUGH THIS HUGE UNIVERSE",
            "UMA NUVEM DE GÁS CÓSMICO FOI AVISTADO ATRAVÉS DESTE IMENSO UNIVERSO" 
        ],
        [
            "FROM A MERGER OF MATTER TO BECOME THE BRIGHTNESS OF CIDERAL SPACE THE TERRIBLE SUN RISES",
            "DE UMA FUSÃO DE MATÉRIA ATÉ SE TORNAR O BRILHO DO ESPAÇO CIDERAL SURGE O SOL ATERROSISANTE"],
        [
            "THE FUEL OF THE SUN SUFFERED A MUTATION THAT TURNED IT INTO A BIG RED STAR",
            "O COMBUSTIVEL DO SOL SOFREU UMA MUTAÇÃO QUE LHE TRANSFORMOU EM UMA GRANDE ESTRELA VERMELHA"
        ],
        [
            "AT THIS MOMENT, THE STAR LOSE STRENGTH, AND STARTS TO SPREAD COSMIC MATTER THROUGH SPACE",
            "NESTE MOMENTO A ESTRELA PERDE FORÇA, E COMEÇA ESPALHAR MATÉRIA CÓSMICA PELO ESPAÇO"
        ],
        [
            "NOW IT IS AN ENDLESS PATH. THE MOST FEARED DANGER IN SPACE... THE STAR WILL DESTROY EVERYTHING! SAVE YOURSELF WHO CAN!",
            "AGORA É UM CAMINHO SEM FIM. O PERIGO MAIS TEMIDO PELO O ESPAÇO... A ESTRELA IRÁ DESTRUIR TUDO! SALVE-SE QUEM PUDER!"
        ]
    ]

rule "player: detect language":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    detectCurrentPlayerLanguage(eventPlayer)

# ====================================================================================================================================================== #

rule "pre game: minimal wait to ensure all players are loaded":
    @Event global
    @Condition isInSetup()
    disableAnnouncer()
    disableGamemodeCompletion()
    disableScoring()
    print(localizeString(Key.WAITING_PLAYERS))

    while true:

        if getNumberOfPlayers(Team.ALL) >= 4 and (len([x for x in getAllPlayers() if x.hasSpawned()]) / getNumberOfPlayers(Team.ALL)) >= 0.5:
            bigMessage(getAllPlayers(), "{} {}{}".format(localizeString(Key.STARTING_MATCH_IN), 15, localizeString(Key.TIME_SEC)))
            setMatchTime(15)
            break

        setMatchTime(60)
        wait(3)
        
    destroyAllHudTexts()
    
    for Z in range(15, 0, -1):
        smallMessage(getAllPlayers(), "{}...".format(Z))
        wait(1.1)

    resetStage()

rule "player: update hud & stuff":
    @Event eachPlayer
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.hasSpawned()
    @Condition eventPlayer.isDummy() == false
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableRespawn()
    eventPlayer.enableDeathSpectateAllPlayers()
    eventPlayer.startForcingOutlineFor(getAllPlayers().exclude([eventPlayer]), true, Color.RED, OutlineVisibility.ALWAYS)
    eventPlayer.setDamageDealt(0)
    eventPlayer.setHealingDealt(0)
    eventPlayer.setMoveSpeed(150)
    eventPlayer.setGravity(75)
    eventPlayer.setJumpVerticalSpeed(120)
    detectCurrentPlayerLanguage(eventPlayer)
    wait(5)

    if RULE_CONDITION:
        goto RULE_START

#!define serverStat(key, fn) "{}: {}%".format(key, (fn() / 255) * 100)

def resetStage():
    @Name "before each stage: resetStage effects, icons, texts, etc."
    destroyAllEffects()
    wait()
    
    destroyAllHudTexts()
    wait()
    
    destroyAllIcons()
    wait()
    
    destroyAllInWorldTexts()
    wait()
    
    destroyAllProgressBarHuds()
    wait()
    
    destroyAllProgressBarInWorldTexts()
    wait()

    hudSubtext(hostPlayer, serverStat("SERVER LOAD", getServerLoad), HudPosition.RIGHT, -5, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(hostPlayer, serverStat("SERVER LOAD PEAK", getPeakServerLoad), HudPosition.RIGHT, -4, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(hostPlayer, serverStat("SERVER LOAD AVG", getAverageServerLoad), HudPosition.RIGHT, -3, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    
    currentStage++
    wait(1)
    setupStage()

globalvar tempWinner1
globalvar tempWinner2

globalvar g_victoryCondition = createWorkshopSetting(enum["Most Valuable Player", "Last Player Alive"], "Game Settings", "Victory Condition", 1, 0)

rule "match ending processing":
    @Event global
    @Condition isGameInProgress()
    @Condition getTotalTimeElapsed() > 5
    @Condition len(getLivingPlayers(Team.ALL)) <= 1
    tempWinner1 = getLivingPlayers(Team.ALL)

    if not tempWinner1.isDead() and g_victoryCondition == 1:
        declarePlayerVictory(tempWinner1)
        return

    tempWinner2 = sorted(getAllPlayers().exclude([tempWinner1]), lambda x: x.getScore() * -1)

    if tempWinner1.isDead():
        declarePlayerVictory(tempWinner2)
    elif tempWinner2.isDead():
        declarePlayerVictory(tempWinner1)

    if tempWinner1.getScore() < tempWinner2.getScore():
        declarePlayerVictory(tempWinner2)
    elif tempWinner1.getScore() > tempWinner2.getScore():
        declarePlayerVictory(tempWinner1)
    else:
        declareDraw()

def setupStage():
    @Name "after start each stage: invoke correct subroutine to peforme actions"
    hudHeader(getAllPlayers(), b"{}: {}".format(localizeString(Key.CURRENT_PHASE), localizeString(getCurrentPhaseKey())), HudPosition.TOP, -5, starPhasePrimaryColor, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    
    if currentStage == Stage.NEBULOSA:
        configNebulosa()
    elif currentStage == Stage.SUN:
        configSun()
    elif currentStage == Stage.GIANT_RED:
        configGiantRed()
    elif currentStage == Stage.WHITE_DWARF:
        configWhiteDwarf()
    elif currentStage == Stage.BLACK_HOLE:
        configBlackHole()
    else:
        print("{}: {}".format(localizeString(Key.NOT_IMPLEMENTED_NOTIFICATION), localizeString(getCurrentPhaseKey())))
        return
        
    wait(1.5)

    async(updateStage(), AsyncBehavior.RESTART)

rule "star: update position":
    @Event global
    @Condition isGameInProgress()
    @Condition isMatchComplete() == false
    @Condition entityExists(target)
    destPos = target.getPosition()
    finalPos = vect(posX, posY, posZ)
    chase(posX, destPos.x, rate=clamp(0.016, 300, speed), ChaseReeval.DESTINATION_AND_RATE)
    chase(posY, destPos.y, rate=clamp(0.016, 50, speed), ChaseReeval.DESTINATION_AND_RATE)
    chase(posZ, destPos.z, rate=clamp(0.016, 300, speed), ChaseReeval.DESTINATION_AND_RATE)
    wait(0.016)

    if RULE_CONDITION:
        goto RULE_START

rule "player: assist":
    @Event playerEarnedElimination
    @Condition attacker != victim
    attacker.addToScore(1)

rule "player: took damage if near star":
    @Event eachPlayer
    @Condition eventPlayer.isAlive()
    @Condition distance(eventPlayer.getPosition(), finalPos) <= size + 2
    damage(eventPlayer, null, damage)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)
    eventPlayer.setEnvironmentalKillCreditor(getAllPlayers().exclude([eventPlayer]))

    if eventPlayer.isDead():
        eventPlayer.addToScore(1)
        getLivingPlayers(Team.ALL).exclude([eventPlayer]).addToScore(2)

    wait(0.5)

    if RULE_CONDITION:
        goto RULE_START

    if eventPlayer.isAlive():
        eventPlayer.clearStatusEffect(Status.BURNING)

# ====================================================================================================================================================== #

#!define rateSpeed rates[0]
#!define rateSize rates[1]
#!define rateDamage rates[2]

def configNebulosa():
    @Name "stage params: nebulosa"
    rates = [0.25, 0.2, 0.3]

    maxSpeed = 7
    maxSize = 5.5
    maxDamage = 5

    createEffect(getAllPlayers(), Effect.CLOUD, Color.SKY_BLUE, getDynamicStarPos(), size * 10, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    createEffect(getAllPlayers(), Effect.CLOUD, Color.ROSE, getDynamicStarPos(), size * 10, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    createEffect(getAllPlayers(), Effect.CLOUD, Color.WHITE, getDynamicStarPos(), size * 10, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    createEffect(getAllPlayers(), Effect.SMOKE_SOUND, Color.WHITE, getDynamicStarPos(), size + 60, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)

def configSun():
    @Name "stage params: sun"
    rates = [0.05, 0.075, 0.2]

    maxSpeed += 1.27
    maxSize += 2.5
    maxDamage += 3

    createEffect(getAllPlayers(), Effect.SPHERE, starPhasePrimaryColor, getDynamicStarPos(), size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.GOOD_AURA, starPhaseSecondaryColor, getDynamicStarPos(), size - 0.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.GOOD_AURA_SOUND, starPhaseSecondaryColor, getDynamicStarPos(), size + 40, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

def configGiantRed():
    @Name "stage params: red giant"
    rates = [0.12, 0.12, 0.06]
    size -= 3.5
    maxSize += 4
    maxSpeed += 1.5
    maxDamage += 1.5

    createEffect(getAllPlayers(), Effect.SPHERE, starPhasePrimaryColor, getDynamicStarPos(), size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.ORANGE, getDynamicStarPos(), size - 0.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.BAD_AURA, starPhaseSecondaryColor, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.BAD_AURA_SOUND, starPhaseSecondaryColor, getDynamicStarPos(), size + 40, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


def configWhiteDwarf():
    @Name "stage params: white dwarf"
    rates = [0.15, 0.17, 0.2]
    maxSize -= 3.5
    maxSpeed -= 1.75
    maxDamage += 1.25

    createEffect(getAllPlayers(), Effect.SPHERE, Color.SKY_BLUE, getDynamicStarPos(), size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.WHITE, getDynamicStarPos(), size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

def configBlackHole():
    @Name "stage params: black hole"
    rates = [0.08, 0.06, 0.2]
    maxSize += 50
    maxSpeed += 50
    maxDamage += 50

    getLivingPlayers(Team.ALL).setMoveSpeed(175)

    disableInspector()

    createEffect(getAllPlayers(), Effect.SPHERE, Color.BLACK, getDynamicStarPos(), size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.BLACK, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.BAD_AURA, starPhasePrimaryColor, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES_SOUND, starPhaseSecondaryColor, getDynamicStarPos(), size + 60, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.ORANGE, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.ROSE, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.SKY_BLUE, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.TURQUOISE, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.BLUE, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.PURPLE, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)
    createEffect(getAllPlayers(), Effect.SPARKLES, Color.VIOLET, getDynamicStarPos(), size + 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    wait(0.25)

    enableInspector()


rule "black hole: make player smooth comes to event horizon":
    @Event eachPlayer
    @Condition currentStage == Stage.BLACK_HOLE
    @Condition distance(eventPlayer, finalPos) + 10 <= size
    eventPlayer.applyImpulse(vectorTowards(eventPlayer, finalPos), 1.25, Relativity.TO_PLAYER, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START

playervar riskPoints

rule "player risk action: increment score":
    @Event eachPlayer
    @Condition distance(eventPlayer, finalPos) <= size + 3
    wait(3, Wait.ABORT_WHEN_FALSE)
    eventPlayer.riskPoints = 1 + floor(1.5 * currentStage)
    smallMessage(eventPlayer, "{} ({} {})".format(localizeString(Key.TOO_RISK_ACTION), eventPlayer.riskPoints, localizeString(Key.KIND_POINTS)))
    eventPlayer.addToScore(eventPlayer.riskPoints)
    eventPlayer.riskPoints = 0

# ====================================================================================================================================================== #

globalvar mode

def updateStage():
    @Name "main subroutine function for generic stage updates"
    bigMessage(getAllPlayers(), localizeString(getCurrentPhaseMessageKey()))
    wait(5)

    chase(speed, maxSpeed, rate=rates[0], ChaseReeval.DESTINATION_AND_RATE)
    chase(size, maxSize, rate=rates[1], ChaseReeval.DESTINATION_AND_RATE)
    chase(damage, maxDamage, rate=rates[2], ChaseReeval.DESTINATION_AND_RATE)
    randomizeTarget()

    while true:
        wait(random.uniform(4, 8) if entityExists(target) else 2)

        if distance(finalPos, target.getPosition()) >= 5 and target.isAlive():
            if not isInLoS(finalPos, target, BarrierLos.PASS_THROUGH_BARRIERS):
                cooldown = random.randint(7, 15)
                randomizeTarget()
                chase(cooldown, 0, duration=evalOnce(cooldown), ChaseReeval.DESTINATION_AND_DURATION)
        elif target.isDead() or not entityExists(target):
            randomizeTarget()
        elif cooldown == 0:
            if mode == 0:
                randomizeTarget()
                mode = 1
            elif mode == 1:
                while true:
                    wait(0.25)

                    target = getClosestPlayer(finalPos, Team.ALL)

                    if target.isAlive():
                        break

                mode = 2

            elif mode == 2:
                while true:
                    wait(0.25)

                    target = getFarthestPlayer(finalPos, Team.ALL)

                    if target.isAlive():
                        break

                mode = 0

        if speed >= maxSpeed and size >= maxSize:
            wait(1)
            resetStage()
            break