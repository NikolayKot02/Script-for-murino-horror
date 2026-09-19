--[[
    SWILL CORE // MEGA HUB WITH INSANE HOLY SPICE + ANTI ARTUR + GITHUB LOCALIZATION
    Full feature set + INSANE Holy Spice + Auto Artur TP + Config System + OPTIMIZED EVENT-BASED ESP + Custom ESP Colors + Fly Feature + Unload Script
    Author: denchik_klasn (Modified by NikolayKot)
    original script: loadstring(game:HttpGet("https://pastefy.app/gop6pus0/raw"))()
    Team: Swill Way
    Version: 2026 Refactor (Rayfield Gen2 Compliant - Instant Event-based ESP)
]]
--(getgenv and getgenv() or _G)._EXECUTOR_TOKEN = "SWILL_SECURE_TOKEN_998811";
-- ===== PLACE CHECK / ПРОВЕРКА ПЛЕЙСА =====
local TARGET_PLACE_ID = 82406104802807

if TARGET_PLACE_ID ~= 0 and game.PlaceId ~= TARGET_PLACE_ID then
    warn("[Swill Hub] Script execution restricted: Incorrect Place ID (" .. tostring(game.PlaceId) .. "). Target Place ID: " .. tostring(TARGET_PLACE_ID))

    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Swill Hub Error",
            Text = "Скрипт предназначен только для другого плейса!",
            Duration = 5
        })
    end)
    return
end

local configFolder = "SwillHub_Configs"
local env = getgenv and getgenv() or _G

-- ===== CHECK AUTO-EXEC ON TELEPORT STATE PRE-CHECK =====
local autoexecFile = configFolder .. "/autoexec_state.txt"
if isfile and readfile and isfile(autoexecFile) then
    local state = readfile(autoexecFile)
    if state == "true" then
        env._EXECUTOR_TOKEN = "SWILL_SECURE_TOKEN_998811"
    end
end

-- ===== CHECK LOADER AUTHORIZATION =====
local AUTH_TOKEN = "SWILL_SECURE_TOKEN_998811"

if env._EXECUTOR_TOKEN ~= AUTH_TOKEN then
    warn("[Swill Hub] Access Denied: Direct execution is prohibited! Run the official Loader instead.")
    return
end

env._EXECUTOR_TOKEN = nil

-- ===== PREVENT DUPLICATE EXECUTION =====
if _G.SwillHubLoaded then
    warn("[Swill Hub] Script is already running!")
    return
end
_G.SwillHubLoaded = true

local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- ===== GITHUB & LOCALIZATION CONFIG =====
local GITHUB_USER = "NikolayKot02"
local GITHUB_REPO = "Mur hub"
local GITHUB_BRANCH = "main"
local RAW_SCRIPT_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/scripty/murhub.lua"
local SCRIPT_PAGE_URL = "https://rscripts.net/script/murino-horror-script-KwMX?__cf_chl_tk=um2QULuk7Dl8XrXjggu09B_j2j_S_KT7Rr9MgZk7fEo-1785074912-1.0.1.1-j7N6Lw0ei._5KjdY5Y44BdyYdI1V9yAr3JyGK2onBeI"

local function fetchAvailableLanguages()
    local languages = {}
    local apiUrl = string.format("https://api.github.com/repos/%s/%s/contents/lang?ref=%s", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH)

    local success, response = pcall(function() return game:HttpGet(apiUrl) end)
    if success and response then
        local ok, data = pcall(function() return HttpService:JSONDecode(response) end)
        if ok and type(data) == "table" then
            for _, file in ipairs(data) do
                local langCode = file.name:match("([^%.]+)%.json$")
                if langCode then table.insert(languages, langCode) end
            end
        end
    end
    if #languages == 0 then table.insert(languages, "english") end
    return languages
end

local function fetchTranslationPack(langCode)
    local rawUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/lang/%s.json", GITHUB_USER, GITHUB_REPO, GITHUB_BRANCH, langCode)
    local success, response = pcall(function() return game:HttpGet(rawUrl) end)
    if success and response then
        local ok, parsed = pcall(function() return HttpService:JSONDecode(response) end)
        if ok then return parsed end
    end
    return nil
end

-- ===== DETECT SYSTEM LANGUAGE =====
local function detectSystemLanguage(availableLangs)
    local locale = "en-us"
    pcall(function()
        locale = LocalizationService.RobloxLocaleId or "en-us"
    end)

    local primaryLang = locale:sub(1, 2):lower()

    for _, lang in ipairs(availableLangs) do
        if lang:lower() == primaryLang then
            return lang
        end
    end

    return "en"
end

local availableLangs = fetchAvailableLanguages()
local CurrentLanguage = detectSystemLanguage(availableLangs)

-- ===== RAYFIELD INIT =====
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Window = Rayfield:CreateWindow({
    name = "Mur hub",
    subtitle = "by NikolayKot",
    configuration = {
        autoSave = false
    }
})

-- Create tabs
local TabHome = Window:CreateTab({ name = "Home", icon = 4483362458 })
local TabFarm = Window:CreateTab({ name = "Farm", icon = 4483362458 })
local TabEsp = Window:CreateTab({ name = "ESP", icon = 4483362458 })
local TabPlayer = Window:CreateTab({ name = "Player", icon = 4483362458 })
local TabVisual = Window:CreateTab({ name = "Visual", icon = 4483362458 })
local TabMonster = Window:CreateTab({ name = "Monster", icon = 4483362458 })
local TabSettings = Window:CreateTab({ name = "Settings", icon = 4483362458 })

local tabsMap = {
    Home = TabHome,
    Farm = TabFarm,
    ESP = TabEsp,
    Player = TabPlayer,
    Visual = TabVisual,
    Monster = TabMonster,
    Settings = TabSettings
}

local function applyTabTranslations(pack)
    if not pack then return end
    for originalName, tabObj in pairs(tabsMap) do
        if pack[originalName] and tabObj.SetTitle then
            tabObj:SetTitle(pack[originalName])
        end
    end
end

-- Register Initial Language
local initialPack = fetchTranslationPack(CurrentLanguage)
if initialPack then
    Window:RegisterTranslations({ [CurrentLanguage] = initialPack })
    Window:SetLocale(CurrentLanguage)
    applyTabTranslations(initialPack)
end

-- ===== SERVICES =====
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")

-- Переменная для Stat элемента
local coinsStat = nil

-- ===== UI ELEMENTS REFERENCES =====
local uiElements = {
    FarmToggle = nil,
    CoinsEspToggle = nil,
    AxeEspToggle = nil,
    BandageEspToggle = nil,
    FlashlightEspToggle = nil,
    PillsEspToggle = nil,
    ArturEspToggle = nil,
    AntonChigurEspToggle = nil,
    DrunEspToggle = nil,
    ShkafEspToggle = nil,
    WalkSpeedToggle = nil,
    SpeedSlider = nil,
    NoclipToggle = nil,
    FlyToggle = nil,
    FlySpeedSlider = nil,
    FullbrightToggle = nil,
    HolySpiceToggle = nil,
    IntensitySlider = nil,
    AntiArturToggle = nil,
    MonsterNotifyToggle = nil,
    NoclipKeybind = nil,
    FlyKeybind = nil,
    ArturTpKeybind = nil,
    AutoTeleportToggle = nil,
    ConfigDropdown = nil,
    LangDropdown = nil
}

