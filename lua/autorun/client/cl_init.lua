local render = render
local cam = cam
local surface = surface
local hook = hook
local Material = Material

---@class zi.outline
outline = {}

---@alias zi.outline.Mode
---| 0 # Both visible and hidden
---| 1 # Only hidden behind geometry
---| 2 # Only visible

local OUTLINE_MODE_BOTH = 0
local OUTLINE_MODE_NOTVISIBLE = 1
local OUTLINE_MODE_VISIBLE = 2

---@type integer
outline.outline_mode_both = OUTLINE_MODE_BOTH

---@type integer
outline.outline_mode_notvisible = OUTLINE_MODE_NOTVISIBLE

---@type integer
outline.outline_mode_visible = OUTLINE_MODE_VISIBLE

local List, ListSize = {}, 0

---@type Entity
local RenderEnt = NULL

local outlineMatSettings = {
    [ "$ignorez" ] = 1,
    [ "$alphatest" ] = 1,
}

local copyMat = Material( "pp/copy" )
local outlineMat = CreateMaterial( "OutlineMat", "UnlitGeneric", outlineMatSettings )
local storeTexture = render.GetScreenEffectTexture( 0 )
local drawTexture = render.GetScreenEffectTexture( 1 )

local ENTS = 1
local COLOR = 2
local MODE = 3

--- [ CLIENT ]
--- Adds entities to the outline render queue.
---
---@param listent Entity|Entity[] Entity or list of entities.
---@param color Color Outline color.
---@param mode? zi.outline.Mode Outline rendering mode.
function outline.Add( listent, color, mode )
    -- Maximum 255 reference values
    if ListSize >= 255 then
        return
    end

    -- Support for passing Entity as first argument
    if not istable( listent ) then
        listent = { listent }
    end

    -- Do not pass empty tables
    if listent[ 1 ] == nil then
        return
    end

    local t = {
        [ ENTS ] = listent,
        [ COLOR ] = color,
        [ MODE ] = mode or OUTLINE_MODE_BOTH,
    }

    ListSize = ListSize + 1
    List[ ListSize ] = t
end

--- [ CLIENT ]
--- Returns the last entity rendered by the outline system.
---
---@return Entity
function outline.RenderedEntity()
    return RenderEnt
end

local function Render()
    local client = LocalPlayer()
    local IsLineOfSightClear = client.IsLineOfSightClear
    local scene = render.GetRenderTarget()

    render.CopyRenderTargetToTexture( storeTexture )

    local w = ScrW()
    local h = ScrH()

    render.Clear( 0, 0, 0, 0, true, true )

    -- start stencil modification
    render.SetStencilEnable( true )

    cam.IgnoreZ( true )

    render.SuppressEngineLighting( true )

    render.SetStencilWriteMask( 0xFF )
    render.SetStencilTestMask( 0xFF )

    render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_REPLACE )
    render.SetStencilPassOperation( STENCIL_REPLACE )

    -- start cam modification
    cam.Start3D()

    for i = 1, ListSize do
        local v = List[ i ]
        local mode = v[ MODE ]
        local listent = v[ ENTS ]

        render.SetStencilReferenceValue( i )

        for j = 1, #listent do
            local ent = listent[ j ]

            if not (not IsValid( ent ) or mode == OUTLINE_MODE_NOTVISIBLE and IsLineOfSightClear( client, ent ) or mode == OUTLINE_MODE_VISIBLE and not IsLineOfSightClear( client, ent )) then
                RenderEnt = ent
                ent:DrawModel()
            end
        end
    end

    RenderEnt = NULL

    cam.End3D()
    -- end cam modification

    render.SetStencilCompareFunction( STENCIL_EQUAL )

    -- start cam modification
    cam.Start2D()

    for i = 1, ListSize do
        render.SetStencilReferenceValue( i )

        surface.SetDrawColor( List[ i ][ COLOR ] )
        surface.DrawRect( 0, 0, w, h )
    end

    cam.End2D()
    -- end cam modification

    render.SuppressEngineLighting( false )

    cam.IgnoreZ( false )

    render.SetStencilEnable( false )
    -- end stencil modification

    render.CopyRenderTargetToTexture( drawTexture )

    render.SetRenderTarget( scene )

    copyMat:SetTexture( "$basetexture", storeTexture )

    render.SetMaterial( copyMat )
    render.DrawScreenQuad()

    -- start stencil modification
    render.SetStencilEnable( true )

    render.SetStencilReferenceValue( 0 )
    render.SetStencilCompareFunction( STENCIL_EQUAL )

    outlineMat:SetTexture( "$basetexture", drawTexture )

    render.SetMaterial( outlineMat )

    render.DrawScreenQuadEx( -1, -1, w, h )
    render.DrawScreenQuadEx( -1, 0, w, h )
    render.DrawScreenQuadEx( -1, 1, w, h )
    render.DrawScreenQuadEx( 0, -1, w, h )
    render.DrawScreenQuadEx( 0, 1, w, h )
    render.DrawScreenQuadEx( 1, -1, w, h )
    render.DrawScreenQuadEx( 1, 0, w, h )
    render.DrawScreenQuadEx( 1, 1, w, h )

    render.SetStencilEnable( false )
    -- end stencil modification
end

hook.Add( "PostDrawEffects", "RenderOutlines", function()
    ---Called before all queued outlines are rendered.
    ---Use this hook to add entities via `outline.Add`.
    hook.Run( "PreDrawOutlines" )

    if ListSize == 0 then
        return
    end

    Render()

    List, ListSize = {}, 0
end )

return outline
