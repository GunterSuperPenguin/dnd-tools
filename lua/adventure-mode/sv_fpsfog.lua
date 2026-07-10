local fpsfog_active = CreateConVar("fpsfog_active", 0, 8192 + 128, "enables fps saving fog", 0, 1)
local fpsfog_skybox = CreateConVar("fpsfog_skybox", 1, 8192 + 128, "disables skybox", 0, 1)
local fpsfog_distance = CreateConVar("fpsfog_distance", 6500, 8192 + 128, "distance at which fog becomes opaque", 0,
    20000)
local fpsfog_thickness = CreateConVar("fpsfog_thickness", 50, 8192 + 128, "distance at which fog starts", 0, 100)
local fpsfog_color_r = CreateConVar("fpsfog_color_r", 200, 8192 + 128, "red component", 0, 255)
local fpsfog_color_g = CreateConVar("fpsfog_color_g", 200, 8192 + 128, "blue component", 0, 255)
local fpsfog_color_b = CreateConVar("fpsfog_color_b", 200, 8192 + 128, "green component", 0, 255)

util.AddNetworkString("fpsfog_3dsky")
util.AddNetworkString("fpsfog_sendskycamera")

local fpsfog_SC_pos = fpsfog_SC_pos
local fpsfog_SC_scale = fpsfog_SC_scale

cvars.AddChangeCallback("fpsfog_skybox", function(name, old, new)
    if #player.GetAll() > 0 then
        local skyscale = 1
        local skypos = Vector(0, 0, 0)
        local skybox = 0

        if IsValid(fpsfog_skycamera) then
            skyscale = fpsfog_skycamera:GetKeyValues().scale
            skypos = fpsfog_skycamera:GetPos()
            skybox = new
        end

        net.Start("fpsfog_3dsky")
        net.WriteInt(skybox, 3)
        net.WriteInt(skyscale, 8)
        net.WriteVector(skypos)
        net.Broadcast()
    end
end)

local fogactive = true
local fogend = 5000
local fogstart = 3000
local fogcolor = Color(83, 83, 83)

local fpsfog_newcontroller = ents.Create("env_fog_controller")

local load_queue = {}

hook.Add("PlayerInitialSpawn", "fpsfog_plyspawn", function(ply)
    load_queue[ply] = true
end)

hook.Add("SetupMove", "fpsfog_plyload", function(ply, _, cmd)
    if load_queue[ply] and not cmd:IsForced() then
        load_queue[ply] = nil

        local skyscale = 1
        local skypos = Vector(0, 0, 0)
        if IsValid(fpsfog_skycamera) then
            skyscale = fpsfog_skycamera:GetKeyValues().scale
            skypos = fpsfog_skycamera:GetPos()
        end


        net.Start("fpsfog_3dsky")
        net.WriteInt(GetConVar("fpsfog_skybox"):GetFloat(), 3)
        net.WriteInt(skyscale, 8)
        net.WriteVector(skypos)
        net.Send(ply)
    end
end)


hook.Add("InitPostEntity", "fpsfog_postinit", function()
    local existingcontrollers = ents.FindByClass("env_fog_controller")

    PrintTable(existingcontrollers)

    for _, v in ipairs(existingcontrollers) do
        v.fpsfog_originalvalue = v:GetKeyValues().farz
    end

    if #existingcontrollers > 1 then
        fpsfog_newcontroller:Remove()
    end

    fpsfog_skycamera = ents.FindByClass("sky_camera")[1]
end)


hook.Add("Think", "fpsfog_farz", function()
    local active = GetConVar("fpsfog_active"):GetFloat()
    local fogend = GetConVar("fpsfog_distance"):GetFloat()

    if active == 1 then
        for k, v in pairs(ents.FindByClass("env_fog_controller")) do
            v:SetKeyValue("farz", fogend + 250)
        end
    else
        for k, v in pairs(ents.FindByClass("env_fog_controller")) do
            v:SetKeyValue("farz", v.fpsfog_originalvalue or -1)
        end
    end
end)
