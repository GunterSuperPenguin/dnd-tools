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

-- hook.Add("PreDrawHalos", "MyCustomHaloHook", function()
--     -- Подсвечиваем всех игроков на сервере красным цветом
--     local players = player.GetAll()
--     local haloColor = Color(255, 79, 0)

--     (таблица_объектов, цвет, размытие_X, размытие_Y, проходы, аддитивный, видеть_сквозь_стены)
--     halo.Add(players, haloColor, 5, 5, 100, true, true)
-- end)

local adventure_mode = CreateConVar("dndt_adventuremode", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Включение (1) или отключение (0) режима приключений для игроков.", 0, 1)

-- Хук для блокировки отрисовки гало-эффектов
hook.Add("PreDrawHalos", "DNDT_DisablePropsHalos", function()
    if not adventure_mode:GetBool() then return end

    -- if LocalPlayer():IsServerHost() then return end

    return true
end)
