-- Фонарик
local hostFlashlight = nil
local hostFlashlightOn = false

hook.Add( "PlayerBindPress", "DNDT_HostFlashlightToggle", function( pl, bind, pressed )
    if string.find( bind, "impulse 100" ) and pressed and pl:IsListenServerHost() then
        hostFlashlightOn = not hostFlashlightOn

        if hostFlashlightOn then
            if not IsValid( hostFlashlight ) then
                hostFlashlight = ProjectedTexture()
                hostFlashlight:SetTexture( "effects/flashlight001" )
                hostFlashlight:SetFarZ( 1024 )
                hostFlashlight:SetFOV( 70 )
            end
        else
            if IsValid( hostFlashlight ) then
                hostFlashlight:Remove()
                hostFlashlight = nil
            end
        end

        pl:EmitSound( "items/flashlight1.wav" )

        return true
    end
end )

hook.Add( "Think", "DNDT_HostFlashlightUpdate", function()
    if hostFlashlightOn and IsValid( hostFlashlight ) then
        local pl = LocalPlayer()
        if IsValid( pl ) then
            hostFlashlight:SetPos( pl:GetShootPos() )
            hostFlashlight:SetAngles( pl:GetAimVector():Angle() )
            hostFlashlight:Update()
        end
    end
end )

hook.Add( "ShutDown", "DNDT_CleanUpFlashlight", function()
    if IsValid( hostFlashlight ) then
        hostFlashlight:Remove()
    end
end )

local adventure_mode = CreateConVar( "dndt_adventuremode", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) режима приключений для игроков.", 0, 1 )

local masterHaloPlayers = CreateConVar( "dndt_masterhaloplayers", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) х-ray.", 0, 1 )

local masterHaloStatusEffects = CreateConVar( "dndt_masteralostatuseffects", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) х-ray.", 0, 1 )

local matGlow = Material( "models/debug/debugwhite" )

hook.Add( "PostDrawOpaqueRenderables", "XRayMasterSystem", function()
    if masterHaloPlayers:GetInt() == 0 and masterHaloStatusEffects:GetInt() == 0 then return end

    local ply = LocalPlayer()

    render.SuppressEngineLighting( true )
    render.MaterialOverride( matGlow )
    cam.IgnoreZ( true )

    if masterHaloPlayers:GetInt() == 1 then
        render.SetColorModulation( 1, 0, 0 )
        for _, target in ipairs( player.GetAll() ) do
            if target == ply or not target:Alive() then continue end

            target:DrawModel()
        end
    end

    if masterHaloStatusEffects:GetInt() == 1 then
        render.SetColorModulation( 0, 0, 1 )
        for _, ent in ipairs( ents.FindByClass( "dnd_status_effects" ) ) do
            if not IsValid( ent ) then continue end

            ent:DrawModel()
        end
    end

    cam.IgnoreZ( false )
    render.MaterialOverride( nil )
    render.SetColorModulation( 1, 1, 1 )
    render.SuppressEngineLighting( false )
end )


-- Хук для блокировки отрисовки гало-эффектов
hook.Add( "PreDrawHalos", "DNDT_DisablePropsHalos", function()
    if not adventure_mode:GetBool() then return end

    -- if LocalPlayer():IsServerHost() then return end
    return true
end )


local dnd_tools_master_fullbright = CreateConVar( "dnd_tools_master_fullbright", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включить/выключить потребность в свете..", 0, 1 )


local function enable_fullbright()
    hook.Add( "PreRender", "DNDT_MasterFullbright_pre", function()
        render.SetLightingMode( 1 )
    end )

    hook.Add( "PostDrawEffects", "DNDT_MasterFullbright_post", function()
        render.SetLightingMode( 0 )
    end )
end

local function disable_fullbright()
    hook.Remove( "PreRender", "DNDT_MasterFullbright_pre" )
    hook.Remove( "PostDrawEffects", "DNDT_MasterFullbright_post" )
end

local function init_garry_mother()
    local pl = LocalPlayer()
    if pl == nil or not (pl:IsValid() and pl:IsListenServerHost()) then return end

    hook.Remove( "PostDrawEffects", "RenderHalos" )

    if dnd_tools_master_fullbright:GetBool() then
        enable_fullbright()
    else
        disable_fullbright()
    end

    cvars.AddChangeCallback( dnd_tools_master_fullbright:GetName(), function( _, __, value )
        if value == "1" then
            enable_fullbright()
        else
            disable_fullbright()
        end
    end, "Fuck Garry" )
end

hook.Add( "InitPostEntity", "DNDT_MasterFullbright", init_garry_mother )
init_garry_mother()
