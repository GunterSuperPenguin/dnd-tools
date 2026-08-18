-- Колизия игроков
local plcol = CreateConVar( "dndt_playercollision", "1", { FCVAR_ARCHIVE },
    "Включение (1) или отключение (0) коллизии между игроками.", 0, 1 )

local function update_collision( pl, collision_enabled )
    if not IsValid( pl ) then return end

    if collision_enabled then
        pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
        pl:SetAvoidPlayers( true )
    else
        pl:SetCollisionGroup( COLLISION_GROUP_WEAPON )
        pl:SetAvoidPlayers( false )
    end
end

local function update_all_players()
    local state = plcol:GetBool()
    for _, pl in player.Iterator() do
        update_collision( pl, state )
    end
end

cvars.AddChangeCallback( "dndt_playercollision", function()
    update_all_players()
end, "dnd-tools" )

hook.Add( "PostPlayerSpawn", "dndt_player_collision_spawn", function( pl )
    timer.Simple( 0, function()
        update_collision( pl, plcol:GetBool() )
    end )
end )


-- Фонарик
local enblfashlight = CreateConVar( "dndt_enableflashlight", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Работа (1) или отключение (0) фонаря для всех игроков, кроме хоста.", 0, 1 )

hook.Add( "PlayerInitialSpawn", "DNDT_MarkFlashlightHost", function( pl )
    if pl:IsListenServerHost() then
        pl:SetNWBool( "DNDT_IsHost", true )
    end

    -- if pl:IsListenServerHost() and enblfashlight:GetBool() then
    --     UpdateFogForHost( "1" )
    -- end
end )

hook.Add( "PlayerSwitchFlashlight", "DNDT_RestrictFlashlight", function( pl, enabled )
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
end )

cvars.AddChangeCallback( "dndt_enableflashlight", function( _, _, value_new )
    if tonumber( value_new ) == 0 then
        for _, pl in ipairs( player.GetAll() ) do
            if not pl:IsListenServerHost() and pl:FlashlightIsOn() then
                pl:Flashlight( false )
            end
        end
    end
end, "DNDT_FlashlightCallback" )


-- Фулбрайт
local masterFullbright = CreateConVar( "dndt_masterfullbright", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включить/выключить потребность в свете у хоста.", 0, 1 )


-- Вкл/откл туман
local masterFogSkip = CreateConVar( "dndt_masterfogskip", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включить/выключить туман для мастера.", 0, 1 )

-- Гало для статус эффектов
local masterHaloStatusEffects = CreateConVar( "dndt_masteralostatuseffects", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) х-ray.", 0, 1 )
