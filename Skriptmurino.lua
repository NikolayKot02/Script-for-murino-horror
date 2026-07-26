--[[
    SWILL CORE // MEGA HUB WITH INSANE HOLY SPICE + ANTI ARTUR
    Full feature set + INSANE Holy Spice + Auto Artur TP + Config System + Unload Script
    Author: denchik_klasn (Modified by NikolayKot)
    Team: Swill Way
    Version: 26.09.2025
]]

local HttpService = game:GetService("HttpService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "SCRIPT FOR MURINO HORROR",
    LoadingTitle = "Murino horror",
    LoadingSubtitle = "by NikolayKot",
    ConfigurationSaving = {Enabled = false}
})

-- Create tabs
local TabFarm = Window:CreateTab("Farm", 4483362458)
local TabPlayer = Window:CreateTab("Player", 4483362458)
local TabVisual = Window:CreateTab("Visual", 4483362458)
local TabMonster = Window:CreateTab("Monster", 4483362458)
local TabSettings = Window:CreateTab("Settings", 4483362458)

-- ===== SERVICES =====
local plr = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")

-- ===== UI ELEMENTS REFERENCES =====
local uiElements = {}

-- ===== VARIABLES =====
local isScriptRunning = true
local farming = false
local collected = 0
local farmThread = nil

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
    if walkspeedConnection then walkspeedConnection:Disconnect() end
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
        if humanoid then humanoid.WalkSpeed = 16 end
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
    if state == nil then state = not noclipEnabled end
    if state then startNoclip() else stopNoclip() end
    if uiElements.NoclipToggle then uiElements.NoclipToggle:Set(noclipEnabled) end
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
    local success = pcall(function() fireproximityprompt(prompt) end)
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
                        if activate(coin) then collected = collected + 1 end
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
    if not char or not char:FindFirstChild("HumanoidRootPart") then isTeleportingToArtur = false return end
    
    local arturPos = nil
    local success, pivot = pcall(function() return arturObj:GetPivot().Position end)
    if not success then isTeleportingToArtur = false return end
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
        pcall(function() fireproximityprompt(prompt) end)
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
        Rayfield:Notify({Title = "Anti Artur", Content = "Artur not found in Hitboxes!", Duration = 2})
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
    if antiArturConnection then antiArturConnection:Disconnect(); antiArturConnection = nil end
end

-- ===== UNLOAD / DISABLE SCRIPT =====
local function unloadScript()
    isScriptRunning = false
    
    -- Выключаем все функции
    stopFarm()
    stopWalkspeed()
    stopNoclip()
    stopFullbright()
    stopHolySpice()
    stopAntiArtur()
    
    -- Восстанавливаем свет
    revertFullbright()
    
    -- Закрываем/удаляем Rayfield GUI
    Rayfield:Destroy()
    print("SWILL MEGA HUB - Script successfully disabled and unloaded.")
end

