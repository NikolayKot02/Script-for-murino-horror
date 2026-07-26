-- ===== LOADER SCRIPT =====
print("[Loader] Checking license & initializing...")

-- Передаем права на запуск
_G.SwillHubAllowed = true
_G.SwillHubKey = "SWILL_SECURE_TOKEN_998811"

-- Загружаем и запускаем основной скрипт
local scriptUrl = "https://raw.githubusercontent.com/NikolayKot02/Script-for-murino-horror/refs/heads/main/Skriptmurino.lua"

local success, result = pcall(function()
    return loadstring(game:HttpGet(scriptUrl))()
end)

if not success then
    warn("[Loader] Failed to execute main script:", result)
end
