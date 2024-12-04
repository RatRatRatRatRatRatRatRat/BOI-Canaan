local mod = CANAAN
local game = Game()

local canaan = mod.PLAYER_CANAAN

mod.SporeTearBlacklist = {
    [TearVariant.SCHYTHE] = true,
    [TearVariant.CHAOS_CARD] = true,
    [TearVariant.FETUS] = true,
}

---@param player EntityPlayer
function mod:CanaanCache(player)
    if player:GetPlayerType() == canaan and player:HasWeaponType(WeaponType.WEAPON_TEARS) then
        player:EnableWeaponType(WeaponType.WEAPON_TEARS, false)
        player:EnableWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS, true)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.CanaanCache, CacheFlag.CACHE_WEAPON)

---@param player EntityPlayer
function mod:CanaanEffectUpdate(player)
    local weapon = player:GetWeapon(1)
    if weapon and weapon:GetWeaponType() == WeaponType.WEAPON_MONSTROS_LUNGS then
        if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) == 0 then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
        end
    elseif weapon and weapon:GetWeaponType() ~= WeaponType.WEAPON_MONSTROS_LUNGS then
        local innatemilk = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK, false, true)
        if innatemilk > 0 then
            player:AddInnateCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK, -innatemilk)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.CanaanEffectUpdate, canaan)

---@param tear EntityTear
function mod:CanaanFireTear(tear)
    local player = mod:GetPlayerFromTear(tear)
    if player and player:GetPlayerType() == canaan then
        if not mod.SporeTearBlacklist[tear.Variant] then
            tear:ChangeVariant(TearVariant.SPORE)
        end
        if tear.Color:__tostring() == Color.TearChocolate:__tostring() then
            tear.Color = Color()
        end

        tear.CollisionDamage = tear.BaseDamage / 2
        tear:GetData().CanaanTear = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.CanaanFireTear)

---@param tear EntityTear
function mod:CanaanTearUpdate(tear)
    if tear:GetData().CanaanTear and tear.Velocity:Length() > 1 then
        tear.Velocity = tear.Velocity * 0.95
        tear.FallingAcceleration = 0
        tear.FallingSpeed = 0
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_UPDATE, mod.CanaanTearUpdate)