-- ===== EXECUTOR ENVIRONMENT HELPERS =====
local fire_prompt = env.fireproximityprompt or fireproximityprompt
local queue_tp = env.queue_on_teleport or (env.syn and env.syn.queue_on_teleport) or (env.fluxus and env.fluxus.queue_on_teleport)
local set_clipboard = env.setclipboard or setclipboard or (env.syn and env.syn.write_clipboard)

-- ===== VARIABLES =====
local isScriptRunning = true
local farming = false
local collected = 0
local farmThread = nil

-- ESP Colors
local coinsEspColor = Color3.fromRGB(255, 215, 0)
local axeEspColor = Color3.fromRGB(0, 191, 255)
local bandageEspColor = Color3.fromRGB(0, 255, 127)
local flashlightEspColor = Color3.fromRGB(255, 255, 0)
local pillsEspColor = Color3.fromRGB(0, 255, 255)
local shkafEspColor = Color3.fromRGB(0, 255, 0)
local arturEspColor = Color3.fromRGB(255, 0, 0)
local antonChigurEspColor = Color3.fromRGB(138, 43, 226)
local drunEspColor = Color3.fromRGB(255, 140, 0)

-- ESP States & Data
local coinsEspEnabled = false
local activeCoinsEspHighlights = {}

local axeEspEnabled = false
local activeAxeEspHighlights = {}

local bandageEspEnabled = false
local activeBandageEspHighlights = {}

local flashlightEspEnabled = false
local activeFlashlightEspHighlights = {}

local pillsEspEnabled = false
local activePillsEspHighlights = {}

local arturEspEnabled = false
local activeArturEspHighlights = {}

local antonChigurEspEnabled = false
local activeAntonChigurEspHighlights = {}

local drunEspEnabled = false
local activeDrunEspHighlights = {}

local shkafEspEnabled = false
local activeShkafEspHighlights = {}

-- Monster Spawn Notifications
local monsterNotifyEnabled = false
local monsterNotifyConnection = nil
local trackedMonsters = {}

-- WalkSpeed
local walkspeed = 16
local walkspeedEnabled = false
local walkspeedConnection = nil

-- Noclip
local noclipEnabled = false

-- Fly
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil

-- Fullbright
local fullbrightEnabled = false
local defaultLighting = {
    Ambient = lighting.Ambient,
    Brightness = lighting.Brightness,
    ClockTime = lighting.ClockTime,
    FogEnd = lighting.FogEnd,
    GlobalShadows = lighting.GlobalShadows,
    OutdoorAmbient = lighting.OutdoorAmbient,
    ColorShift_Bottom = lighting.ColorShift_Bottom,
    ColorShift_Top = lighting.ColorShift_Top
}

-- Holy Spice
local holySpiceEnabled = false
local holySpiceConnection = nil
local holySpiceIntensity = 3.0

-- Anti Artur
local antiArturEnabled = false
local antiArturConnection = nil
local isTeleportingToArtur = false

-- Keybinds
local noclipKeybind = "N"
local flyKeybind = "X"
local arturTpKeybind = "F"

-- Auto Exec on Teleport
local autoExecOnTeleport = false
local teleportConnection = nil
local teleportFired = false

-- Config Variables
local selectedConfig = "---"
local currentConfigNameInput = ""

-- Create Folder for Configs
if isfolder and makefolder then
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
end

-- ===== TEXT ESP HELPER FUNCTION =====
local function createEspLabel(parent, text, color)
    if not parent then return nil end

    local billboard = parent:FindFirstChild("SwillEspLabel")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "SwillEspLabel"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = billboard

        billboard.Parent = parent
    end

    local textLabel = billboard:FindFirstChild("Text")
    if textLabel then
        textLabel.Text = text
        textLabel.TextColor3 = color
    end

    return billboard
end

-- ===== OPTIMIZED EVENT-BASED ESP CORE LOGIC =====
local espConnections = {}

local function applyEspToObject(item, espColor, labelText, highlightName, activeTable)
    if not item or not item.Parent or activeTable[item] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = highlightName
    highlight.Adornee = item
    highlight.FillColor = espColor
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = item

    activeTable[item] = highlight
    createEspLabel(item, labelText or item.Name, espColor)
end

local function removeEspFromObject(item, activeTable)
    if activeTable[item] then
        if activeTable[item].Parent then
            activeTable[item]:Destroy()
        end
        activeTable[item] = nil
    end
    if item and item.Parent then
        local label = item:FindFirstChild("SwillEspLabel")
        if label then label:Destroy() end
    end
end

local function clearEspCategory(activeTable)
    for item, highlight in pairs(activeTable) do
        if highlight and highlight.Parent then highlight:Destroy() end
        if item and item.Parent then
            local label = item:FindFirstChild("SwillEspLabel")
            if label then label:Destroy() end
        end
    end
    table.clear(activeTable)
end

local function setupGenericEventEsp(espKey, isEnabledFunc, checkMatchFunc, activeTable, getColorFunc, getLabelFunc, highlightName)
    if espConnections[espKey] then
        espConnections[espKey]:Disconnect()
        espConnections[espKey] = nil
    end

    if isEnabledFunc() then
    -- 1. Инициализация существующих предметов один раз
        for _, obj in ipairs(workspace:GetDescendants()) do
            if checkMatchFunc(obj) then
                applyEspToObject(obj, getColorFunc(), getLabelFunc(obj), highlightName, activeTable)
            end
        end

        -- 2. Мгновенная подсветка новых спавнящихся предметов (0 сек задержки)
        espConnections[espKey] = workspace.DescendantAdded:Connect(function(child)
            if isScriptRunning and isEnabledFunc() and checkMatchFunc(child) then
                applyEspToObject(child, getColorFunc(), getLabelFunc(child), highlightName, activeTable)
            end
        end)
    else
        clearEspCategory(activeTable)
    end
end

local function updateEspColorsInTable(activeTable, newColor)
    for item, highlight in pairs(activeTable) do
        if highlight and highlight.Parent then
            highlight.FillColor = newColor
        end
        if item and item.Parent then
            local billboard = item:FindFirstChild("SwillEspLabel")
            if billboard then
                local label = billboard:FindFirstChild("Text")
                if label then label.TextColor3 = newColor end
            end
        end
    end
end

