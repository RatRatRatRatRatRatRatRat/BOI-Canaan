local mod = CANAAN
local game = Game()

local canaan = mod.PLAYER_CANAAN

mod.SporeTearBlacklist = {
    [TearVariant.SCHYTHE] = true,
    [TearVariant.CHAOS_CARD] = true,
    [TearVariant.FETUS] = true,
}

---@param player EntityPlayer
---@param cache CacheFlag
function mod:CanaanCache(player, cache)
    if player:GetPlayerType() == canaan then
        if cache & CacheFlag.CACHE_WEAPON > 0 and player:HasWeaponType(WeaponType.WEAPON_TEARS) then
            player:EnableWeaponType(WeaponType.WEAPON_TEARS, false)
            player:EnableWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS, true)
        end

        if cache & CacheFlag.CACHE_TEARCOLOR > 0 then
            player.TearColor = Color()
            player.LaserColor = Color(1, 1, 1, 1, 0, 0, 0, 1.2, 0, 2.4, 1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.CanaanCache)

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

        tear.CollisionDamage = tear.BaseDamage / 4
        tear:GetData().CanaanTear = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.CanaanFireTear)

---@param tear EntityTear
function mod:CanaanTearUpdate(tear)
    if tear:GetData().CanaanTear and tear.Velocity:Length() > 1 then
        tear.Velocity = tear.Velocity * 0.95
        tear.FallingAcceleration = 0
        tear.FallingSpeed = 0
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_UPDATE, mod.CanaanTearUpdate)

---@param laser EntityLaser
function mod:CanaanFireLaser(laser)
    local player = mod:GetPlayerFromTear(laser)
    if player and player:GetPlayerType() == canaan then
        laser.Color = Color(1, 1, 1, 1, 0, 0, 0, 1.2, 0, 2.4, 1)
        laser:GetData().CanaanTear = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, mod.CanaanFireLaser)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, mod.CanaanFireLaser)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, mod.CanaanFireLaser)

---@param ent Entity
---@param flags DamageFlag
---@param source EntityRef
function mod:AddInfectedStatus(ent, dmg, flags, source)
    local npc = ent:ToNPC()
    if npc and npc:IsVulnerableEnemy() then
        if source.Type == EntityType.ENTITY_TEAR then
            local tear = source.Entity:ToTear()
            if tear and tear:GetData().CanaanTear then
                local player = tear.SpawnerEntity:ToPlayer() or tear.SpawnerEntity:ToFamiliar().Player
                if player then
                    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SAD_ONION)
                    if rng:RandomFloat() < 0.1 then
                        npc:GetData().CanaanInfected = true
                        print("WOOO!")
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, mod.AddInfectedStatus)

---@param npc EntityNPC
function mod:InfectedEnemyDeath(npc)
    if npc:GetData().CanaanInfected then
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, 2500, 0, npc.Position, Vector.Zero, nil):ToEffect()
        if creep then
            --creep.DepthOffset = -999999
            creep.SortingLayer = SortingLayer.SORTING_BACKGROUND
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.InfectedEnemyDeath)