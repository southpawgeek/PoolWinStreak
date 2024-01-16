local this = ModUtil.Mod.Register("PoolWinStreak")
this.Config = { Enabled = true }

if not this.Config.Enabled then return end

ModUtil.WrapBaseFunction("UseWaterBowl", function(baseFunc, usee, args)
    if CheckCooldown("WaterBowl", 3) then
        local numRuns = 1 + TableLength(GameState.RunHistory)
        local numKills = GameState.TotalRequiredEnemyKills
        local currentStreak = GameState.ConsecutiveClears or 0
        local currentStreakRecord = GameState.ConsecutiveClearsRecord or 0
        thread(PlayVoiceLines, HeroVoiceLines.RunAttemptsVoiceLines, true)
        local lines = {}
        table.insert(lines, GetDisplayName({ Text = "ScryingPoolMessage" }) .. numRuns)
        table.insert(lines, GetDisplayName({ Text = "ScryingPoolMessage_2" }) .. numKills)
        table.insert(lines, GetDisplayName({ Text = "RunClearScreen_ClearStreak" }) .. " " .. currentStreak)
        table.insert(lines, GetDisplayName({ Text = "RunClearScreen_ClearStreakRecord" }) .. " " .. currentStreakRecord)
        this.DisplayWaterBowl(usee, lines)
    end
end, this)

function this.DisplayWaterBowl(usee, lines)
    UseableOff({ Id = usee.ObjectId })

    local fadeInDuration = 0.5
    local fadeOutDuration = 0.5
    local holdDuration = 2

    local speechbubbleId = SpawnObstacle({
        Name = "BlankObstacle",
        Group = "Combat_UI_World_Backing",
        DestinationId =
            usee.ObjectId,
        OffsetY = -150
    })
    Shake({ Id = usee.ObjectId, Distance = 2, Speed = 200, Duration = 0.15 })
    PlaySound({ Name = "/Leftovers/World Sounds/Caravan Interior/DishesInteract", Id = usee.ObjectId })
    PlaySound({ Name = "/Leftovers/World Sounds/ClickSplash", Id = usee.ObjectId })
    CreateAnimation({ Name = "ScryingPoolInteract", DestinationId = usee.ObjectId, Group = "Overlay" })
    SetAnimation({ Name = "GhostDialogue", DestinationId = speechbubbleId, Scale = 1.0 })

    local offsetY = -35
    for k, line in ipairs(lines) do
        CreateTextBox({
            Id = speechbubbleId,
            Text = line,
            FontSize = 16,
            Width = 265,
            OffsetX = -157,
            OffsetY = offsetY,
            Justification = "Left",
            Font = "AlegreyaSansSCMedium",
            Color = White,
            OutlineColor = { 0.113, 0.113, 0.113, 1 },
            OutlineThickness = 2,
            LuaKey = "TempTextData",
            LuaValue = usee,
            LangEsScaleModifier = 0.80,
            LangDeScaleModifier = 0.80,
            LangRuScaleModifier = 0.85,
            LangFrScaleModifier = 0.85,
            LangPtBrScaleModifier = 0.85,
            LangPlScaleModifier = 0.85
        })
        offsetY = offsetY + 24
    end

    Move({ Ids = { speechbubbleId }, Angle = 90, Distance = 20, Duration = fadeInDuration, SmoothStep = true })
    wait(fadeInDuration + holdDuration)

    SetAlpha({ Ids = { speechbubbleId }, Fraction = 0.0, Duration = fadeOutDuration })
    Move({ Ids = { speechbubbleId }, Angle = 90, Distance = 20, Duration = fadeOutDuration, EaseOut = 1 })
    ModifyTextBox({ Ids = { speechbubbleId }, FadeTarget = 0, FadeDuration = fadeOutDuration })
    wait(fadeOutDuration)

    Destroy({ Ids = { speechbubble } })
    wait(0.25)
    if not usee.UseableToggleBlocked then
        UseableOn({ Id = usee.ObjectId })
    end
end