-- ===== MONSTER NOTIFICATIONS LOGIC =====
local function checkAndNotifyMonster(child)
    if not monsterNotifyEnabled or not child then return end
    if trackedMonsters[child] then return end

    local name = child.Name
    if name == "AntonChigur" or name == "Anton" then
        trackedMonsters[child] = true
        Window:Notify({
            title = "⚠️ Monster Spawned!",
            content = "AntonChigur has spawned!",
            duration = 5
        })
    elseif name == "Rush" then
        trackedMonsters[child] = true
        Window:Notify({
            title = "⚠️ Monster Spawned!",
            content = "Rush has spawned!",
            duration = 5
        })
    elseif string.match(name, "^Drun%d+$") then
        trackedMonsters[child] = true
        Window:Notify({
            title = "⚠️ Monster Spawned!",
            content = name .. " has spawned!",
            duration = 5
        })
    end
end

local function startMonsterNotifications()
    if monsterNotifyEnabled then return end
    monsterNotifyEnabled = true
    trackedMonsters = {}

    for _, obj in pairs(workspace:GetDescendants()) do
        local name = obj.Name
        if name == "AntonChigur" or name == "Anton" or name == "Rush" or string.match(name, "^Drun%d+$") then
            trackedMonsters[obj] = true
        end
    end

    monsterNotifyConnection = workspace.DescendantAdded:Connect(function(child)
        if monsterNotifyEnabled and isScriptRunning then
            checkAndNotifyMonster(child)
        end
    end)
end

local function stopMonsterNotifications()
    monsterNotifyEnabled = false
    if monsterNotifyConnection then
        monsterNotifyConnection:Disconnect()
        monsterNotifyConnection = nil
    end
    trackedMonsters = {}
end

-- ===== WALKSPEED =====
local function updateWalkspeed()
    if not walkspeedEnabled then return end
    local char = plr.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkspeed
    end
end

local function startWalkspeed()
    if walkspeedConnection then
        walkspeedConnection:Disconnect()
    end
    walkspeedEnabled = true
    walkspeedConnection = runService.Heartbeat:Connect(updateWalkspeed)
end

local function stopWalkspeed()
    walkspeedEnabled = false
    if walkspeedConnection then
        walkspeedConnection:Disconnect()
        walkspeedConnection = nil
    end
    local char = plr.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

-- ===== NOCLIP =====
local function noclipLoop()
    while noclipEnabled and isScriptRunning do
        local char = plr.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        task.wait(0.1)
    end
end

local function startNoclip()
    if noclipEnabled then return end
    noclipEnabled = true
    task.spawn(noclipLoop)
end

local function stopNoclip()
    noclipEnabled = false
    local char = plr.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso") then
                part.CanCollide = true
            end
        end
    end
end

local function toggleNoclip(state)
    if state == nil then
        state = not noclipEnabled
    end

    if state then
        startNoclip()
    else
        stopNoclip()
    end

    if uiElements.NoclipToggle and uiElements.NoclipToggle.Set then
        uiElements.NoclipToggle:Set(noclipEnabled)
    end
end

-- ===== FLY LOGIC =====
local function startFly()
    if flyEnabled then return end
    flyEnabled = true

    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    local bv = Instance.new("BodyVelocity")
    bv.Name = "SwillFlyBV"
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.zero
    bv.Parent = root

    local bg = Instance.new("BodyGyro")
    bg.Name = "SwillFlyBG"
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 9e4
    bg.CFrame = root.CFrame
    bg.Parent = root

    if humanoid then humanoid.PlatformStand = true end

    flyConnection = runService.RenderStepped:Connect(function()
        if not flyEnabled or not isScriptRunning or not root or not root.Parent then
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
            if flyConnection then flyConnection:Disconnect() end
            return
        end

        local camera = workspace.CurrentCamera
        local moveDir = Vector3.zero

        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            bv.Velocity = moveDir.Unit * flySpeed
        else
            bv.Velocity = Vector3.zero
        end
        bg.CFrame = camera.CFrame
    end)
end

local function stopFly()
    flyEnabled = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    local char = plr.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            if root:FindFirstChild("SwillFlyBV") then root.SwillFlyBV:Destroy() end
            if root:FindFirstChild("SwillFlyBG") then root.SwillFlyBG:Destroy() end
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local function toggleFly(state)
    if state == nil then
        state = not flyEnabled
    end

    if state then
        startFly()
    else
        stopFly()
    end

    if uiElements.FlyToggle and uiElements.FlyToggle.Set then
        uiElements.FlyToggle:Set(flyEnabled)
    end
end

-- ===== FULLBRIGHT =====
local function applyFullbright()
    lighting.Ambient = Color3.new(1, 1, 1)
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    lighting.ColorShift_Top = Color3.new(1, 1, 1)
end

local function revertFullbright()
    lighting.Ambient = defaultLighting.Ambient
    lighting.Brightness = defaultLighting.Brightness
    lighting.ClockTime = defaultLighting.ClockTime
    lighting.FogEnd = defaultLighting.FogEnd
    lighting.GlobalShadows = defaultLighting.GlobalShadows
    lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
    lighting.ColorShift_Bottom = defaultLighting.ColorShift_Bottom
    lighting.ColorShift_Top = defaultLighting.ColorShift_Top
end

local function startFullbright()
    fullbrightEnabled = true
    applyFullbright()
end

local function stopFullbright()
    fullbrightEnabled = false
    revertFullbright()
end

-- ===== INSANE HOLY SPICE =====
local function holySpiceLoop()
    local hue = 0
    local intensity = holySpiceIntensity

    while holySpiceEnabled and isScriptRunning do
        hue = (hue + 2 * intensity) % 360
        local color1 = Color3.fromHSV(hue / 360, 1, 1)
        local color2 = Color3.fromHSV((hue + 180) / 360, 1, 1)
        local color3 = Color3.fromHSV((hue + 90) / 360, 1, 1)
        local color4 = Color3.fromHSV((hue + 270) / 360, 1, 1)

        lighting.Ambient = color1
        lighting.OutdoorAmbient = color2
        lighting.ColorShift_Bottom = color3
        lighting.ColorShift_Top = color4

        lighting.Brightness = 0.5 + (math.sin(tick() * intensity * 2) * 1.5)
        lighting.FogEnd = 100 + (math.sin(tick() * intensity) * 500)
        lighting.FogColor = color1
        lighting.ClockTime = (tick() * 0.1) % 24
        lighting.GlobalShadows = math.random(0, 1) == 1

        if math.random(1, 10) == 1 then
            lighting.Brightness = 5
            task.wait(0.05)
        end
        task.wait(0.03)
    end
end

local function startHolySpice()
    if holySpiceEnabled then return end
    if fullbrightEnabled then stopFullbright() end
    holySpiceEnabled = true
    task.spawn(holySpiceLoop)
end

local function stopHolySpice()
    holySpiceEnabled = false
    if holySpiceConnection then
        holySpiceConnection:Disconnect()
        holySpiceConnection = nil
    end
    revertFullbright()
end

