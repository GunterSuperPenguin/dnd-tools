-- Фонарик
local hostFlashlight = nil
local hostFlashlightOn = false

hook.Add("PlayerBindPress", "DNDT_HostFlashlightToggle", function(pl, bind, pressed)
    if string.find(bind, "impulse 100") and pressed and pl:IsListenServerHost() then
        hostFlashlightOn = not hostFlashlightOn

        if hostFlashlightOn then
            if not IsValid(hostFlashlight) then
                hostFlashlight = ProjectedTexture()
                hostFlashlight:SetTexture("effects/flashlight001")
                hostFlashlight:SetFarZ(1024)
                hostFlashlight:SetFOV(70)
            end
        else
            if IsValid(hostFlashlight) then
                hostFlashlight:Remove()
                hostFlashlight = nil
            end
        end

        pl:EmitSound("items/flashlight1.wav")

        return true
    end
end)

hook.Add("Think", "DNDT_HostFlashlightUpdate", function()
    if hostFlashlightOn and IsValid(hostFlashlight) then
        local pl = LocalPlayer()
        if IsValid(pl) then
            hostFlashlight:SetPos(pl:GetShootPos())
            hostFlashlight:SetAngles(pl:GetAimVector():Angle())
            hostFlashlight:Update()
        end
    end
end)

hook.Add("ShutDown", "DNDT_CleanUpFlashlight", function()
    if IsValid(hostFlashlight) then
        hostFlashlight:Remove()
    end
end)

local adventure_mode = CreateConVar("dndt_adventuremode", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) режима приключений для игроков.", 0, 1)

local masterHaloPlayers = CreateConVar("dndt_masterhaloplayers", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) х-ray.", 0, 1)

local masterHaloStatusEffects = CreateConVar("dndt_masteralostatuseffects", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) х-ray.", 0, 1)

local matGlow = Material("models/debug/debugwhite")

hook.Add("PostDrawOpaqueRenderables", "XRayMasterSystem", function()
    if masterHaloPlayers:GetInt() == 0 and masterHaloStatusEffects:GetInt() == 0 then return end

    local ply = LocalPlayer()

    render.SuppressEngineLighting(true)
    render.MaterialOverride(matGlow)
    cam.IgnoreZ(true)

    if masterHaloPlayers:GetInt() == 1 then
        render.SetColorModulation(1, 0, 0)
        for _, target in ipairs(player.GetAll()) do
            if target == ply or not target:Alive() then continue end
            target:DrawModel()
        end
    end


    if masterHaloStatusEffects:GetInt() == 1 then
        render.SetColorModulation(0, 0, 1)
        for _, ent in ipairs(ents.FindByClass("dnd_status_effects")) do
            if not IsValid(ent) then continue end
            ent:DrawModel()
        end
    end

    cam.IgnoreZ(false)
    render.MaterialOverride(nil)
    render.SetColorModulation(1, 1, 1)
    render.SuppressEngineLighting(false)
end)


-- Хук для блокировки отрисовки гало-эффектов
hook.Add("PreDrawHalos", "DNDT_DisablePropsHalos", function()
    if not adventure_mode:GetBool() then return end

    -- if LocalPlayer():IsServerHost() then return end
    return true
end)


local masterFullbright = CreateConVar("dndt_masterfullbright", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включить/выключить потребность в свете..", 0, 1)

hook.Add("PreRender", "DNDT_MasterFullbright_Pre", function()
    if masterFullbright:GetBool() then
        local ply = LocalPlayer()

        if IsValid(ply) and ply:IsListenServerHost() then
            render.SetLightingMode(1)
        end
    end
end)

hook.Add("PreDrawHUD", "DNDT_MasterFullbright_HUD", function()
    render.SetLightingMode(0)
end)
