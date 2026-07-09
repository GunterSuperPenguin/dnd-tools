local ENTITY_CLASS = "dnd_status_effects"

local function GetAttachedStatusEntity(parent)
    if not IsValid(parent) then return nil end
    for _, child in pairs(parent:GetChildren()) do
        if child:GetClass() == ENTITY_CLASS then
            return child
        end
    end
    return nil
end

properties.Add("dnd_add_status_child", {
    MenuLabel = "Добавить статус эффекты",
    Order = 10000,
    MenuIcon = "icon16/heart_add.png",

    Filter = function(self, ent, pl)
        if not IsValid(ent) or ent:IsPlayer() then return false end
        if ent:GetClass() == ENTITY_CLASS then return false end
        if IsValid(GetAttachedStatusEntity(ent)) then return false end
        return gamemode.Call("CanProperty", pl, "dnd_add_status_child", ent)
    end,

    Action = function(self, ent)
        self:MsgStart()
        net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function(self, length, pl)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        if not gamemode.Call("CanProperty", pl, "dnd_add_status_child", ent) then return end

        local statusEnt = ents.Create(ENTITY_CLASS)
        if not IsValid(statusEnt) then return end
        statusEnt:SetPos(ent:GetPos())
        statusEnt:SetAngles(ent:GetAngles())
        statusEnt:Spawn()
        statusEnt:Activate()
        statusEnt:SetParent(ent)
        statusEnt:SetLocalPos(Vector(0, 0, 0))
        statusEnt:SetLocalAngles(Angle(0, 0, 0))
        statusEnt:SetSolid(SOLID_NONE)
        statusEnt:SetMoveType(MOVETYPE_NONE)
        statusEnt:SetNotSolid(true)

        statusEnt:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    end
})

properties.Add("dnd_edit_status_child", {
    MenuLabel = "Изменить статус эффекты...",
    Order = 10002,
    MenuIcon = "icon16/pencil.png",

    Filter = function(self, ent, pl)
        if not IsValid(ent) then return false end
        local statusEnt = GetAttachedStatusEntity(ent)
        if not IsValid(statusEnt) then return false end
        return gamemode.Call("CanProperty", pl, "dnd_edit_status_child", ent)
    end,

    Action = function(self, ent)
        local statusEnt = GetAttachedStatusEntity(ent)
        if IsValid(statusEnt) then
            local editProp = properties.List.editentity
            if editProp then
                editProp:Action(statusEnt)
            end
        end
    end
})

properties.Add("dnd_remove_status_child", {
    MenuLabel = "Убрать статус эффекты",
    Order = 10001,
    MenuIcon = "icon16/heart_delete.png",

    Filter = function(self, ent, pl)
        if not IsValid(ent) then return false end
        if not IsValid(GetAttachedStatusEntity(ent)) then return false end
        return gamemode.Call("CanProperty", pl, "dnd_remove_status_child", ent)
    end,

    Action = function(self, ent)
        self:MsgStart()
        net.WriteEntity(ent)
        self:MsgEnd()
    end,
    Receive = function(self, length, pl)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end

        local statusEnt = GetAttachedStatusEntity(ent)
        if IsValid(statusEnt) then
            statusEnt:Remove()
        end
    end
})