-- ===== INTERFACE - FARM TAB =====
TabFarm:CreateLabel("COIN FARM")
uiElements.FarmToggle = TabFarm:CreateToggle({
    Name = "ON/OFF FARM",
    CurrentValue = false,
    Callback = function(v) if v then startFarm() else stopFarm() end end,
})
TabFarm:CreateButton({ Name = "SCAN COINS", Callback = function() print("Found coins:", #findCoins()) end })
TabFarm:CreateButton({ Name = "TEST: collect one", Callback = function() local c = findCoins()[1]; if c and tpTo(c) then task.wait(0.3); activate(c) end end })
TabFarm:CreateButton({ Name = "RESET COUNTER", Callback = function() collected = 0 end })
local farmStatus = TabFarm:CreateLabel("Status: Off | Collected: 0")

-- ===== INTERFACE - PLAYER TAB =====
TabPlayer:CreateLabel("WALKSPEED")
uiElements.WalkSpeedToggle = TabPlayer:CreateToggle({
    Name = "ON/OFF WALKSPEED",
    CurrentValue = false,
    Callback = function(v) if v then startWalkspeed() else stopWalkspeed() end end,
})
uiElements.SpeedSlider = TabPlayer:CreateSlider({
    Name = "Speed", Range = {16, 200}, Increment = 1, Suffix = "speed", CurrentValue = 16,
    Callback = function(v) walkspeed = v; if walkspeedEnabled then updateWalkspeed() end end,
})
TabPlayer:CreateLabel("NOCLIP")
uiElements.NoclipToggle = TabPlayer:CreateToggle({
    Name = "ON/OFF NOCLIP", CurrentValue = false,
    Callback = function(v) toggleNoclip(v) end,
})
local playerStatus = TabPlayer:CreateLabel("WalkSpeed: Off | Noclip: Off")

-- ===== INTERFACE - VISUAL TAB =====
TabVisual:CreateLabel("LIGHTING")
uiElements.FullbrightToggle = TabVisual:CreateToggle({
    Name = "FULLBRIGHT", CurrentValue = false,
    Callback = function(v) if v then if holySpiceEnabled then stopHolySpice() end; startFullbright() else stopFullbright() end end,
})
uiElements.HolySpiceToggle = TabVisual:CreateToggle({
    Name = "HOLY SPICE (INSANE)", CurrentValue = false,
    Callback = function(v) if v then if fullbrightEnabled then stopFullbright() end; startHolySpice() else stopHolySpice() end end,
})
uiElements.IntensitySlider = TabVisual:CreateSlider({
    Name = "Intensity", Range = {1, 5}, Increment = 0.5, Suffix = "x", CurrentValue = 3.0,
    Callback = function(v) holySpiceIntensity = v end,
})
TabVisual:CreateButton({ Name = "RESET LIGHTING", Callback = function() stopHolySpice(); stopFullbright() end })
local visualStatus = TabVisual:CreateLabel("Fullbright: Off | Holy Spice: Off")

-- ===== INTERFACE - MONSTER TAB =====
TabMonster:CreateLabel("ANTI ARTUR")
uiElements.AntiArturToggle = TabMonster:CreateToggle({
    Name = "ANTI ARTUR", Description = "Auto teleport to Artur and press E when appears in Hitboxes", CurrentValue = false,
    Callback = function(v) if v then startAntiArtur() else stopAntiArtur() end end,
})
TabMonster:CreateButton({ Name = "TEST: Teleport to Artur", Callback = manualTeleportToArtur })
local monsterStatus = TabMonster:CreateLabel("Anti Artur: Off")

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
        FarmEnabled = farming
    }
end

local function applyConfigData(data)
    if not data then return end
    
    if data.WalkSpeed ~= nil and uiElements.SpeedSlider then uiElements.SpeedSlider:Set(data.WalkSpeed) end
    if data.WalkSpeedEnabled ~= nil and uiElements.WalkSpeedToggle then uiElements.WalkSpeedToggle:Set(data.WalkSpeedEnabled) end
    if data.NoclipEnabled ~= nil and uiElements.NoclipToggle then uiElements.NoclipToggle:Set(data.NoclipEnabled) end
    if data.NoclipKeybind ~= nil and uiElements.NoclipKeybind then uiElements.NoclipKeybind:Set(data.NoclipKeybind) end
    if data.ArturTpKeybind ~= nil and uiElements.ArturTpKeybind then uiElements.ArturTpKeybind:Set(data.ArturTpKeybind) end
    if data.FullbrightEnabled ~= nil and uiElements.FullbrightToggle then uiElements.FullbrightToggle:Set(data.FullbrightEnabled) end
    if data.HolySpiceEnabled ~= nil and uiElements.HolySpiceToggle then uiElements.HolySpiceToggle:Set(data.HolySpiceEnabled) end
    if data.HolySpiceIntensity ~= nil and uiElements.IntensitySlider then uiElements.IntensitySlider:Set(data.HolySpiceIntensity) end
    if data.AntiArturEnabled ~= nil and uiElements.AntiArturToggle then uiElements.AntiArturToggle:Set(data.AntiArturEnabled) end
    if data.FarmEnabled ~= nil and uiElements.FarmToggle then uiElements.FarmToggle:Set(data.FarmEnabled) end
end

local function saveConfigToFile(cfgName)
    if cfgName == "" or cfgName == "---" then
        Rayfield:Notify({Title = "Config Error", Content = "Please enter a valid config name!", Duration = 3})
        return
    end
    
    if writefile then
        local filepath = configFolder .. "/" .. cfgName .. ".json"
        local jsonData = HttpService:JSONEncode(getCurrentConfigData())
        writefile(filepath, jsonData)
        Rayfield:Notify({Title = "Config Saved", Content = "Successfully saved config: " .. cfgName, Duration = 3})
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
            Rayfield:Notify({Title = "Config Loaded", Content = "Loaded config: " .. cfgName, Duration = 3})
        end
    end
end

local function deleteConfigFile(cfgName)
    if cfgName == "---" or cfgName == "" then return end
    local filepath = configFolder .. "/" .. cfgName .. ".json"
    if isfile and delfile and isfile(filepath) then
        delfile(filepath)
        Rayfield:Notify({Title = "Config Deleted", Content = "Deleted config: " .. cfgName, Duration = 3})
    end
end

-- ===== INTERFACE - SETTINGS TAB =====

TabSettings:CreateLabel("KEYBINDS")

uiElements.NoclipKeybind = TabSettings:CreateKeybind({
    Name = "Noclip Toggle Key",
    CurrentKeybind = "N",
    HoldToInteract = false,
    CallOnKeycode = true,
    Callback = function(key)
        noclipKeybind = tostring(key):gsub("Enum.KeyCode.", "")
        if isScriptRunning then
            toggleNoclip()
        end
    end,
})

uiElements.ArturTpKeybind = TabSettings:CreateKeybind({
    Name = "Artur Teleport Key",
    CurrentKeybind = "F",
    HoldToInteract = false,
    CallOnKeycode = true,
    Callback = function(key)
        arturTpKeybind = tostring(key):gsub("Enum.KeyCode.", "")
        if isScriptRunning then
            manualTeleportToArtur()
        end
    end,
})

TabSettings:CreateLabel("Config name")

TabSettings:CreateInput({
    Name = "Config Name Input",
    PlaceholderText = "Enter config name...",
    RemoveTextOnFocusLost = false,
    Callback = function(Text)
        currentConfigNameInput = Text
    end,
})

TabSettings:CreateButton({
    Name = "Create config",
    Callback = function()
        saveConfigToFile(currentConfigNameInput)
        if uiElements.ConfigDropdown then
            uiElements.ConfigDropdown:Refresh(getConfigFileList())
        end
    end,
})

TabSettings:CreateLabel("Config list")

uiElements.ConfigDropdown = TabSettings:CreateDropdown({
    Name = "Select Config",
    Options = getConfigFileList(),
    CurrentOption = {"---"},
    MultipleOptions = false,
    Callback = function(Option)
        if type(Option) == "table" then
            selectedConfig = Option[1] or "---"
        else
            selectedConfig = Option
        end
    end,
})

TabSettings:CreateButton({
    Name = "Load config",
    Callback = function()
        loadConfigFromFile(selectedConfig)
    end,
})

TabSettings:CreateButton({
    Name = "Overwrite config",
    Callback = function()
        saveConfigToFile(selectedConfig)
    end,
})

TabSettings:CreateButton({
    Name = "Delete config",
    Callback = function()
        deleteConfigFile(selectedConfig)
        if uiElements.ConfigDropdown then
            uiElements.ConfigDropdown:Refresh(getConfigFileList())
        end
    end,
})

TabSettings:CreateButton({
    Name = "Refresh list",
    Callback = function()
        if uiElements.ConfigDropdown then
            uiElements.ConfigDropdown:Refresh(getConfigFileList())
        end
    end,
})

local autoloadLabel = TabSettings:CreateLabel("Current autoload config: none")

TabSettings:CreateButton({
    Name = "Set as autoload",
    Callback = function()
        if selectedConfig ~= "---" and selectedConfig ~= "" then
            if writefile then
                writefile(configFolder .. "/autoload.txt", selectedConfig)
                autoloadLabel:Set("Current autoload config: " .. selectedConfig)
                Rayfield:Notify({Title = "Autoload Set", Content = "Autoload set to: " .. selectedConfig, Duration = 3})
            end
        end
    end,
})

TabSettings:CreateButton({
    Name = "Reset autoload",
    Callback = function()
        if isfile and delfile and isfile(configFolder .. "/autoload.txt") then
            delfile(configFolder .. "/autoload.txt")
        end
        autoloadLabel:Set("Current autoload config: none")
        Rayfield:Notify({Title = "Autoload Reset", Content = "Cleared autoload config", Duration = 3})
    end,
})

TabSettings:CreateLabel("UNLOAD SCRIPT")

TabSettings:CreateButton({
    Name = "Destroy Script / Unload",
    Callback = function()
        unloadScript()
    end,
})

-- ===== CHECK AUTOLOAD ON START =====
task.spawn(function()
    task.wait(1)
    local autoFile = configFolder .. "/autoload.txt"
    if isfile and readfile and isfile(autoFile) then
        local autoName = readfile(autoFile)
        if autoName and autoName ~= "" then
            autoloadLabel:Set("Current autoload config: " .. autoName)
            loadConfigFromFile(autoName)
        end
    end
end)

-- ===== UPDATE STATUSES =====
task.spawn(function()
    while isScriptRunning do
        if farming then
            farmStatus:Set("Status: ON | Collected: " .. collected .. " | On map: " .. #findCoins())
        else
            farmStatus:Set("Status: Off | Collected: " .. collected)
        end
        
        playerStatus:Set("WalkSpeed: " .. (walkspeedEnabled and "On" or "Off") .. " | Noclip: " .. (noclipEnabled and "On" or "Off"))
        visualStatus:Set("Fullbright: " .. (fullbrightEnabled and "On" or "Off") .. " | Holy Spice: " .. (holySpiceEnabled and "On" or "Off"))
        monsterStatus:Set("Anti Artur: " .. (antiArturEnabled and "On" or "Off"))
        
        task.wait(1)
    end
end)

-- ===== WELCOME =====
task.wait(1)
print("=================================")
print("Script for Murino horror")
print("Author: NikolayKot")
print("=================================")