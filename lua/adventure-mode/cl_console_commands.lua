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
