local fpsfog_active = CreateConVar("fpsfog_active", 0, 8192 + 128, "enables fps saving fog", 0, 1)
local fpsfog_skybox = CreateConVar("fpsfog_skybox", 1, 8192 + 128, "disables skybox", 0, 1)
local fpsfog_distance = CreateConVar("fpsfog_distance", 6500, 8192 + 128, "distance at which fog becomes opaque", 0,
    20000)
local fpsfog_thickness = CreateConVar("fpsfog_thickness", 50, 8192 + 128, "distance at which fog starts", 0, 100)
local fpsfog_color_r = CreateConVar("fpsfog_color_r", 200, 8192 + 128, "red component", 0, 255)
local fpsfog_color_g = CreateConVar("fpsfog_color_g", 200, 8192 + 128, "blue component", 0, 255)
local fpsfog_color_b = CreateConVar("fpsfog_color_b", 200, 8192 + 128, "green component", 0, 255)

LocalPlayer().fpsfog_3dsky = GetConVar("r_3dsky"):GetFloat()

local fpsfog_SC_pos = fpsfog_SC_pos
local fpsfog_SC_scale = fpsfog_SC_scale

net.Receive("fpsfog_3dsky", function(len, ply)
    local active = net.ReadInt(3)
    fpsfog_SC_scale = net.ReadInt(8)
    fpsfog_SC_pos = net.ReadVector()

    LocalPlayer():ConCommand("r_3dsky " .. tostring(active))
end)

local fogactive = true
local fogend = 5000
local fogstart = 3000
local fogcolor = Color(83, 83, 83)

hook.Add("InitPostEntity", "fpsfog_postinit", function()
    local existingcontrollers = ents.FindByClass("env_fog_controller")

    PrintTable(existingcontrollers)

    for _, v in ipairs(existingcontrollers) do
        v.fpsfog_originalvalue = v:GetKeyValues().farz
    end

    fpsfog_skycamera = ents.FindByClass("sky_camera")[1]
end)

hook.Add("ShutDown", "fpsfog_returnsky", function()
    RunConsoleCommand("r_3dsky", 1)
end)


local constructmat = Material("gm_construct/color_room")

hook.Add("PreDrawOpaqueRenderables", "fpsfog_removeskybox", function(depth, skybox)
    local active = GetConVar("fpsfog_active"):GetFloat()

    if active == 1 and fpsfog_SC_scale ~= nil then
        local ply = LocalPlayer()
        local view = render.GetViewSetup()
        local lookdir = view.angles
        local lookpos = view.origin
        local looknorm = Vector(1, 0, 0)
        looknorm:Rotate(lookdir)
        local fogend = GetConVar("fpsfog_distance"):GetFloat()
        local fpsfog_r = GetConVar("fpsfog_color_r"):GetFloat()
        local fpsfog_g = GetConVar("fpsfog_color_g"):GetFloat()
        local fpsfog_b = GetConVar("fpsfog_color_b"):GetFloat()

        if skybox and GetConVar("fpsfog_skybox"):GetFloat() == 1 then
            render.SetMaterial(constructmat)
            render.DrawQuadEasy((lookpos + looknorm * fogend) / fpsfog_SC_scale + fpsfog_SC_pos, looknorm * -1, 1000000,
                1000000, Color(fpsfog_r, fpsfog_g, fpsfog_b))
        elseif GetConVar("fpsfog_skybox"):GetFloat() == 0 then
            render.SetMaterial(constructmat)
            render.DrawQuadEasy((lookpos + looknorm * fogend), looknorm * -1, 1000000, 1000000,
                Color(fpsfog_r, fpsfog_g, fpsfog_b))
        end
    end
end)

hook.Add("SetupWorldFog", "fpsfog_fog", function()
    local active = GetConVar("fpsfog_active"):GetFloat()

    if active == 1 then
        local fogend = GetConVar("fpsfog_distance"):GetFloat()
        local fogstart = fogend - fogend * (GetConVar("fpsfog_thickness"):GetFloat() / 100)
        local fpsfog_r = GetConVar("fpsfog_color_r"):GetFloat()
        local fpsfog_g = GetConVar("fpsfog_color_g"):GetFloat()
        local fpsfog_b = GetConVar("fpsfog_color_b"):GetFloat()

        render.FogMode(active)
        render.FogColor(fpsfog_r, fpsfog_g, fpsfog_b)
        render.FogMaxDensity(1)
        render.FogStart(fogstart)
        render.FogEnd(fogend)

        return true
    end
end)

hook.Add("SetupSkyboxFog", "fpsfog_skyfog", function(scale)
    local active = GetConVar("fpsfog_active"):GetFloat()

    if active == 1 then
        local fogend = GetConVar("fpsfog_distance"):GetFloat()
        local fogstart = fogend - fogend * (GetConVar("fpsfog_thickness"):GetFloat() / 100)
        local fpsfog_r = GetConVar("fpsfog_color_r"):GetFloat()
        local fpsfog_g = GetConVar("fpsfog_color_g"):GetFloat()
        local fpsfog_b = GetConVar("fpsfog_color_b"):GetFloat()

        render.FogMode(active)
        render.FogColor(fpsfog_r, fpsfog_g, fpsfog_b)
        render.FogMaxDensity(1)
        render.FogStart(fogstart * scale)
        render.FogEnd(fogend * scale)

        return true
    end
end)
