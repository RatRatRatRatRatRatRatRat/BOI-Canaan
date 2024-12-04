CANAAN = RegisterMod("Canaan", 1)
local mod = CANAAN
mod.Version = "0.0.1"

local scripts = {
    helpers = include("scripts.helpers"),
    constants = include("scripts.constants"),

    canaan = include("scripts.canaan"),
}

for _, player in pairs(PlayerManager.GetPlayers()) do
    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end