-- ===== COIN FINDER & FARM =====
local function findCoins()
    local coins = {}
    for _, model in pairs(workspace:GetDescendants()) do
        if model.Name == "Coins" and model:IsA("Model") then
            local root = model:FindFirstChild("Root")
            if root then
                local prompt = root:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local pos = nil
                    local success, pivot = pcall(function() return model:GetPivot().Position end)
                    if success then pos = pivot end
                    if pos then
                        table.insert(coins, { model = model, root = root, prompt = prompt, pos = pos })
                    end
                end
            end
        end
    end
    return coins
end

local function tpTo(coin)
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    char.HumanoidRootPart.CFrame = CFrame.new(coin.pos + Vector3.new(0, 3, 2))
    return true
end

local function activate(coin)
    if not coin or not coin.prompt then return false end
    local prompt = coin.prompt
    local oldHold, oldDist, oldLOS = prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 100
    prompt.RequiresLineOfSight = false

    local success = pcall(function()
        if fire_prompt then
            fire_prompt(prompt)
        end
    end)

    prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = oldHold, oldDist, oldLOS
    return success
end

local function farmLoop()
    while farming and isScriptRunning do
        local coins = findCoins()
        if #coins > 0 then
            for _, coin in ipairs(coins) do
                if not farming or not isScriptRunning then break end
                if coin.model and coin.model.Parent then
                    if tpTo(coin) then
                        task.wait(0.3)
                        if activate(coin) then
                            collected = collected + 1
                            if coinsStat and coinsStat.Set then
                                coinsStat:Set(collected)
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            task.wait(1)
        else
            task.wait(3)
        end
    end
end

local function startFarm()
    if farming then return end
    farming = true
    farmThread = task.spawn(farmLoop)
end

local function stopFarm()
    farming = false
    if farmThread then farmThread = nil end
end

-- ===== EVENT ESP WRAPPERS =====
local function toggleCoinsEsp(v)
    coinsEspEnabled = v
    setupGenericEventEsp(
        "Coins",
        function() return coinsEspEnabled end,
        function(obj) return obj.Name == "Coins" and obj:IsA("Model") end,
        activeCoinsEspHighlights,
        function() return coinsEspColor end,
        function() return "Coin" end,
        "SwillCoinEsp"
    )
end

local function toggleAxeEsp(v)
    axeEspEnabled = v
    setupGenericEventEsp(
        "Axe",
        function() return axeEspEnabled end,
        function(obj) return obj.Name == "Axe" and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) end,
        activeAxeEspHighlights,
        function() return axeEspColor end,
        function() return "Axe" end,
        "SwillAxeEsp"
    )
end

local function toggleBandageEsp(v)
    bandageEspEnabled = v
    setupGenericEventEsp(
        "Bandage",
        function() return bandageEspEnabled end,
        function(obj) return (obj.Name == "Bandage" or obj.Name == "Medkit") and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) end,
        activeBandageEspHighlights,
        function() return bandageEspColor end,
        function() return "Bandage" end,
        "SwillBandageEsp"
    )
end

local function toggleFlashlightEsp(v)
    flashlightEspEnabled = v
    setupGenericEventEsp(
        "Flashlight",
        function() return flashlightEspEnabled end,
        function(obj) return obj.Name == "Flashlight" and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) end,
        activeFlashlightEspHighlights,
        function() return flashlightEspColor end,
        function() return "Flashlight" end,
        "SwillFlashlightEsp"
    )
end

local function togglePillsEsp(v)
    pillsEspEnabled = v
    setupGenericEventEsp(
        "Pills",
        function() return pillsEspEnabled end,
        function(obj) return (obj.Name == "Pills" or obj.Name == "Pill") and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Tool")) end,
        activePillsEspHighlights,
        function() return pillsEspColor end,
        function() return "Pills" end,
        "SwillPillsEsp"
    )
end

local function toggleShkafEsp(v)
    shkafEspEnabled = v
    setupGenericEventEsp(
        "Shkaf",
        function() return shkafEspEnabled end,
        function(obj) return obj.Name == "Shkaf" end,
        activeShkafEspHighlights,
        function() return shkafEspColor end,
        function() return "Cabinet" end,
        "SwillShkafEsp"
    )
end

local function toggleArturEsp(v)
    arturEspEnabled = v
    setupGenericEventEsp(
        "Artur",
        function() return arturEspEnabled end,
        function(obj) return obj.Name == "Artur" and (obj:IsA("Model") or obj:IsA("BasePart")) end,
        activeArturEspHighlights,
        function() return arturEspColor end,
        function() return "Artur" end,
        "SwillArturEsp"
    )
end

local function toggleAntonChigurEsp(v)
    antonChigurEspEnabled = v
    setupGenericEventEsp(
        "Anton",
        function() return antonChigurEspEnabled end,
        function(obj) return (obj.Name == "AntonChigur" or obj.Name == "Anton") and (obj:IsA("Model") or obj:IsA("BasePart")) end,
        activeAntonChigurEspHighlights,
        function() return antonChigurEspColor end,
        function() return "Anton Chigur" end,
        "SwillAntonEsp"
    )
end

local function toggleDrunEsp(v)
    drunEspEnabled = v
    setupGenericEventEsp(
        "Drun",
        function() return drunEspEnabled end,
        function(obj) return string.match(obj.Name, "^Drun%d+$") and (obj:IsA("Model") or obj:IsA("BasePart")) end,
        activeDrunEspHighlights,
        function() return drunEspColor end,
        function(obj) return obj.Name end,
        "SwillDrunEsp"
    )
end

-- ===== ANTI ARTUR =====
local function findArtur()
    local hitboxes = workspace:FindFirstChild("Hitboxes")
    if hitboxes then
        for _, child in pairs(hitboxes:GetChildren()) do
            if child.Name == "Artur" then return child end
        end
    end
    return nil
end

local function teleportToArturAndActivate(arturObj)
    if isTeleportingToArtur then return end
    isTeleportingToArtur = true
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        isTeleportingToArtur = false
        return
    end

    local arturPos = nil
    local success, pivot = pcall(function() return arturObj:GetPivot().Position end)
    if not success then
        isTeleportingToArtur = false
        return
    end
    arturPos = pivot

    local oldPos = char.HumanoidRootPart.CFrame
    char.HumanoidRootPart.CFrame = CFrame.new(arturPos + Vector3.new(0, 3, 2))
    task.wait(0.3)

    local prompt = arturObj:FindFirstChildOfClass("ProximityPrompt") or arturObj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        local oldHold, oldDist, oldLOS = prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 100
        prompt.RequiresLineOfSight = false
        pcall(function()
            if fire_prompt then
                fire_prompt(prompt)
            end
        end)
        prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = oldHold, oldDist, oldLOS
    end

    task.wait(0.5)
    char.HumanoidRootPart.CFrame = oldPos
    task.wait(1)
    isTeleportingToArtur = false
end

