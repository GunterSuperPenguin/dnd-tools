include( "shared.lua" )

local pl = LocalPlayer()

function ENT:Initialize()
    local mn, mx = self:GetModel() and self:GetModelBounds() or Vector( -16, -16, -16 ), Vector( 16, 16, 16 )
    self:SetRenderBounds( mn or Vector( -16, -16, -16 ), mx or Vector( 16, 16, 16 ) )
end

surface.CreateFont( "EntityNameFont", {
    font = "DermaDefault",
    size = 80,
    weight = 1000
} )

surface.CreateFont( "EntityHPFont", {
    font = "DermaDefault",
    size = 50,
    weight = 1000
} )

local ICON_CONFIG = {
    -- Обычные эффекты 
    { func = "GetDSE_blood",       icon = "blood-drop.png" },
    { func = "GetDSE_stunning",    icon = "unhealthy.png" },
    { func = "GetDSE_fire",        icon = "fire.png" },
    { func = "GetDSE_ice",         icon = "icicle.png" },
    { func = "GetDSE_electricity", icon = "electricity.png" },
    { func = "GetDSE_madness",     icon = "madness.png" },
    { func = "GetDSE_sleep",       icon = "sleep-plus.png" },
    { func = "GetDSE_toxic",       icon = "toxic.png" },
    { func = "GetDSE_acid",        icon = "acid.png" },
    { func = "GetDSE_fear",        icon = "fear.png" },
    { func = "GetDSE_shocked",     icon = "shocked.png" },

    -- Исключение: вес выводит пробел вместо значения
    { func = "GetDSE_weight",      icon = "weight.png",          staticValue = " " },

    -- Модификаторы статов с разными иконками для плюса и минуса
    { func = "GetDSE_attack",      iconPlus = "attack-plus.png", iconMinus = "attack-minus.png", showPlus = true },
    { func = "GetDSE_block",       iconPlus = "shield-plus.png", iconMinus = "shield-minus.png", showPlus = true },

    -- Модификаторы статов с одинаковыми иконками, но знаком "+"
    { func = "GetDSE_dodge",       icon = "dodge.png",           showPlus = true },
    { func = "GetDSE_counter",     icon = "counter-action.png",  showPlus = true },
    { func = "GetDSE_fists",       icon = "fists.png",           showPlus = true },
    { func = "GetDSE_crossbow",    icon = "crossbow.png",        showPlus = true },
    { func = "GetDSE_other",       icon = "other.png",           showPlus = true },
}

local function StatusIconDraw( self )
    local transpert = self:GetDSE_NameDisplay() and 0 or 255

    local pos = self:GetPos() + Vector( self:GetDSE_x_Position(), self:GetDSE_z_Position(), 90 + self:GetDSE_y_Position() )
    local eyeAngles = pl:EyeAngles()
    local angles = Angle( 0, eyeAngles.y - 90, 90 )

    local sizeScale = self:GetDSE_Size() or 1
    if sizeScale <= 0 then sizeScale = 1 end

    local activeIcons = {}

    for _, cfg in ipairs( ICON_CONFIG ) do
        local val = self[ cfg.func ]( self ) or 0
        if val > 0 then
            local iconPath = cfg.iconPlus or cfg.icon

            local displayValue = val
            if cfg.staticValue then
                displayValue = cfg.staticValue
            elseif cfg.showPlus then
                displayValue = "+" .. val
            end

            table.insert( activeIcons, { path = iconPath, value = displayValue } )

        elseif val < 0 then
            if cfg.iconMinus or cfg.showPlus then
                local iconPath = cfg.iconMinus or cfg.icon
                table.insert( activeIcons, { path = iconPath, value = val } )
            end
        end
    end

    local iconSize = 128
    local count = #activeIcons

    if count == 0 and transpert == 0 then return end

    cam.Start3D2D( pos, angles, 0.01 * sizeScale )
    if count > 0 then
        local maxPerRow = 10
        local padding = 5

        local totalRows = math.ceil( count / maxPerRow )
        local totalGridHeight = (totalRows * iconSize) + ((totalRows - 1) * padding)
        local currentY = -(totalGridHeight / 2) + (iconSize / 2)

        local iconIdx = 1

        for row = 1, totalRows do
            local iconsInRow = math.min( maxPerRow, count - (iconIdx - 1) )

            local rowWidth = (iconsInRow * iconSize) + ((iconsInRow - 1) * padding)
            local currentX = -(rowWidth / 2) + (iconSize / 2)
            for col = 1, iconsInRow do
                local data = activeIcons[ iconIdx ]
                if data then
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.SetMaterial( Material( data.path ) )
                    surface.DrawTexturedRectRotated( currentX, currentY, iconSize, iconSize, 0 )

                    draw.SimpleTextOutlined(
                        data.value,
                        "EntityNameFont",
                        currentX,
                        currentY,
                        Color( 255, 255, 255 ),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        3,
                        Color( 0, 0, 0 )
                    )
                end

                currentX = currentX + iconSize + padding
                iconIdx = iconIdx + 1
            end

            currentY = currentY + iconSize + padding
        end
    end

    local vecCol = self:GetDSE_TopColor()
    local textColor = Color( vecCol.x * 255, vecCol.y * 255, vecCol.z * 255, transpert )

    draw.SimpleText( self:GetDSE_EntityName(), "EntityNameFont", 0, 122, Color( 0, 0, 0, transpert ), TEXT_ALIGN_CENTER )
    draw.SimpleText( self:GetDSE_EntityName(), "EntityNameFont", -2, 120, textColor, TEXT_ALIGN_CENTER )

    if self:GetDSE_HPDisplay() ~= true then
        local curHP = self:GetDSE_CurrentHP()
        local maxHP = self:GetDSE_MaxHP()
        local rollDeath = 0

        if curHP <= 0 then
            rollDeath = math.floor( 10 + (math.abs( curHP ) / maxHP * 100) / 5 )
        end

        local hpText = curHP .. " | " .. maxHP .. " (≥" .. rollDeath .. ")"

        local hpColor = Color( 255, 255, 255, transpert )
        if curHP < 0 then
            hpColor = Color( 255, 50, 50, transpert )
        end

        draw.SimpleText( hpText, "EntityHPFont", 0, 185, Color( 0, 0, 0, transpert ), TEXT_ALIGN_CENTER )
        draw.SimpleText( hpText, "EntityHPFont", -2, 183, hpColor, TEXT_ALIGN_CENTER )
    end

    cam.End3D2D()
end



function ENT:Draw()
    StatusIconDraw( self )
    local wep = LocalPlayer():GetActiveWeapon()
    local col = self:GetDSE_TopColor()
    render.SetColorModulation( col.x, col.y, col.z )
    local hasParent = IsValid( self:GetParent() )
    if IsValid( wep ) then
        local class = wep:GetClass()
        if class == "gmod_tool" or class == "weapon_physgun" then
            self:DrawModel()
        end
    end
end
