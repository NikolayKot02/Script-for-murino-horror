--[[
    SWILL CORE // OFFICIAL LOADER
    Author: NikolayKot
    Target: Script-for-murino-horror
]]

local AUTH_TOKEN = "SWILL_SECURE_TOKEN_998811"
local SCRIPT_URL = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/Skriptmurino.lua"

local env = getgenv and getgenv() or _G

print("[Swill Loader] Initializing execution process...")

-- Устанавливаем токен авторизации для основного скрипта
env._EXECUTOR_TOKEN = AUTH_TOKEN

-- Скачиваем и выполняем основной код
local success, result = pcall(function()
    local scriptContent = game:HttpGet(SCRIPT_URL)
    local loadedFunc, err = loadstring(scriptContent)
    
    if not loadedFunc then
        error("Syntax/Compile error: " .. tostring(err))
    end
    
    return loadedFunc()
end)

if not success then
    -- В случае ошибки сбрасываем токен
    env._EXECUTOR_TOKEN = nil
    warn("[Swill Loader] Failed to load script. Reason:", result)
else
    print("[Swill Loader] Script loaded successfully!")
end
