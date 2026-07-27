--[[
    SWILL CORE // MEGA HUB WITH INSANE HOLY SPICE + ANTI ARTUR + GITHUB LOCALIZATION
    Full feature set + INSANE Holy Spice + Auto Artur TP + Config System + OPTIMIZED ESP (Coins, Axe, Bandage, Flashlight, Artur, AntonChigur, Drun) + Unload Script
    Author: denchik_klasn (Modified by NikolayKot)
    original script: loadstring(game:HttpGet("https://pastefy.app/gop6pus0/raw"))()
    Team: Swill Way
    Version: 2026 Refactor (Rayfield Gen2 Compliant)
]]

-- ===== CHECK LOADER AUTHORIZATION =====
local AUTH_TOKEN = "SWILL_SECURE_TOKEN_998811"

local env = getgenv and getgenv() or _G
if env._EXECUTOR_TOKEN ~= AUTH_TOKEN then
    warn("[Swill Hub] Access Denied: Direct execution is prohibited! Run the official Loader instead.")
    return
end

-- Clear the token immediately after verification for security
env._EXECUTOR_TOKEN = nil

-- ===== PREVENT DUPLICATE EXECUTION =====
if _G.SwillHubLoaded then
    warn("[Swill Hub] Script is already running!")
    return
end
_G.SwillHubLoaded = true

local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")

-- ===== GITHUB & LOCALIZATION CONFIG =====
local GITHUB_USER = "NikolayKot02"
local GITHUB_REPO = "Script-for-murino-horror"
local GITHUB_BRANCH = "main"
local RAW_SCRIPT_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/LOADER.lua"
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
    if #languages == 0 then table.insert(languages, "ru") end
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
    name = "SCRIPT FOR MURINO HORROR",
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
local plr = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")

-- ===== UI ELEMENTS REFERENCES =====
local uiElements = {
    FarmToggle = nil,
    CoinsEspToggle = nil,
    AxeEspToggle = nil,
    BandageEspToggle = nil,
    FlashlightEspToggle = nil,
    ArturEspToggle = nil,
    AntonChigurEspToggle = nil,
    DrunEspToggle = nil,
    WalkSpeedToggle = nil,
    SpeedSlider = nil,
    NoclipToggle = nil,
    FullbrightToggle = nil,
    HolySpiceToggle = nil,
    IntensitySlider = nil,
    AntiArturToggle = nil,
    NoclipKeybind = nil,
    ArturTpKeybind = nil,
    AutoTeleportToggle = nil,
    ConfigDropdown = nil,
    LangDropdown = nil
}

-- ===== EXECUTOR ENVIRONMENT HELPERS =====
local fire_prompt = env.fireproximityprompt or fireproximityprompt
local queue_tp = env.queue_on_teleport or (env.syn and env.syn.queue_on_teleport) or (env.fluxus and env.fluxus.queue_on_teleport)
local set_clipboard = env.setclipboard 
    or setclipboard 
    or (env.syn and env.syn.write_clipboard)

-- ===== VARIABLES =====
local isScriptRunning = true
local farming = false
local collected = 0
local farmThread = nil

-- ESP States & Data
local coinsEspEnabled = false
local coinsEspThread = nil
local activeCoinsEspHighlights = {}

local axeEspEnabled = false
local axeEspThread = nil
local activeAxeEspHighlights = {}

local bandageEspEnabled = false
local bandageEspThread = nil
local activeBandageEspHighlights = {}

local flashlightEspEnabled = false
local flashlightEspThread = nil
local activeFlashlightEspHighlights = {}

local arturEspEnabled = false
local arturEspThread = nil
local activeArturEspHighlights = {}

local antonChigurEspEnabled = false
local antonChigurEspThread = nil
local activeAntonChigurEspHighlights = {}

local drunEspEnabled = false
local drunEspThread = nil
local activeDrunEspHighlights = {}

-- WalkSpeed
local walkspeed = 16
local walkspeedEnabled = false
local walkspeedConnection = nil

-- Noclip
local noclipEnabled = false

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
local arturTpKeybind = "F"

-- Auto Exec on Teleport
local autoExecOnTeleport = false
local teleportConnection = nil
local teleportFired = false

