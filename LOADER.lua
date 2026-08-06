--[[
    SWILL CORE // OFFICIAL ANIMATED LOADER
    Author: NikolayKot
    Target: Script-for-murino-horror
]]

-- ===== CONFIGURATION =====
local LOBBY_PLACE_ID = 72500576874545 -- Укажите Place ID вашего Лобби
local GAME_PLACE_ID = 82406104802807  -- Укажите Place ID игровой карты

-- Список Roblox UserId пользователей, которым доступен Бета-тест
local BETA_USERS = {
    -- 123456789, -- Добавь сюда UserId нужных игроков
    8536712832,
    8551389725
}

local AUTH_TOKEN = "SWILL_SECURE_TOKEN_998811"
local PC_SCRIPT_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/Skriptmurino.lua"
local PHONE_SCRIPT_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/Skriptmurinophone.lua"

-- ПРЯМЫЕ ССЫЛКИ НА КАРТИНКИ С GITHUB (RAW)
local PHONE_ICON_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/main/resurses/noFilter2.png"
local PC_ICON_URL    = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/main/resurses/noFilter.png"
local CLOSE_ICON_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/main/resurses/Close.png"

local env = getgenv and getgenv() or _G
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- Проверка: имеет ли текущий игрок доступ к бета-тесту
local function isUserInBeta(userId)
    -- Если список пустой, то доступно всем (для удобства тестов)
    if #BETA_USERS == 0 then return true end 
    for _, id in ipairs(BETA_USERS) do
        if id == userId then
            return true
        end
    end
    return false
end

local HAS_BETA_ACCESS = isUserInBeta(LocalPlayer.UserId)

-- Определяем платформу пользователя
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Разблокировка курсора
UserInputService.MouseBehavior = Enum.MouseBehavior.Default

-- ===== HELPER: GITHUB IMAGE LOADER =====
local function getGithubAsset(url, fileName)
    if not (writefile and isfile and getcustomasset) then
        warn("[Swill Loader] Ваш эксплойт не поддерживает getcustomasset/writefile!")
        return ""
    end

    local folderName = "SwillLoaderAssets"
    if not isfolder(folderName) then
        makefolder(folderName)
    end

    local filePath = folderName .. "/" .. fileName
    if not isfile(filePath) then
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            writefile(filePath, result)
        else
            warn("[Swill Loader] Не удалось загрузить картинку с GitHub:", url)
            return ""
        end
    end

    return getcustomasset(filePath)
end

-- Загружаем ресурсы с GitHub
local PHONE_ICON_ASSET = getGithubAsset(PHONE_ICON_URL, "phone_icon.png")
local PC_ICON_ASSET    = getGithubAsset(PC_ICON_URL, "pc_icon.png")
local CLOSE_ICON_ASSET = getGithubAsset(CLOSE_ICON_URL, "close_icon.png")

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
TitleText.Position = UDim2.new(0.5, 0, 0.08, 0)
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
SubtitleText.Position = UDim2.new(0.5, 0, 0.23, 0)
SubtitleText.Size = UDim2.new(0.8, 0, 0, 18)
SubtitleText.BackgroundTransparency = 1
SubtitleText.Text = "By NikolayKot"
SubtitleText.TextColor3 = Color3.fromRGB(180, 180, 190)
SubtitleText.TextScaled = true
SubtitleText.Font = Enum.Font.GothamMedium
SubtitleText.TextTransparency = 1
SubtitleText.Parent = MainFrame

-- Текст статуса загрузки по центру
local CenterStageText = Instance.new("TextLabel")
CenterStageText.Name = "CenterStageText"
CenterStageText.AnchorPoint = Vector2.new(0.5, 0.5)
CenterStageText.Position = UDim2.new(0.5, 0, 0.54, 0)
CenterStageText.Size = UDim2.new(0.85, 0, 0, 30)
CenterStageText.BackgroundTransparency = 1
CenterStageText.Text = ""
CenterStageText.TextColor3 = Color3.fromRGB(160, 160, 170)
CenterStageText.TextSize = 16
CenterStageText.Font = Enum.Font.GothamBold
CenterStageText.TextTransparency = 1
CenterStageText.Parent = MainFrame

-- Постоянная надпись под основным текстом загрузки (для бета-теста)
local BetaNoticeText = Instance.new("TextLabel")
BetaNoticeText.Name = "BetaNoticeText"
BetaNoticeText.AnchorPoint = Vector2.new(0.5, 0)
BetaNoticeText.Position = UDim2.new(0.5, 0, 0.67, 0)
BetaNoticeText.Size = UDim2.new(0.9, 0, 0, 20)
BetaNoticeText.BackgroundTransparency = 1
BetaNoticeText.Text = "This is a beta test and there are many bugs"
BetaNoticeText.TextColor3 = Color3.fromRGB(255, 170, 0)
BetaNoticeText.TextSize = 12
BetaNoticeText.Font = Enum.Font.GothamMedium
BetaNoticeText.TextTransparency = 1
BetaNoticeText.Parent = MainFrame

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
ButtonsFrame.Position = UDim2.new(0.5, 0, 0.62, 0)
ButtonsFrame.Size = UDim2.new(0.8, 0, 0, 65)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Visible = false
ButtonsFrame.Parent = MainFrame

