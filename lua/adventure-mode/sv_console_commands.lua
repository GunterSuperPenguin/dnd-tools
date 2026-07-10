-- Режим приключений
local adventure_mode = CreateConVar("dndt_adventuremode", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) режима приключений для игроков.", 0, 1)

local properties_to_hide = {
    --    "collision_off",
    --    "collision_on",
    "bodygroups",
    "bone_manipulate",
    "bone_manipulate_end",
    "drive",
    --    "gravity",
    "ignite",
    "extinguish",
    "keepupright",
    "keepupright_stop",
    "motioncontrol_ragdoll",
    "npc_bigger",
    "npc_smaller",
    "persist",
    "persist_end",
    "remove",
    "skin",
    "statue",
    "statue_stop"
}

hook.Add("Initialize", "DNDT_ModifyMultipleProperties", function()
    for _, prop_name in ipairs(properties_to_hide) do
        local prop = properties.List[prop_name]

        if prop then
            local original_filter = prop.Filter
            prop.Filter = function(self, ent, ply)
                if not IsValid(ply) then return false end

                -- if ply:IsListenServerHost() then
                --     if original_filter then
                --         return original_filter(self, ent, ply)
                --     else
                --         return true
                --     end
                -- end

                if adventure_mode:GetInt() == 1 then
                    return false
                end

                if original_filter then
                    return original_filter(self, ent, ply)
                else
                    return true
                end
            end
        end
    end
end)


-- Колизия игроков
local plcol = CreateConVar("dndt_playercollision", "1", { FCVAR_ARCHIVE },
    "Включение (1) или отключение (0) коллизии между игроками.", 0, 1)

local function update_collision(pl, collision_enabled)
    if not IsValid(pl) then return end

    if collision_enabled then
        pl:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        pl:SetAvoidPlayers(true)
    else
        pl:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        pl:SetAvoidPlayers(false)
    end
end

local function update_all_players()
    local state = plcol:GetBool()
    for _, pl in player.Iterator() do
        update_collision(pl, state)
    end
end

cvars.AddChangeCallback("dndt_playercollision", function()
    update_all_players()
end, "dnd-tools")

hook.Add("PostPlayerSpawn", "dndt_player_collision_spawn", function(pl)
    timer.Simple(0, function()
        update_collision(pl, plcol:GetBool())
    end)
end)


-- Фонарик
local enblfashlight = CreateConVar("dndt_enableflashlight", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Работа (1) или отключение (0) фонаря для всех игроков, кроме хоста.", 0, 1)

hook.Add("PlayerInitialSpawn", "DNDT_MarkFlashlightHost", function(pl)
    if pl:IsListenServerHost() then
        pl:SetNWBool("DNDT_IsHost", true)
    end
end)

hook.Add("PlayerSwitchFlashlight", "DNDT_RestrictFlashlight", function(pl, enabled)
    if pl:IsListenServerHost() then
        return false
    end

    if enblfashlight:GetInt() == 0 then
        if enabled then
            return false
        else
            return true
        end
    end

    return true
end)

cvars.AddChangeCallback("dndt_enableflashlight", function(_, _, value_new)
    if tonumber(value_new) == 0 then
        for _, pl in ipairs(player.GetAll()) do
            if not pl:IsListenServerHost() and pl:FlashlightIsOn() then
                pl:Flashlight(false)
            end
        end
    end
end, "DNDT_FlashlightCallback")