-- Config Variables
local configFolder = "SwillHub_Configs"
local selectedConfig = "---"
local currentConfigNameInput = ""

-- Create Folder for Configs
if isfolder and makefolder then
    if not isfolder(configFolder) then
        makefolder(configFolder)
    end
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
    collected = 0
    farmThread = task.spawn(farmLoop)
end

local function stopFarm()
    farming = false
    if farmThread then farmThread = nil end
end

-- ===== COINS ESP LOGIC =====
local function clearCoinsEsp()
    for model, highlight in pairs(activeCoinsEspHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
    end
    table.clear(activeCoinsEspHighlights)
end

local function updateCoinsEsp()
    if not coinsEspEnabled or not isScriptRunning then return end
    local coins = findCoins()
    local currentModels = {}

    for _, coinData in ipairs(coins) do
        local model = coinData.model
        if model and model.Parent then
            currentModels[model] = true
            if not activeCoinsEspHighlights[model] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SwillCoinEsp"
                highlight.Adornee = model
                highlight.FillColor = Color3.fromRGB(255, 215, 0)
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = model

                activeCoinsEspHighlights[model] = highlight
            end
        end
    end

    for model, highlight in pairs(activeCoinsEspHighlights) do
        if not currentModels[model] then
            if highlight and highlight.Parent then highlight:Destroy() end
            activeCoinsEspHighlights[model] = nil
        end
    end
end

local function startCoinsEsp()
    if coinsEspEnabled then return end
    coinsEspEnabled = true
    coinsEspThread = task.spawn(function()
        while coinsEspEnabled and isScriptRunning do
            updateCoinsEsp()
            task.wait(1)
        end
    end)
end

local function stopCoinsEsp()
    coinsEspEnabled = false
    if coinsEspThread then coinsEspThread = nil end
    clearCoinsEsp()
end

-- ===== AXE ESP LOGIC =====
local function findAxes()
    local axes = {}
    for _, item in pairs(workspace:GetDescendants()) do
        if item.Name == "Axe" and (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) then
            table.insert(axes, item)
        end
    end
    return axes
end

local function clearAxeEsp()
    for item, highlight in pairs(activeAxeEspHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
    end
    table.clear(activeAxeEspHighlights)
end

local function updateAxeEsp()
    if not axeEspEnabled or not isScriptRunning then return end
    local axes = findAxes()
    local currentItems = {}

    for _, item in ipairs(axes) do
        if item and item.Parent then
            currentItems[item] = true
            if not activeAxeEspHighlights[item] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SwillAxeEsp"
                highlight.Adornee = item
                highlight.FillColor = Color3.fromRGB(0, 191, 255)
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = item

                activeAxeEspHighlights[item] = highlight
            end
        end
    end

    for item, highlight in pairs(activeAxeEspHighlights) do
        if not currentItems[item] then
            if highlight and highlight.Parent then highlight:Destroy() end
            activeAxeEspHighlights[item] = nil
        end
    end
end

local function startAxeEsp()
    if axeEspEnabled then return end
    axeEspEnabled = true
    axeEspThread = task.spawn(function()
        while axeEspEnabled and isScriptRunning do
            updateAxeEsp()
            task.wait(1)
        end
    end)
end

local function stopAxeEsp()
    axeEspEnabled = false
    if axeEspThread then axeEspThread = nil end
    clearAxeEsp()
end

-- ===== BANDAGE ESP LOGIC =====
local function findBandages()
    local bandages = {}
    for _, item in pairs(workspace:GetDescendants()) do
        if (item.Name == "Bandage" or item.Name == "Medkit") and (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) then
            table.insert(bandages, item)
        end
    end
    return bandages
end

local function clearBandageEsp()
    for item, highlight in pairs(activeBandageEspHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
    end
    table.clear(activeBandageEspHighlights)
end

local function updateBandageEsp()
    if not bandageEspEnabled or not isScriptRunning then return end
    local items = findBandages()
    local currentItems = {}

    for _, item in ipairs(items) do
        if item and item.Parent then
            currentItems[item] = true
            if not activeBandageEspHighlights[item] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SwillBandageEsp"
                highlight.Adornee = item
                highlight.FillColor = Color3.fromRGB(0, 255, 127)
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = item

                activeBandageEspHighlights[item] = highlight
            end
        end
    end

    for item, highlight in pairs(activeBandageEspHighlights) do
        if not currentItems[item] then
            if highlight and highlight.Parent then highlight:Destroy() end
            activeBandageEspHighlights[item] = nil
        end
    end
end

local function startBandageEsp()
    if bandageEspEnabled then return end
    bandageEspEnabled = true
    bandageEspThread = task.spawn(function()
        while bandageEspEnabled and isScriptRunning do
            updateBandageEsp()
            task.wait(1)
        end
    end)
end

local function stopBandageEsp()
    bandageEspEnabled = false
    if bandageEspThread then bandageEspThread = nil end
    clearBandageEsp()
end

-- ===== FLASHLIGHT ESP LOGIC =====
local function findFlashlights()
    local flashlights = {}
    for _, item in pairs(workspace:GetDescendants()) do
        if item.Name == "Flashlight" and (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) then
            table.insert(flashlights, item)
        end
    end
    return flashlights
end

local function clearFlashlightEsp()
    for item, highlight in pairs(activeFlashlightEspHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
    end
    table.clear(activeFlashlightEspHighlights)
end

local function updateFlashlightEsp()
    if not flashlightEspEnabled or not isScriptRunning then return end
    local items = findFlashlights()
    local currentItems = {}

    for _, item in ipairs(items) do
        if item and item.Parent then
            currentItems[item] = true
            if not activeFlashlightEspHighlights[item] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SwillFlashlightEsp"
                highlight.Adornee = item
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = item

                activeFlashlightEspHighlights[item] = highlight
            end
        end
    end

    for item, highlight in pairs(activeFlashlightEspHighlights) do
        if not currentItems[item] then
            if highlight and highlight.Parent then highlight:Destroy() end
            activeFlashlightEspHighlights[item] = nil
        end
    end
end

local function startFlashlightEsp()
    if flashlightEspEnabled then return end
    flashlightEspEnabled = true
    flashlightEspThread = task.spawn(function()
        while flashlightEspEnabled and isScriptRunning do
            updateFlashlightEsp()
            task.wait(1)
        end
    end)
end

local function stopFlashlightEsp()
    flashlightEspEnabled = false
    if flashlightEspThread then flashlightEspThread = nil end
    clearFlashlightEsp()
end

-- ===== ARTUR ESP LOGIC =====
local function findArturObjects()
    local arturs = {}
    local hitboxes = workspace:FindFirstChild("Hitboxes")
    if hitboxes then
        for _, child in pairs(hitboxes:GetChildren()) do
            if child.Name == "Artur" then table.insert(arturs, child) end
        end
    end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Artur" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            if not table.find(arturs, obj) then table.insert(arturs, obj) end
        end
    end
    return arturs
end

local function clearArturEsp()
    for item, highlight in pairs(activeArturEspHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
    end
    table.clear(activeArturEspHighlights)
end

local function updateArturEsp()
    if not arturEspEnabled or not isScriptRunning then return end
    local arturs = findArturObjects()
    local currentItems = {}

    for _, item in ipairs(arturs) do
        if item and item.Parent then
            currentItems[item] = true
            if not activeArturEspHighlights[item] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SwillArturEsp"
                highlight.Adornee = item
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.3
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = item

                activeArturEspHighlights[item] = highlight
            end
        end
    end

    for item, highlight in pairs(activeArturEspHighlights) do
        if not currentItems[item] then
            if highlight and highlight.Parent then highlight:Destroy() end
            activeArturEspHighlights[item] = nil
        end
    end
end

local function startArturEsp()
    if arturEspEnabled then return end
    arturEspEnabled = true
    arturEspThread = task.spawn(function()
        while arturEspEnabled and isScriptRunning do
            updateArturEsp()
            task.wait(1)
        end
    end)
end

local function stopArturEsp()
    arturEspEnabled = false
    if arturEspThread then arturEspThread = nil end
    clearArturEsp()
end

-- ===== ANTON CHIGUR ESP LOGIC =====
local function findAntonChigurObjects()
    local antonList = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name == "AntonChigur" or obj.Name == "Anton") and (obj:IsA("Model") or obj:IsA("BasePart")) then
            table.insert(antonList, obj)
        end
    end
    return antonList
end

local function clearAntonChigurEsp()
    for item, highlight in pairs(activeAntonChigurEspHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
    end
    table.clear(activeAntonChigurEspHighlights)
end

local function updateAntonChigurEsp()
    if not antonChigurEspEnabled or not isScriptRunning then return end
    local antonList = findAntonChigurObjects()
    local currentItems = {}

    for _, item in ipairs(antonList) do
        if item and item.Parent then
            currentItems[item] = true
            if not activeAntonChigurEspHighlights[item] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SwillAntonEsp"
                highlight.Adornee = item
                highlight.FillColor = Color3.fromRGB(138, 43, 226)
                highlight.FillTransparency = 0.3
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = item

                activeAntonChigurEspHighlights[item] = highlight
            end
        end
    end

    for item, highlight in pairs(activeAntonChigurEspHighlights) do
        if not currentItems[item] then
            if highlight and highlight.Parent then highlight:Destroy() end
            activeAntonChigurEspHighlights[item] = nil
        end
    end
end

local function startAntonChigurEsp()
    if antonChigurEspEnabled then return end
    antonChigurEspEnabled = true
    antonChigurEspThread = task.spawn(function()
        while antonChigurEspEnabled and isScriptRunning do
            updateAntonChigurEsp()
            task.wait(1)
        end
    end)
end

local function stopAntonChigurEsp()
    antonChigurEspEnabled = false
    if antonChigurEspThread then antonChigurEspThread = nil end
    clearAntonChigurEsp()
end

-- ===== DRUN (1-6) ESP LOGIC =====
local function findDrunObjects()
    local drunList = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if string.match(obj.Name, "^Drun%d+$") and (obj:IsA("Model") or obj:IsA("BasePart")) then
            table.insert(drunList, obj)
        end
    end
    return drunList
end

local function clearDrunEsp()
    for item, highlight in pairs(activeDrunEspHighlights) do
        if highlight and highlight.Parent then highlight:Destroy() end
    end
    table.clear(activeDrunEspHighlights)
end

local function updateDrunEsp()
    if not drunEspEnabled or not isScriptRunning then return end
    local drunList = findDrunObjects()
    local currentItems = {}

    for _, item in ipairs(drunList) do
        if item and item.Parent then
            currentItems[item] = true
            if not activeDrunEspHighlights[item] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SwillDrunEsp"
                highlight.Adornee = item
                highlight.FillColor = Color3.fromRGB(255, 140, 0)
                highlight.FillTransparency = 0.3
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = item

                activeDrunEspHighlights[item] = highlight
            end
        end
    end

    for item, highlight in pairs(activeDrunEspHighlights) do
        if not currentItems[item] then
            if highlight and highlight.Parent then highlight:Destroy() end
            activeDrunEspHighlights[item] = nil
        end
    end
end

local function startDrunEsp()
    if drunEspEnabled then return end
    drunEspEnabled = true
    drunEspThread = task.spawn(function()
        while drunEspEnabled and isScriptRunning do
            updateDrunEsp()
            task.wait(1)
        end
    end)
end

local function stopDrunEsp()
    drunEspEnabled = false
    if drunEspThread then drunEspThread = nil end
    clearDrunEsp()
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

-- ===== UNLOAD / DISABLE SCRIPT =====
local function unloadScript()
    isScriptRunning = false
    _G.SwillHubLoaded = nil
    
    stopFarm()
    stopCoinsEsp()
    stopAxeEsp()
    stopBandageEsp()
    stopFlashlightEsp()
    stopArturEsp()
    stopAntonChigurEsp()
    stopDrunEsp()
    stopWalkspeed()
    stopNoclip()
    stopFullbright()
    stopHolySpice()
    stopAntiArtur()
    if teleportConnection then teleportConnection:Disconnect() end
    
    revertFullbright()
    Window:Unload()
    print("SWILL MEGA HUB - Script successfully disabled and unloaded.")
end

-- ===== INTERFACE - HOME TAB =====
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
            activate(c) 
        end 
    end 
})

TabFarm:CreateButton({ 
    name = "RESET COUNTER", 
    callback = function() collected = 0 end 
})

-- ===== INTERFACE - ESP TAB =====
TabEsp:CreateSection({ name = "Item Visual Highlights" })

uiElements.CoinsEspToggle = TabEsp:CreateToggle({
    name = "Coins ESP",
    description = "Highlights all coins on the map through walls",
    currentValue = false,
    callback = function(v) if v then startCoinsEsp() else stopCoinsEsp() end end,
})

uiElements.AxeEspToggle = TabEsp:CreateToggle({
    name = "Axe ESP",
    description = "Highlights all axes on the map through walls",
    currentValue = false,
    callback = function(v) if v then startAxeEsp() else stopAxeEsp() end end,
})

uiElements.BandageEspToggle = TabEsp:CreateToggle({
    name = "Bandage ESP",
    description = "Highlights all bandages/medkits on the map through walls",
    currentValue = false,
    callback = function(v) if v then startBandageEsp() else stopBandageEsp() end end,
})

uiElements.FlashlightEspToggle = TabEsp:CreateToggle({
    name = "Flashlight ESP",
    description = "Highlights all flashlights on the map through walls",
    currentValue = false,
    callback = function(v) if v then startFlashlightEsp() else stopFlashlightEsp() end end,
})

TabEsp:CreateSection({ name = "Monster & World Visual Highlights" })

uiElements.ArturEspToggle = TabEsp:CreateToggle({
    name = "Artur ESP",
    description = "Highlights Artur monster through walls in Red",
    currentValue = false,
    callback = function(v) if v then startArturEsp() else stopArturEsp() end end,
})

uiElements.AntonChigurEspToggle = TabEsp:CreateToggle({
    name = "AntonChigur ESP",
    description = "Highlights Anton Chigur monster through walls in Purple",
    currentValue = false,
    callback = function(v) if v then startAntonChigurEsp() else stopAntonChigurEsp() end end,
})

uiElements.DrunEspToggle = TabEsp:CreateToggle({
    name = "Drun ESP",
    description = "Highlights Drun monsters (Drun1 - Drun6) through walls in Orange",
    currentValue = false,
    callback = function(v) if v then startDrunEsp() else stopDrunEsp() end end,
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
        NoclipKeybind = noclipKeybind,
        ArturTpKeybind = arturTpKeybind,
        FullbrightEnabled = fullbrightEnabled,
        HolySpiceEnabled = holySpiceEnabled,
        HolySpiceIntensity = holySpiceIntensity,
        AntiArturEnabled = antiArturEnabled,
        FarmEnabled = farming,
        CoinsEspEnabled = coinsEspEnabled,
        AxeEspEnabled = axeEspEnabled,
        BandageEspEnabled = bandageEspEnabled,
        FlashlightEspEnabled = flashlightEspEnabled,
        ArturEspEnabled = arturEspEnabled,
        AntonChigurEspEnabled = antonChigurEspEnabled,
        DrunEspEnabled = drunEspEnabled,
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

    if data.ArturEspEnabled ~= nil and uiElements.ArturEspToggle then
        uiElements.ArturEspToggle:Set(data.ArturEspEnabled)
    end

    if data.AntonChigurEspEnabled ~= nil and uiElements.AntonChigurEspToggle then
        uiElements.AntonChigurEspToggle:Set(data.AntonChigurEspEnabled)
    end

    if data.DrunEspEnabled ~= nil and uiElements.DrunEspToggle then
        uiElements.DrunEspToggle:Set(data.DrunEspEnabled)
    end
    
    if data.NoclipKeybind ~= nil and uiElements.NoclipKeybind then 
        uiElements.NoclipKeybind:Set(data.NoclipKeybind) 
    end
    
    if data.ArturTpKeybind ~= nil and uiElements.ArturTpKeybind then 
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
print("Script for Murino horror")
print("Author: NikolayKot")
print("Original script:", SCRIPT_PAGE_URL)
print("=================================")
