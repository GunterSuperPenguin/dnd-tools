if SERVER then
    AddCSLuaFile("adventure-mode/cl_start_sgins.lua")
    AddCSLuaFile("adventure-mode/cl_master_panel.lua")
    AddCSLuaFile("dnd-status-effects/sv_status_system.lua")

    include("dnd-status-effects/sv_status_system.lua")
    include("adventure-mode/sv_start_sgins.lua")
end

if CLIENT then
    include("dnd-status-effects/sv_status_system.lua")
    include("adventure-mode/cl_start_sgins.lua")
    include("adventure-mode/cl_master_panel.lua")
end
