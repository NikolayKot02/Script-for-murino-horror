--[[
    SWILL CORE // OFFICIAL ANIMATED LOADER
    Author: NikolayKot
    Target: Script-for-murino-horror
]]

-- ===== CONFIGURATION =====
local LOBBY_PLACE_ID = 72500576874545 -- Укажите Place ID вашего Лобби
local GAME_PLACE_ID = 82406104802807  -- Укажите Place ID игровой карты

local AUTH_TOKEN = "SWILL_SECURE_TOKEN_998811"
local PC_SCRIPT_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/Skriptmurino.lua"
local PHONE_SCRIPT_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/Skriptmurino.lua" -- Ссылка на мобильную версию

local env = getgenv and getgenv() or _G
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Разблокировка курсора
UserInputService.MouseBehavior = Enum.MouseBehavior.Default

-- ===== UI CONSTRUCTION =====
if CoreGui:FindFirstChild("SwillLoaderUI") then
    CoreGui.SwillLoaderUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SwillLoaderUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

-- Главная панель лоадера
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 220) 
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(40, 40, 40)
UIStroke.Thickness = 2
UIStroke.Transparency = 1
UIStroke.Parent = MainFrame

-- Кнопка закрытия (Крестик X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.AnchorPoint = Vector2.new(1, 0)
CloseBtn.Position = UDim2.new(0.96, 0, 0.05, 0)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextTransparency = 1
CloseBtn.Parent = MainFrame

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 60, 60)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    local tweenClose = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    TweenService:Create(MainFrame, tweenClose, {Size = UDim2.new(0, 0, 0, 220)}):Play()
    TweenService:Create(UIStroke, tweenClose, {Transparency = 1}):Play()
    TweenService:Create(CloseBtn, tweenClose, {TextTransparency = 1}):Play()
    task.wait(0.4)
    ScreenGui:Destroy()
end)

-- Текст: Script for murino horror
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.AnchorPoint = Vector2.new(0.5, 0)
TitleText.Position = UDim2.new(0.5, 0, 0.12, 0)
TitleText.Size = UDim2.new(0.9, 0, 0, 30)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Script for murino horror"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled = true
TitleText.Font = Enum.Font.FredokaOne
TitleText.TextTransparency = 1
TitleText.Parent = MainFrame

-- Текст: By NikolayKot
local SubtitleText = Instance.new("TextLabel")
SubtitleText.Name = "SubtitleText"
SubtitleText.AnchorPoint = Vector2.new(0.5, 0)
SubtitleText.Position = UDim2.new(0.5, 0, 0.28, 0)
SubtitleText.Size = UDim2.new(0.8, 0, 0, 18)
SubtitleText.BackgroundTransparency = 1
SubtitleText.Text = "By NikolayKot"
SubtitleText.TextColor3 = Color3.fromRGB(180, 180, 190)
SubtitleText.TextScaled = true
SubtitleText.Font = Enum.Font.GothamMedium
SubtitleText.TextTransparency = 1
SubtitleText.Parent = MainFrame

-- Текст Предупреждения (Ошибки / Лобби)
local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.AnchorPoint = Vector2.new(0.5, 0.5)
StatusText.Position = UDim2.new(0.5, 0, 0.65, 0)
StatusText.Size = UDim2.new(0.85, 0, 0, 40)
StatusText.BackgroundTransparency = 1
StatusText.Text = ""
StatusText.TextColor3 = Color3.fromRGB(255, 75, 75)
StatusText.TextSize = 16
StatusText.Font = Enum.Font.GothamBold
StatusText.TextWrapped = true
StatusText.TextTransparency = 1
StatusText.Parent = MainFrame

-- ===== BUTTONS CONTAINER =====
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Name = "ButtonsFrame"
ButtonsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ButtonsFrame.Position = UDim2.new(0.5, 0, 0.65, 0)
ButtonsFrame.Size = UDim2.new(0.8, 0, 0, 45)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Visible = false
ButtonsFrame.Parent = MainFrame