local function createPlatformButton(name, text, assetId, position)
    local wrapper = Instance.new("Frame")
    wrapper.Name = name .. "_Wrapper"
    wrapper.Position = position
    wrapper.Size = UDim2.new(0.45, 0, 1, 0)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = ButtonsFrame

    -- Текст ошибки / предупреждения сверху кнопки
    local warnText = Instance.new("TextLabel")
    warnText.Name = "WarnText"
    warnText.Size = UDim2.new(1, 0, 0, 14)
    warnText.Position = UDim2.new(0, 0, 0, -16)
    warnText.BackgroundTransparency = 1
    warnText.Text = ""
    warnText.TextColor3 = Color3.fromRGB(255, 75, 75)
    warnText.Font = Enum.Font.GothamBold
    warnText.TextSize = 9
    warnText.TextScaled = true
    warnText.TextTransparency = 1
    warnText.Parent = wrapper

    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = ""
    btn.BackgroundTransparency = 1
    btn.Parent = wrapper

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = btn

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 4)
    layout.Parent = btn

    local icon = Instance.new("ImageLabel")
    icon.Name = "ButtonIcon"
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.BackgroundTransparency = 1
    icon.Image = assetId
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    icon.ImageTransparency = 1
    icon.Parent = btn

    local txtLabel = Instance.new("TextLabel")
    txtLabel.Name = "ButtonText"
    txtLabel.Size = UDim2.new(1, 0, 0, 18)
    txtLabel.BackgroundTransparency = 1
    txtLabel.Text = text
    txtLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    txtLabel.Font = Enum.Font.GothamBold
    txtLabel.TextSize = 15
    txtLabel.TextTransparency = 1
    txtLabel.Parent = btn

    return btn, stroke, icon, txtLabel, warnText, wrapper
end

local PhoneBtn, PhoneStroke, PhoneIcon, PhoneText, PhoneWarn, PhoneWrapper = createPlatformButton("PhoneBtn", "Phone", PHONE_ICON_ASSET, UDim2.new(0, 0, 0, 0))
local PcBtn, PcStroke, PcIcon, PcText, PcWarn, PcWrapper       = createPlatformButton("PcBtn", "PC", PC_ICON_ASSET, UDim2.new(0.55, 0, 0, 0))

-- ===== MINI BETA TEST BUTTON (ПОД КНОПКОЙ PHONE) =====
local BetaPhoneBtn = Instance.new("TextButton")
BetaPhoneBtn.Name = "BetaPhoneBtn"
BetaPhoneBtn.Position = UDim2.new(0, 0, 1, 6)
BetaPhoneBtn.Size = UDim2.new(1, 0, 0, 20)
BetaPhoneBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
BetaPhoneBtn.Text = "Beta Test"
BetaPhoneBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
BetaPhoneBtn.Font = Enum.Font.GothamBold
BetaPhoneBtn.TextSize = 11
BetaPhoneBtn.BackgroundTransparency = 1
BetaPhoneBtn.TextTransparency = 1
BetaPhoneBtn.Visible = HAS_BETA_ACCESS -- Видимость зависит от прав бета-теста
BetaPhoneBtn.Parent = PhoneWrapper

local BetaCorner = Instance.new("UICorner")
BetaCorner.CornerRadius = UDim.new(0, 5)
BetaCorner.Parent = BetaPhoneBtn

local BetaStroke = Instance.new("UIStroke")
BetaStroke.Color = Color3.fromRGB(0, 140, 220)
BetaStroke.Thickness = 1
BetaStroke.Transparency = 1
BetaStroke.Parent = BetaPhoneBtn

BetaPhoneBtn.MouseEnter:Connect(function()
    TweenService:Create(BetaPhoneBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 200), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
BetaPhoneBtn.MouseLeave:Connect(function()
    TweenService:Create(BetaPhoneBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Color3.fromRGB(0, 180, 255)}):Play()
end)

-- ===== PLATFORM & AVAILABILITY LOGIC =====
local isPhoneDisabled = true      -- Временно отключено ("Coming soon...")
local isPcDisabled    = IS_MOBILE -- На телефоне кнопка PC не работает

-- Настройка состояния кнопки Phone
PhoneIcon.Image = CLOSE_ICON_ASSET
PhoneText.TextColor3 = Color3.fromRGB(120, 120, 130)
PhoneBtn.AutoButtonColor = false
PhoneWarn.Text = "Coming soon..."

-- Настройка состояния кнопки PC
if isPcDisabled then
    PcIcon.Image = CLOSE_ICON_ASSET
    PcText.TextColor3 = Color3.fromRGB(120, 120, 130)
    PcBtn.AutoButtonColor = false
    PcWarn.Text = "System does not support this script"
