if SERVER then
    AddCSLuaFile( "adventure-mode/sh_properties_hide.lua" )
    AddCSLuaFile( "adventure-mode/cl_start_sgins.lua" )
    AddCSLuaFile( "adventure-mode/cl_master_panel.lua" )
    AddCSLuaFile( "dnd-status-effects/sv_status_system.lua" )
    AddCSLuaFile( "adventure-mode/cl_console_commands.lua" )
    AddCSLuaFile( "adventure-mode/cl_fpsfog.lua" )

    include( "sv_data.lua" )
    include( "adventure-mode/sh_properties_hide.lua" )

    include( "adventure-mode/sv_mastrer_panel.lua" )
    include( "adventure-mode/sv_console_commands.lua" )
    include( "adventure-mode/sv_queue.lua" )
    include( "dnd-status-effects/sv_status_system.lua" )
    include( "adventure-mode/sv_fpsfog.lua" )
    include( "adventure-mode/sv_start_sgins.lua" )
else
    include( "adventure-mode/sh_properties_hide.lua" )
    include( "adventure-mode/cl_console_commands.lua" )
    include( "dnd-status-effects/sv_status_system.lua" )
    include( "adventure-mode/cl_start_sgins.lua" )
    include( "adventure-mode/cl_master_panel.lua" )
    include( "adventure-mode/cl_fpsfog.lua" )
end

-- local outlineMaterial = Material( "models/debug/debugwhite" )

-- --- Рисует обводку вокруг entity (игрок/NPC/проп/любой ent с моделью).
-- -- @param ent          Entity  — объект, которому нужна обводка
-- -- @param color        Color   — цвет обводки (необязательно, по умолчанию красный)
-- -- @param throughWalls boolean — true = обводка видна сквозь стены (wallhack-стиль),
-- --                                false/nil = обычная обводка с учётом depth-буфера
-- -- @param thickness    number  — толщина обводки, множитель масштаба (необязательно, по умолчанию 1.03)
-- function DrawEntityOutline( ent, color, throughWalls, thickness )
--     if not IsValid( ent ) then return end

--     if not ent.DrawModel then return end

--     color = color or Color( 255, 0, 0, 255 )
--     thickness = thickness or 1.03

--     local weapon = ent:IsPlayer() and ent:GetActiveWeapon() or nil
--     local hasWeapon = IsValid( weapon )
--     if hasWeapon then
--         weapon:SetNoDraw( true )
--     end

--     render.SuppressEngineLighting( true )
--     if throughWalls then
--         cam.IgnoreZ( true )
--     end

--     render.SetStencilEnable( true )
--     render.ClearStencil()
--     render.SetStencilWriteMask( 0xFF )
--     render.SetStencilTestMask( 0xFF )
--     render.SetStencilCompareFunction( STENCIL_ALWAYS )
--     render.SetStencilPassOperation( STENCIL_REPLACE )
--     render.SetStencilFailOperation( STENCIL_KEEP )
--     render.SetStencilZFailOperation( STENCIL_KEEP )
--     render.SetStencilReferenceValue( 1 )
--     ent:DrawModel()
--     render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
--     render.SetStencilPassOperation( STENCIL_KEEP )
--     render.SetStencilFailOperation( STENCIL_KEEP )
--     render.SetColorModulation( color.r / 255, color.g / 255, color.b / 255 )
--     render.SetBlend( (color.a or 255) / 255 )
--     render.MaterialOverride( outlineMaterial )
--     local scaleMatrix = Matrix()
--     scaleMatrix:Scale( Vector( thickness, thickness, thickness ) )
--     ent:EnableMatrix( "RenderMultiply", scaleMatrix )
--     ent:DrawModel()
--     ent:DisableMatrix( "RenderMultiply" )
--     render.MaterialOverride( nil )
--     render.SetBlend( 1 )
--     render.SetColorModulation( 1, 1, 1 )
--     render.SetStencilEnable( false )

--     if hasWeapon then
--         weapon:SetNoDraw( false )
--         weapon:DrawModel()
--     end

--     if throughWalls then
--         cam.IgnoreZ( false )
--     end

--     render.SuppressEngineLighting( false )
-- end

-- hook.Add( "PostDrawTranslucentRenderables", "ExampleOutlines", function()
--     for _, ply in ipairs( player.GetAll() ) do
--         if ply ~= LocalPlayer() then
--             --DrawEntityOutline( ply, Color( 0, 255, 0 ), true, 1.01 )
--         end
--     end

--     for _, ent in ipairs( props ) do
--         --DrawEntityOutline( ent, Color( 255, 0, 0 ), true, 1.05 )
--     end

--     props = {}
-- end )


-- local red = Color( 255, 0, 0 )

-- hook.Add( "PreDrawOutlines", "ExampleOutlines", function()
--     props = {}

--     for _, ent in ipairs( ents.GetAll() ) do
--         if IsValid( ent ) and ent:GetClass() == "prop_physics" then
--             if ent.CPPIGetOwner then
--                 local owner = ent:CPPIGetOwner()
--                 if owner == ply then
--                     table.insert( props, ent )
--                 end
--             elseif ent.Spawner == ply then
--                 table.insert( props, ent )

--             elseif ent:GetNWEntity( "Owner" ) == ply then
--                 table.insert( props, ent )
--             end

--         end
--     end

--     local _, plys = player.Iterator()
--     outline.Add( props, red, outline.outline_mode_both )
-- end )