local function createPlatformButton(name, text, position)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Position = position
    btn.Size = UDim2.new(0.45, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextTransparency = 1
    btn.BackgroundTransparency = 1
    btn.Parent = ButtonsFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = btn

    return btn, stroke
end

local PhoneBtn, PhoneStroke = createPlatformButton("PhoneBtn", "Phone", UDim2.new(0, 0, 0, 0))
local PcBtn, PcStroke = createPlatformButton("PcBtn", "PC", UDim2.new(0.55, 0, 0, 0))

-- ===== LOADING CONTAINER =====
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.AnchorPoint = Vector2.new(1, 1)
LoadingFrame.Position = UDim2.new(0.95, 0, 0.9, 0)
LoadingFrame.Size = UDim2.new(0, 160, 0, 30)
LoadingFrame.BackgroundTransparency = 1
LoadingFrame.Visible = false
LoadingFrame.Parent = MainFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Position = UDim2.new(0, 0, 0, 0)
LoadingText.Size = UDim2.new(0, 85, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading"
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 18
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextXAlignment = Enum.TextXAlignment.Right
LoadingText.TextTransparency = 1
LoadingText.Parent = LoadingFrame

local dots = {}
for i = 1, 3 do
    local dot = Instance.new("TextLabel")
    dot.Name = "Dot" .. i
    dot.Position = UDim2.new(0, 90 + (i * 12), 0, 0)
    dot.Size = UDim2.new(0, 8, 1, 0)
    dot.BackgroundTransparency = 1
    dot.Text = "."
    dot.TextColor3 = Color3.fromRGB(255, 255, 255)
    dot.TextSize = 22
    dot.Font = Enum.Font.GothamBold
    dot.TextTransparency = 1
    dot.Parent = LoadingFrame
    table.insert(dots, dot)
end

-- ===== ANIMATION & PLACE CHECK LOGIC =====
local tweenInfoFast = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenInfoBook = TweenInfo.new(1.0, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Раскрытие окна из центра
TweenService:Create(MainFrame, tweenInfoBook, {Size = UDim2.new(0, 440, 0, 220)}):Play()
TweenService:Create(UIStroke, tweenInfoFast, {Transparency = 0}):Play()
task.wait(0.4)

TweenService:Create(TitleText, tweenInfoFast, {TextTransparency = 0}):Play()
TweenService:Create(SubtitleText, tweenInfoFast, {TextTransparency = 0}):Play()
TweenService:Create(CloseBtn, tweenInfoFast, {TextTransparency = 0}):Play()

-- ПРОВЕРКА МЕСТА (PLACE ID)
local currentPlaceId = game.PlaceId

if currentPlaceId == LOBBY_PLACE_ID then
    StatusText.Text = "Script does not work in the Lobby"
    TweenService:Create(StatusText, tweenInfoFast, {TextTransparency = 0}):Play()
elseif currentPlaceId == GAME_PLACE_ID then
    -- Показываем кнопки выбора платформы
    ButtonsFrame.Visible = true
    TweenService:Create(PhoneBtn, tweenInfoFast, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    TweenService:Create(PhoneStroke, tweenInfoFast, {Transparency = 0}):Play()
    TweenService:Create(PcBtn, tweenInfoFast, {TextTransparency = 0, BackgroundTransparency = 0}):Play()
    TweenService:Create(PcStroke, tweenInfoFast, {Transparency = 0}):Play()
else
    StatusText.Text = "This game is not supported"
    TweenService:Create(StatusText, tweenInfoFast, {TextTransparency = 0}):Play()
end

-- Функция запуска загрузки после клика
local function startLoadingProcess(scriptUrl)
    -- Скрываем кнопки
    TweenService:Create(PhoneBtn, tweenInfoFast, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    TweenService:Create(PhoneStroke, tweenInfoFast, {Transparency = 1}):Play()
    TweenService:Create(PcBtn, tweenInfoFast, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    TweenService:Create(PcStroke, tweenInfoFast, {Transparency = 1}):Play()

    task.wait(0.3)
    ButtonsFrame.Visible = false

    -- Показываем запуск
    LoadingFrame.Visible = true
    TweenService:Create(LoadingText, tweenInfoFast, {TextTransparency = 0}):Play()
    for _, dot in ipairs(dots) do
        TweenService:Create(dot, tweenInfoFast, {TextTransparency = 0}):Play()
    end

    local isLoading = true
    task.spawn(function()
        while isLoading do
            for i, dot in ipairs(dots) do
                if not isLoading then break end
                
                local upTween = TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 90 + (i * 12), 0, -6),
                    TextColor3 = Color3.fromRGB(0, 170, 255)
                })
                local downTween = TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, 90 + (i * 12), 0, 0),
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                })
                
                upTween:Play()
                upTween.Completed:Wait()
                downTween:Play()
                task.wait(0.1)
            end
        end
    end)

    task.wait(10)
    isLoading = false

    LoadingText.Text = "Done"
    for _, dot in ipairs(dots) do
        dot.Visible = false
    end

    task.wait(0.5)

    -- Закрываем интерфейс
    local tweenClose = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    TweenService:Create(MainFrame, tweenClose, {Size = UDim2.new(0, 0, 0, 220)}):Play()
    TweenService:Create(TitleText, tweenClose, {TextTransparency = 1}):Play()
    TweenService:Create(SubtitleText, tweenClose, {TextTransparency = 1}):Play()
    TweenService:Create(LoadingText, tweenClose, {TextTransparency = 1}):Play()
    TweenService:Create(CloseBtn, tweenClose, {TextTransparency = 1}):Play()
    TweenService:Create(UIStroke, tweenClose, {Transparency = 1}):Play()

    task.wait(0.7)
    ScreenGui:Destroy()

    -- ===== EXECUTE SELECTED SCRIPT =====
    print("[Swill Loader] Loading complete. Launching target script...")
    env._EXECUTOR_TOKEN = AUTH_TOKEN

    local success, result = pcall(function()
        local scriptContent = game:HttpGet(scriptUrl)
        local loadedFunc, err = loadstring(scriptContent)
        if not loadedFunc then
            error("Syntax/Compile error: " .. tostring(err))
        end
        return loadedFunc()
    end)

    if not success then
        env._EXECUTOR_TOKEN = nil
        warn("[Swill Loader] Execution failed:", result)
    end
end

-- Клики
PhoneBtn.MouseButton1Click:Connect(function()
    startLoadingProcess(PHONE_SCRIPT_URL)
end)

PcBtn.MouseButton1Click:Connect(function()
    startLoadingProcess(PC_SCRIPT_URL)
end)