end

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
    ButtonsFrame.Visible = true
    
    TweenService:Create(PhoneBtn, tweenInfoFast, {BackgroundTransparency = 0}):Play()
    TweenService:Create(PhoneIcon, tweenInfoFast, {ImageTransparency = 0}):Play()
    TweenService:Create(PhoneText, tweenInfoFast, {TextTransparency = 0}):Play()
    TweenService:Create(PhoneStroke, tweenInfoFast, {Transparency = 0}):Play()
    if PhoneWarn.Text ~= "" then
        TweenService:Create(PhoneWarn, tweenInfoFast, {TextTransparency = 0}):Play()
    end
    
    -- Проявление мини-кнопки Бета-теста (только для разрешенных пользователей)
    if HAS_BETA_ACCESS then
        TweenService:Create(BetaPhoneBtn, tweenInfoFast, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        TweenService:Create(BetaStroke, tweenInfoFast, {Transparency = 0}):Play()
    end

    TweenService:Create(PcBtn, tweenInfoFast, {BackgroundTransparency = 0}):Play()
    TweenService:Create(PcIcon, tweenInfoFast, {ImageTransparency = 0}):Play()
    TweenService:Create(PcText, tweenInfoFast, {TextTransparency = 0}):Play()
    TweenService:Create(PcStroke, tweenInfoFast, {Transparency = 0}):Play()
    if PcWarn.Text ~= "" then
        TweenService:Create(PcWarn, tweenInfoFast, {TextTransparency = 0}):Play()
    end
else
    StatusText.Text = "This game is not supported"
    TweenService:Create(StatusText, tweenInfoFast, {TextTransparency = 0}):Play()
end

-- Функция запуска загрузки после клика
local function startLoadingProcess(scriptUrl, isBeta)
    TweenService:Create(PhoneBtn, tweenInfoFast, {BackgroundTransparency = 1}):Play()
    TweenService:Create(PhoneIcon, tweenInfoFast, {ImageTransparency = 1}):Play()
    TweenService:Create(PhoneText, tweenInfoFast, {TextTransparency = 1}):Play()
    TweenService:Create(PhoneStroke, tweenInfoFast, {Transparency = 1}):Play()
    TweenService:Create(PhoneWarn, tweenInfoFast, {TextTransparency = 1}):Play()

    if HAS_BETA_ACCESS then
        TweenService:Create(BetaPhoneBtn, tweenInfoFast, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(BetaStroke, tweenInfoFast, {Transparency = 1}):Play()
    end

    TweenService:Create(PcBtn, tweenInfoFast, {BackgroundTransparency = 1}):Play()
    TweenService:Create(PcIcon, tweenInfoFast, {ImageTransparency = 1}):Play()
    TweenService:Create(PcText, tweenInfoFast, {TextTransparency = 1}):Play()
    TweenService:Create(PcStroke, tweenInfoFast, {Transparency = 1}):Play()
    TweenService:Create(PcWarn, tweenInfoFast, {TextTransparency = 1}):Play()

    TweenService:Create(CloseBtn, tweenInfoFast, {TextTransparency = 1}):Play()

    task.wait(0.3)
    ButtonsFrame.Visible = false
    CloseBtn.Visible = false

    -- Показываем предупреждающую надпись только в режиме бета-теста
    if isBeta then
        TweenService:Create(BetaNoticeText, tweenInfoFast, {TextTransparency = 0}):Play()
    end

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

    local stages = {"check place", "loading language", "loading script"}
    local fadeTime = 0.5
    local displayTime = 2.0

    task.spawn(function()
        for i, stage in ipairs(stages) do
            if not isLoading then break end
            
            CenterStageText.Text = stage
            local fadeIn = TweenService:Create(CenterStageText, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
            fadeIn:Play()
            fadeIn.Completed:Wait()

            task.wait(displayTime)

            local fadeOut = TweenService:Create(CenterStageText, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Wait()
        end
    end)

    task.wait(#stages * (fadeTime * 2 + displayTime))
    isLoading = false

    TweenService:Create(CenterStageText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    if isBeta then
        TweenService:Create(BetaNoticeText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    end

    LoadingText.Text = "Done"
    for _, dot in ipairs(dots) do
        dot.Visible = false
    end

    task.wait(0.6)

    local tweenClose = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    TweenService:Create(MainFrame, tweenClose, {Size = UDim2.new(0, 0, 0, 220)}):Play()
    TweenService:Create(TitleText, tweenClose, {TextTransparency = 1}):Play()
    TweenService:Create(SubtitleText, tweenClose, {TextTransparency = 1}):Play()
    TweenService:Create(LoadingText, tweenClose, {TextTransparency = 1}):Play()
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

-- ОБРАБОТКА КЛИКОВ (С проверкой доступности)
PhoneBtn.MouseButton1Click:Connect(function()
    if isPhoneDisabled then
        return -- Заблокировано (Coming soon...)
    end
    startLoadingProcess(PHONE_SCRIPT_URL, false)
end)

BetaPhoneBtn.MouseButton1Click:Connect(function()
    startLoadingProcess(PHONE_SCRIPT_URL, true)
end)

PcBtn.MouseButton1Click:Connect(function()
    if isPcDisabled then
        return -- Заблокировано для мобильных устройств
    end
    startLoadingProcess(PC_SCRIPT_URL, false)
end)