local function manualTeleportToArtur()
    local artur = findArtur()
    if artur then
        teleportToArturAndActivate(artur)
    else
        Window:Notify({ title = "Anti Artur", content = "Artur not found in Hitboxes!" })
    end
end

local function startAntiArtur()
    if antiArturConnection then antiArturConnection:Disconnect() end
    antiArturEnabled = true
    antiArturConnection = runService.Stepped:Connect(function()
        if not antiArturEnabled or not isScriptRunning then return end
        local artur = findArtur()
        if artur then teleportToArturAndActivate(artur) end
    end)
end

local function stopAntiArtur()
    antiArturEnabled = false
    if antiArturConnection then
        antiArturConnection:Disconnect()
        antiArturConnection = nil
    end
end

-- ===== AUTO EXECUTE ON TELEPORT =====
local function setupAutoTeleportExec()
    if teleportConnection then teleportConnection:Disconnect() end

    teleportConnection = plr.OnTeleport:Connect(function()
        if autoExecOnTeleport and isScriptRunning and not teleportFired then
            teleportFired = true
            if queue_tp then
                local codeToQueue = string.format([[
                    repeat task.wait() until game:IsLoaded()
                    local env = getgenv and getgenv() or _G
                    env._EXECUTOR_TOKEN = "%s"
                    local success, scriptContent = pcall(function()
                        return game:HttpGet("%s")
                    end)
                    if success and scriptContent then
                        local loadedFunc, err = loadstring(scriptContent)
                        if loadedFunc then
                            loadedFunc()
                        else
                            warn("Auto-exec loadstring error:", err)
                        end
                    else
                        warn("Failed to download script on teleport!")
                    end
                ]], AUTH_TOKEN, RAW_SCRIPT_URL)

                queue_tp(codeToQueue)
            end
        end
    end)
end

-- ===== DISABLE AUTO EXEC FUNCTION =====
local function disableAutoExec()
    autoExecOnTeleport = false

    if uiElements.AutoTeleportToggle and uiElements.AutoTeleportToggle.Set then
        uiElements.AutoTeleportToggle:Set(false)
    end

    if writefile then
        writefile(configFolder .. "/autoexec_state.txt", "false")
    end
end

-- ===== UNLOAD / DISABLE SCRIPT =====
local function unloadScript()
    isScriptRunning = false
    _G.SwillHubLoaded = nil

    disableAutoExec()

    stopFarm()

    toggleCoinsEsp(false)
    toggleAxeEsp(false)
    toggleBandageEsp(false)
    toggleFlashlightEsp(false)
    togglePillsEsp(false)
    toggleShkafEsp(false)
    toggleArturEsp(false)
    toggleAntonChigurEsp(false)
    toggleDrunEsp(false)

    for _, conn in pairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    table.clear(espConnections)

    stopMonsterNotifications()
    stopWalkspeed()
    stopNoclip()
    stopFly()
    stopFullbright()
    stopHolySpice()
    stopAntiArtur()

    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end

    revertFullbright()
    Window:Unload()
    print("SWILL MEGA HUB - Script successfully disabled and unloaded.")
end

-- ===== INTERFACE - HOME TAB =====
local avatarUrl = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"

local AvatarContainer = Instance.new("Frame")
AvatarContainer.Name = "AvatarContainer"
AvatarContainer.Size = UDim2.new(1, 0, 0, 80)
AvatarContainer.BackgroundTransparency = 1

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Name = "UserAvatar"
AvatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
AvatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
AvatarImage.Size = UDim2.new(0, 70, 0, 70)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = avatarUrl
AvatarImage.Parent = AvatarContainer

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImage

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Color3.fromRGB(0, 170, 255)
AvatarStroke.Thickness = 2
AvatarStroke.Parent = AvatarImage

if TabHome.Container then
    AvatarContainer.Parent = TabHome.Container
elseif TabHome.TabFolder then
    AvatarContainer.Parent = TabHome.TabFolder
end

TabHome:CreateSection({ name = "Hello, " .. plr.DisplayName .. " (@" .. plr.Name .. ")" })
TabHome:CreateSection({ name = "Information: Welcome to Murino Horror Hub!" })
TabHome:CreateSection({ name = "Author: NikolayKot" })

TabHome:CreateSection({ name = "Language Settings" })

uiElements.LangDropdown = TabHome:CreateDropdown({
    name = "Select Language",
    options = availableLangs,
    currentOption = { CurrentLanguage },
    multipleOptions = false,
    callback = function(Option)
        local selectedLang = type(Option) == "table" and Option[1] or Option
        if selectedLang then
            local langData = fetchTranslationPack(selectedLang)
            if langData then
                Window:RegisterTranslations({ [selectedLang] = langData })
                Window:SetLocale(selectedLang)
                applyTabTranslations(langData)
                CurrentLanguage = selectedLang
                Window:Notify({
                    title = "Language Updated",
                    content = "Language changed to: " .. selectedLang,
                    duration = 3
                })
            end
        end
    end,
})

TabHome:CreateSection({ name = "Links" })

TabHome:CreateButton({
    name = "Original script",
    callback = function()
        if set_clipboard then
            set_clipboard(SCRIPT_PAGE_URL)
            Window:Notify({
                title = "Link Copied!",
                content = "Script page link has been copied to your clipboard.",
                duration = 4
            })
        else
            Window:Notify({
                title = "Error",
                content = "Your executor does not support clipboard copying.",
                duration = 4
            })
        end
    end,
})

-- ===== INTERFACE - FARM TAB =====
TabFarm:CreateSection({ name = "Coin Farm" })

coinsStat = TabFarm:CreateStat({
    name = "Collected Coins",
    description = "Количество собранных монет за сессию",
    value = 0,
    prefix = "",
    suffix = " шт."
})

uiElements.FarmToggle = TabFarm:CreateToggle({
    name = "ON/OFF FARM",
    currentValue = false,
    callback = function(v)
        if v then startFarm() else stopFarm() end
    end,
})

