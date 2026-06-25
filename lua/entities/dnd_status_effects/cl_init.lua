include( "shared.lua" )

function ENT:Initialize()
    self:SetRenderBounds( Vector( -1000, -1000, -1000 ), Vector ( 1000, 1000, 1000 ), Vector( 0, 0, 0 ) )
end

surface.CreateFont( "EntityNameFont", {
    font = "DermaDefault",
    size = 80,
    weight = 1000
})

surface.CreateFont( "EntityHPFont", {
    font = "DermaDefault",
    size = 50,
    weight = 1000
})

local function StatusIconDraw( self )
    local transpert = 255
    if self:GetDSE_NameDisplay() == true then
        transpert = 0
    end

    local pos = self:GetPos() + Vector( 0 + self:GetDSE_x_Position(), 0 + self:GetDSE_z_Position(), 90 + self:GetDSE_y_Position() )
    local eyeAngles = LocalPlayer():EyeAngles()
    local angles = Angle( 0, eyeAngles.y - 90, 90 )

    local sizeScale = self:GetDSE_Size() or 1
    if sizeScale <= 0 then sizeScale = 1 end

    local activeIcons = {}

    if self:GetDSE_blood() > 0 then
        table.insert( activeIcons, { path = "blood-drop.png", value = self:GetDSE_blood() } )
    end

    if self:GetDSE_stunning() > 0 then
        table.insert( activeIcons, { path = "unhealthy.png", value = self:GetDSE_stunning() } )
    end

    if self:GetDSE_fire() > 0 then
        table.insert( activeIcons, { path = "fire.png", value = self:GetDSE_fire() } )
    end

    if self:GetDSE_ice() > 0 then
        table.insert( activeIcons, { path = "icicle.png", value = self:GetDSE_ice() } )
    end

    if self:GetDSE_electricity() > 0 then
        table.insert( activeIcons, { path = "electricity.png", value = self:GetDSE_electricity() } )
    end

    if self:GetDSE_madness() > 0 then
        table.insert( activeIcons, { path = "madness.png", value = self:GetDSE_madness() } )
    end

    if self:GetDSE_sleep() > 0 then
        table.insert( activeIcons, { path = "sleep-plus.png", value = self:GetDSE_sleep() } )
    end

    if self:GetDSE_toxic() > 0 then
        table.insert( activeIcons, { path = "toxic.png", value = self:GetDSE_toxic() } )
    end

    if self:GetDSE_weight() > 0 then
        table.insert( activeIcons, { path = "weight.png", value = " " } )
    end

    if self:GetDSE_Attack() > 0 then
        table.insert( activeIcons, { path = "attack-plus.png", value = "+" .. self:GetDSE_Attack() } )
    elseif self:GetDSE_Attack() < 0 then
            table.insert( activeIcons, { path = "attack-minus.png", value = self:GetDSE_Attack() } )
    end

    if self:GetDSE_block() > 0 then
        table.insert( activeIcons, { path = "shield-plus.png", value = "+" .. self:GetDSE_block() } )
    elseif self:GetDSE_block() < 0 then
            table.insert( activeIcons, { path = "shield-minus.png", value = self:GetDSE_block() } )
    end

    if self:GetDSE_dodge() > 0 then
        table.insert( activeIcons, { path = "dodge.png", value = "+" .. self:GetDSE_dodge() } )
    elseif self:GetDSE_dodge() < 0 then
            table.insert( activeIcons, { path = "dodge.png", value = self:GetDSE_dodge() } )
    end

    if self:GetDSE_counter() > 0 then
        table.insert( activeIcons, { path = "counter-action.png", value = "+" .. self:GetDSE_counter() } )
    elseif self:GetDSE_counter() < 0 then
            table.insert( activeIcons, { path = "counter-action.png", value = self:GetDSE_counter() } )
    end

    if self:GetDSE_fists() > 0 then
        table.insert( activeIcons, { path = "fists.png", value = "+" .. self:GetDSE_fists() } )
    elseif self:GetDSE_fists() < 0 then
            table.insert( activeIcons, { path = "fists.png", value = self:GetDSE_fists() } )
    end

    if self:GetDSE_crossbow() > 0 then
        table.insert( activeIcons, { path = "crossbow.png", value = "+" .. self:GetDSE_crossbow() } )
    elseif self:GetDSE_crossbow() < 0 then
            table.insert( activeIcons, { path = "crossbow.png", value = self:GetDSE_crossbow() } )
    end

    if self:GetDSE_other() > 0 then
        table.insert( activeIcons, { path = "other.png", value = "+" .. self:GetDSE_other() } )
    elseif self:GetDSE_other() < 0 then
            table.insert( activeIcons, { path = "other.png", value = self:GetDSE_other() } )
    end

    local iconSize = 128
    local count = #activeIcons

    if count == 0 and transpert == 0 then return end

    cam.Start3D2D( pos, angles, 0.01 * sizeScale )
        if count > 0 then
            local maxPerRow = 10
            local padding = 5

            local totalRows = math.ceil( count / maxPerRow )
            local totalGridHeight = ( totalRows * iconSize ) + ( ( totalRows - 1 ) * padding )
            local currentY = -( totalGridHeight / 2 ) + ( iconSize / 2 )

            local iconIdx = 1

            for row = 1, totalRows do
                local iconsInRow = math.min( maxPerRow, count - ( iconIdx - 1 ) )

                local rowWidth = ( iconsInRow * iconSize ) + ( ( iconsInRow - 1 ) * padding )
                local currentX = -( rowWidth / 2 ) + ( iconSize / 2 )
                for col = 1, iconsInRow do
                    local data = activeIcons[iconIdx]
                    if data then
                        surface.SetDrawColor( 255, 255, 255, 255 )
                        surface.SetMaterial( Material( data.path ) )
                        surface.DrawTexturedRectRotated( currentX, currentY, iconSize, iconSize, 0 )

                        draw.SimpleTextOutlined(
                            data.value,
                            "EntityNameFont",
                            currentX,
                            currentY,
                            Color(255, 255, 255),
                            TEXT_ALIGN_CENTER,
                            TEXT_ALIGN_CENTER,
                            3,
                            Color(0, 0, 0)
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
                rollDeath = math.floor(10 + (math.abs(curHP) / maxHP * 100 ) / 5)
            end

            local hpText = curHP .. " | " .. maxHP .. " (≥" .. rollDeath .. ")"

            local hpColor = Color(255, 255, 255, transpert)
            if curHP < 0 then
                hpColor = Color(255, 50, 50, transpert)
            end

            draw.SimpleText( hpText, "EntityHPFont", 0, 185, Color( 0, 0, 0, transpert ), TEXT_ALIGN_CENTER )
            draw.SimpleText( hpText, "EntityHPFont", -2, 183, hpColor, TEXT_ALIGN_CENTER )
        end

    cam.End3D2D()
end

function ENT:Draw()
    StatusIconDraw( self )
    local col = self:GetDSE_TopColor()
    render.SetColorModulation( col.x, col.y, col.z )
    local hasParent = IsValid(self:GetParent())
    if LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" or LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun" then
        self:DrawModel()
    end
end