TabFarm:CreateButton({
    name = "SCAN COINS",
    callback = function() print("Found coins:", #findCoins()) end
})

TabFarm:CreateButton({
    name = "TEST: collect one",
    callback = function()
        local c = findCoins()[1]
        if c and tpTo(c) then
            task.wait(0.3)
            if activate(c) then
                collected = collected + 1
                if coinsStat and coinsStat.Set then
                    coinsStat:Set(collected)
                end
            end
        end
    end
})

TabFarm:CreateButton({
    name = "RESET COUNTER",
    callback = function()
        collected = 0
        if coinsStat and coinsStat.Set then
            coinsStat:Set(0)
        end
    end
})

-- ===== INTERFACE - ESP TAB =====
TabEsp:CreateSection({ name = "Item Visual Highlights" })

TabEsp:CreateColorPicker({
    name = "Coins ESP Color",
    color = coinsEspColor,
    callback = function(color)
        coinsEspColor = color
        updateEspColorsInTable(activeCoinsEspHighlights, color)
    end,
})

uiElements.CoinsEspToggle = TabEsp:CreateToggle({
    name = "Coins ESP",
    description = "Highlights all coins on the map through walls",
    currentValue = false,
    callback = function(v) toggleCoinsEsp(v) end,
})

TabEsp:CreateColorPicker({
    name = "Axe ESP Color",
    color = axeEspColor,
    callback = function(color)
        axeEspColor = color
        updateEspColorsInTable(activeAxeEspHighlights, color)
    end,
})

uiElements.AxeEspToggle = TabEsp:CreateToggle({
    name = "Axe ESP",
    description = "Highlights all axes on the map through walls",
    currentValue = false,
    callback = function(v) toggleAxeEsp(v) end,
})

TabEsp:CreateColorPicker({
    name = "Bandage ESP Color",
    color = bandageEspColor,
    callback = function(color)
        bandageEspColor = color
        updateEspColorsInTable(activeBandageEspHighlights, color)
    end,
})

uiElements.BandageEspToggle = TabEsp:CreateToggle({
    name = "Bandage ESP",
    description = "Highlights all bandages/medkits on the map through walls",
    currentValue = false,
    callback = function(v) toggleBandageEsp(v) end,
})

TabEsp:CreateColorPicker({
    name = "Flashlight ESP Color",
    color = flashlightEspColor,
    callback = function(color)
        flashlightEspColor = color
        updateEspColorsInTable(activeFlashlightEspHighlights, color)
    end,
})

uiElements.FlashlightEspToggle = TabEsp:CreateToggle({
    name = "Flashlight ESP",
    description = "Highlights all flashlights on the map through walls",
    currentValue = false,
    callback = function(v) toggleFlashlightEsp(v) end,
})

TabEsp:CreateColorPicker({
    name = "Pills ESP Color",
    color = pillsEspColor,
    callback = function(color)
        pillsEspColor = color
        updateEspColorsInTable(activePillsEspHighlights, color)
    end,
})

uiElements.PillsEspToggle = TabEsp:CreateToggle({
    name = "Pills ESP",
    description = "Highlights all pills on the map through walls",
    currentValue = false,
    callback = function(v) togglePillsEsp(v) end,
})

TabEsp:CreateColorPicker({
    name = "Cabinet ESP Color",
    color = shkafEspColor,
    callback = function(color)
        shkafEspColor = color
        updateEspColorsInTable(activeShkafEspHighlights, color)
    end,
})

uiElements.ShkafEspToggle = TabEsp:CreateToggle({
    name = "Cabinet ESP",
    description = "Highlights all cabinets (Shkaf) on the map through walls",
    currentValue = false,
    callback = function(v) toggleShkafEsp(v) end,
})

TabEsp:CreateSection({ name = "Monster & World Visual Highlights" })

TabEsp:CreateColorPicker({
    name = "Artur ESP Color",
    color = arturEspColor,
    callback = function(color)
        arturEspColor = color
        updateEspColorsInTable(activeArturEspHighlights, color)
    end,
})

uiElements.ArturEspToggle = TabEsp:CreateToggle({
    name = "Artur ESP",
    description = "Highlights Artur monster through walls",
    currentValue = false,
    callback = function(v) toggleArturEsp(v) end,
})

TabEsp:CreateColorPicker({
    name = "AntonChigur ESP Color",
    color = antonChigurEspColor,
    callback = function(color)
        antonChigurEspColor = color
        updateEspColorsInTable(activeAntonChigurEspHighlights, color)
    end,
})

uiElements.AntonChigurEspToggle = TabEsp:CreateToggle({
    name = "AntonChigur ESP",
    description = "Highlights Anton Chigur monster through walls",
    currentValue = false,
    callback = function(v) toggleAntonChigurEsp(v) end,
})

TabEsp:CreateColorPicker({
    name = "Drun ESP Color",
    color = drunEspColor,
    callback = function(color)
        drunEspColor = color
        updateEspColorsInTable(activeDrunEspHighlights, color)
    end,
})

uiElements.DrunEspToggle = TabEsp:CreateToggle({
    name = "Drun ESP",
    description = "Highlights Drun monsters (Drun1 - Drun6) through walls",
    currentValue = false,
    callback = function(v) toggleDrunEsp(v) end,
})

-- ===== INTERFACE - PLAYER TAB =====
TabPlayer:CreateSection({ name = "WalkSpeed" })

uiElements.WalkSpeedToggle = TabPlayer:CreateToggle({
    name = "ON/OFF WALKSPEED",
    currentValue = false,
    callback = function(v)
        if v then startWalkspeed() else stopWalkspeed() end
    end,
})

uiElements.SpeedSlider = TabPlayer:CreateSlider({
    name = "Speed",
    range = {16, 200},
    increment = 1,
    suffix = "speed",
    currentValue = 16,
    callback = function(v)
        walkspeed = v
        if walkspeedEnabled then updateWalkspeed() end
    end,
})

TabPlayer:CreateSection({ name = "Noclip" })

uiElements.NoclipToggle = TabPlayer:CreateToggle({
    name = "ON/OFF NOCLIP",
    currentValue = false,
    callback = function(v) toggleNoclip(v) end,
})

TabPlayer:CreateSection({ name = "Fly" })

uiElements.FlyToggle = TabPlayer:CreateToggle({
    name = "ON/OFF FLY",
    currentValue = false,
    callback = function(v) toggleFly(v) end,
})

uiElements.FlySpeedSlider = TabPlayer:CreateSlider({
    name = "Fly Speed",
    range = {10, 300},
    increment = 5,
    suffix = "speed",
    currentValue = 50,
    callback = function(v)
        flySpeed = v
    end,
})

-- ===== INTERFACE - VISUAL TAB =====
TabVisual:CreateSection({ name = "Lighting" })

uiElements.FullbrightToggle = TabVisual:CreateToggle({
    name = "FULLBRIGHT",
    currentValue = false,
    callback = function(v)
        if v then
            if holySpiceEnabled then stopHolySpice() end
            startFullbright()
        else
            stopFullbright()
        end
    end,
})

uiElements.HolySpiceToggle = TabVisual:CreateToggle({
    name = "HOLY SPICE (INSANE)",
    currentValue = false,
    callback = function(v)
        if v then
            if fullbrightEnabled then stopFullbright() end
            startHolySpice()
        else
            stopHolySpice()
        end
    end,
})

uiElements.IntensitySlider = TabVisual:CreateSlider({
    name = "Intensity",
    range = {1, 5},
    increment = 0.5,
    suffix = "x",
    currentValue = 3.0,
    callback = function(v) holySpiceIntensity = v end,
})

TabVisual:CreateButton({
    name = "RESET LIGHTING",
    callback = function()
        stopHolySpice()
        stopFullbright()
    end
})

-- ===== INTERFACE - MONSTER TAB =====
TabMonster:CreateSection({ name = "Anti Artur Controls" })

uiElements.AntiArturToggle = TabMonster:CreateToggle({
    name = "ANTI ARTUR",
    description = "Auto teleport to Artur and press E when appears in Hitboxes",
    currentValue = false,
    callback = function(v)
        if v then startAntiArtur() else stopAntiArtur() end
    end,
})

TabMonster:CreateButton({ name = "TEST: Teleport to Artur", callback = manualTeleportToArtur })

TabMonster:CreateSection({ name = "Monster Detector" })

uiElements.MonsterNotifyToggle = TabMonster:CreateToggle({
    name = "Monster Spawn Notifications",
    description = "Sends UI notifications when AntonChigur, Rush, or Drun spawn",
    currentValue = false,
    callback = function(v)
        if v then startMonsterNotifications() else stopMonsterNotifications() end
    end,
})

-- ===== CONFIG SYSTEM FUNCTIONS =====
local function getConfigFileList()
    local list = {}
    if isfolder and listfiles then
        if isfolder(configFolder) then
            for _, file in ipairs(listfiles(configFolder)) do
                local name = file:match("([^\\/]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end
    if #list == 0 then table.insert(list, "---") end
    return list
end

local function getCurrentConfigData()
    return {
        WalkSpeed = walkspeed,
        WalkSpeedEnabled = walkspeedEnabled,
        NoclipEnabled = noclipEnabled,
        FlyEnabled = flyEnabled,
        FlySpeed = flySpeed,
        NoclipKeybind = noclipKeybind,
        FlyKeybind = flyKeybind,
        ArturTpKeybind = arturTpKeybind,
        FullbrightEnabled = fullbrightEnabled,
        HolySpiceEnabled = holySpiceEnabled,
        HolySpiceIntensity = holySpiceIntensity,
        AntiArturEnabled = antiArturEnabled,
        MonsterNotifyEnabled = monsterNotifyEnabled,
        FarmEnabled = farming,
        CoinsEspEnabled = coinsEspEnabled,
        AxeEspEnabled = axeEspEnabled,
        BandageEspEnabled = bandageEspEnabled,
        FlashlightEspEnabled = flashlightEspEnabled,
        PillsEspEnabled = pillsEspEnabled,
        ArturEspEnabled = arturEspEnabled,
        AntonChigurEspEnabled = antonChigurEspEnabled,
        DrunEspEnabled = drunEspEnabled,
        ShkafEspEnabled = shkafEspEnabled,
        AutoExecOnTeleport = autoExecOnTeleport,
        Language = CurrentLanguage
    }
end

local function applyConfigData(data)
    if not data then return end

    if data.WalkSpeed ~= nil and uiElements.SpeedSlider then
        uiElements.SpeedSlider:Set(data.WalkSpeed)
    end

    if data.WalkSpeedEnabled ~= nil and uiElements.WalkSpeedToggle then
        uiElements.WalkSpeedToggle:Set(data.WalkSpeedEnabled)
    end

    if data.NoclipEnabled ~= nil and uiElements.NoclipToggle then
        uiElements.NoclipToggle:Set(data.NoclipEnabled)
    end

    if data.FlyEnabled ~= nil and uiElements.FlyToggle then
        uiElements.FlyToggle:Set(data.FlyEnabled)
    end

    if data.FlySpeed ~= nil and uiElements.FlySpeedSlider then
        uiElements.FlySpeedSlider:Set(data.FlySpeed)
    end

    if data.CoinsEspEnabled ~= nil and uiElements.CoinsEspToggle then
        uiElements.CoinsEspToggle:Set(data.CoinsEspEnabled)
    end

    if data.AxeEspEnabled ~= nil and uiElements.AxeEspToggle then
        uiElements.AxeEspToggle:Set(data.AxeEspEnabled)
    end

    if data.BandageEspEnabled ~= nil and uiElements.BandageEspToggle then
        uiElements.BandageEspToggle:Set(data.BandageEspEnabled)
    end

    if data.FlashlightEspEnabled ~= nil and uiElements.FlashlightEspToggle then
        uiElements.FlashlightEspToggle:Set(data.FlashlightEspEnabled)
    end

    if data.PillsEspEnabled ~= nil and uiElements.PillsEspToggle then
        uiElements.PillsEspToggle:Set(data.PillsEspEnabled)
    end

    if data.ArturEspEnabled ~= nil and uiElements.ArturEspToggle then
        uiElements.ArturEspToggle:Set(data.ArturEspEnabled)
    end

    if data.AntonChigurEspEnabled ~= nil and uiElements.AntonChigurEspToggle then
        uiElements.AntonChigurEspToggle:Set(data.AntonChigurEspEnabled)
    end

    if data.DrunEspEnabled ~= nil and uiElements.DrunEspToggle then
        uiElements.DrunEspToggle:Set(data.DrunEspEnabled)
    end

    if data.ShkafEspEnabled ~= nil and uiElements.ShkafEspToggle then
        uiElements.ShkafEspToggle:Set(data.ShkafEspEnabled)
    end

    if data.MonsterNotifyEnabled ~= nil and uiElements.MonsterNotifyToggle then
        uiElements.MonsterNotifyToggle:Set(data.MonsterNotifyEnabled)
    end

    if data.NoclipKeybind ~= nil and uiElements.NoclipKeybind then
        noclipKeybind = data.NoclipKeybind
        uiElements.NoclipKeybind:Set(data.NoclipKeybind)
    end

    if data.FlyKeybind ~= nil and uiElements.FlyKeybind then
        flyKeybind = data.FlyKeybind
        uiElements.FlyKeybind:Set(data.FlyKeybind)
    end

    if data.ArturTpKeybind ~= nil and uiElements.ArturTpKeybind then
        arturTpKeybind = data.ArturTpKeybind
        uiElements.ArturTpKeybind:Set(data.ArturTpKeybind)
    end

    if data.HolySpiceIntensity ~= nil and uiElements.IntensitySlider then
        uiElements.IntensitySlider:Set(data.HolySpiceIntensity)
    end

    if data.HolySpiceEnabled ~= nil and uiElements.HolySpiceToggle then
        uiElements.HolySpiceToggle:Set(data.HolySpiceEnabled)
    end

    if data.FullbrightEnabled ~= nil and uiElements.FullbrightToggle then
        uiElements.FullbrightToggle:Set(data.FullbrightEnabled)
    end

    if data.AntiArturEnabled ~= nil and uiElements.AntiArturToggle then
        uiElements.AntiArturToggle:Set(data.AntiArturEnabled)
    end

    if data.FarmEnabled ~= nil and uiElements.FarmToggle then
        uiElements.FarmToggle:Set(data.FarmEnabled)
    end

    if data.AutoExecOnTeleport ~= nil and uiElements.AutoTeleportToggle then
        uiElements.AutoTeleportToggle:Set(data.AutoExecOnTeleport)
    end

    task.defer(function()
        if data.FullbrightEnabled then
            fullbrightEnabled = true
            applyFullbright()
        elseif data.HolySpiceEnabled then
            startHolySpice()
        end
    end)
end

local function saveConfigToFile(cfgName)
    if cfgName == "" or cfgName == "---" then
        Window:Notify({ title = "Config Error", content = "Please enter a valid config name!" })
        return
    end

    if writefile then
        local filepath = configFolder .. "/" .. cfgName .. ".json"
        local jsonData = HttpService:JSONEncode(getCurrentConfigData())
        writefile(filepath, jsonData)
        Window:Notify({ title = "Config Saved", content = "Successfully saved config: " .. cfgName })
    end
end

local function loadConfigFromFile(cfgName)
    if cfgName == "---" or cfgName == "" then return end
    local filepath = configFolder .. "/" .. cfgName .. ".json"

    if isfile and readfile and isfile(filepath) then
        local content = readfile(filepath)
        local success, data = pcall(function() return HttpService:JSONDecode(content) end)
        if success and data then
            applyConfigData(data)
            Window:Notify({ title = "Config Loaded", content = "Loaded config: " .. cfgName })
        end
    end
end

local function deleteConfigFile(cfgName)
    if cfgName == "---" or cfgName == "" then return end
    local filepath = configFolder .. "/" .. cfgName .. ".json"
    if isfile and delfile and isfile(filepath) then
        delfile(filepath)
        Window:Notify({ title = "Config Deleted", content = "Deleted config: " .. cfgName })
    end
end

-- ===== INTERFACE - SETTINGS TAB =====
TabSettings:CreateSection({ name = "Keybinds & Automation" })

uiElements.NoclipKeybind = TabSettings:CreateKeybind({
    name = "Noclip Toggle Key",
    default = Enum.KeyCode.N,
    holdToInteract = false,
    callOnKeycode = true,
    callback = function(key)
        if typeof(key) == "EnumItem" then
            noclipKeybind = key.Name
        else
            noclipKeybind = tostring(key):gsub("Enum.KeyCode.", "")
        end

        if isScriptRunning then
            toggleNoclip()
        end
    end,
})

uiElements.FlyKeybind = TabSettings:CreateKeybind({
    name = "Fly Toggle Key",
    default = Enum.KeyCode.X,
    holdToInteract = false,
    callOnKeycode = true,
    callback = function(key)
        if typeof(key) == "EnumItem" then
            flyKeybind = key.Name
        else
            flyKeybind = tostring(key):gsub("Enum.KeyCode.", "")
        end

        if isScriptRunning then
            toggleFly()
        end
    end,
})

uiElements.ArturTpKeybind = TabSettings:CreateKeybind({
    name = "Artur Teleport Key",
    default = Enum.KeyCode.F,
    holdToInteract = false,
    callOnKeycode = true,
    callback = function(key)
        if typeof(key) == "EnumItem" then
            arturTpKeybind = key.Name
        else
            arturTpKeybind = tostring(key):gsub("Enum.KeyCode.", "")
        end

        if isScriptRunning then
            manualTeleportToArtur()
        end
    end,
})

uiElements.AutoTeleportToggle = TabSettings:CreateToggle({
    name = "Auto-exec on Teleport",
    description = "Re-executes the script when teleported between games/places",
    currentValue = false,
    callback = function(v)
        autoExecOnTeleport = v
        if writefile then
            writefile(configFolder .. "/autoexec_state.txt", tostring(v))
        end
    end,
})

TabSettings:CreateSection({ name = "Config Management" })

TabSettings:CreateInput({
    name = "Config Name Input",
    placeholderText = "Enter config name...",
    removeTextOnFocusLost = false,
    callback = function(Text)
        currentConfigNameInput = Text
    end,
})

TabSettings:CreateButton({
    name = "Create config",
    callback = function()
        saveConfigToFile(currentConfigNameInput)
        if uiElements.ConfigDropdown and uiElements.ConfigDropdown.Refresh then
            uiElements.ConfigDropdown:Refresh(getConfigFileList())
        end
    end,
})

uiElements.ConfigDropdown = TabSettings:CreateDropdown({
    name = "Select Config",
    options = getConfigFileList(),
    currentOption = {"---"},
    multipleOptions = false,
    callback = function(Option)
        if type(Option) == "table" then
            selectedConfig = Option[1] or "---"
        else
            selectedConfig = Option
        end
    end,
})

TabSettings:CreateButton({
    name = "Load config",
    callback = function()
        loadConfigFromFile(selectedConfig)
    end,
})

TabSettings:CreateButton({
    name = "Overwrite config",
    callback = function()
        saveConfigToFile(selectedConfig)
    end,
})

TabSettings:CreateButton({
    name = "Delete config",
    callback = function()
        deleteConfigFile(selectedConfig)
        if uiElements.ConfigDropdown and uiElements.ConfigDropdown.Refresh then
            uiElements.ConfigDropdown:Refresh(getConfigFileList())
        end
    end,
})

TabSettings:CreateButton({
    name = "Refresh list",
    callback = function()
        if uiElements.ConfigDropdown and uiElements.ConfigDropdown.Refresh then
            uiElements.ConfigDropdown:Refresh(getConfigFileList())
        end
    end,
})

TabSettings:CreateButton({
    name = "Set as autoload",
    callback = function()
        if selectedConfig ~= "---" and selectedConfig ~= "" then
            if writefile then
                writefile(configFolder .. "/autoload.txt", selectedConfig)
                Window:Notify({ title = "Autoload Set", content = "Autoload set to: " .. selectedConfig })
            end
        end
    end,
})

TabSettings:CreateButton({
    name = "Reset autoload",
    callback = function()
        if isfile and delfile and isfile(configFolder .. "/autoload.txt") then
            delfile(configFolder .. "/autoload.txt")
        end
        Window:Notify({ title = "Autoload Reset", content = "Cleared autoload config" })
    end,
})

TabSettings:CreateSection({ name = "Unload Script" })

TabSettings:CreateButton({
    name = "Destroy Script / Unload",
    callback = function()
        unloadScript()
    end,
})

-- ===== INITIALIZE TELEPORT HANDLER =====
setupAutoTeleportExec()

-- ===== CHECK AUTOLOAD & SAVED STATES ON START =====
task.spawn(function()
    task.wait(0.5)

    local stateFile = configFolder .. "/autoexec_state.txt"
    if isfile and readfile and isfile(stateFile) then
        local savedState = readfile(stateFile)
        if savedState == "true" and uiElements.AutoTeleportToggle then
            uiElements.AutoTeleportToggle:Set(true)
        end
    end

    task.wait(0.5)
    local autoFile = configFolder .. "/autoload.txt"
    if isfile and readfile and isfile(autoFile) then
        local autoName = readfile(autoFile)
        if autoName and autoName ~= "" then
            loadConfigFromFile(autoName)
        end
    end
end)

-- ===== WELCOME =====
task.wait(1)
print("=================================")
print("Mur hub")
print("Author: NikolayKot")
print("Original script:", SCRIPT_PAGE_URL)
print("=================================")
