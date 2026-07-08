util.AddNetworkString("queue_teleport")

net.Receive("queue_teleport", function(len, ply)
    if not ply:IsListenServerHost() then return end
    local entIndex = net.ReadInt(32)
    local target = ents.GetByIndex(entIndex)

    if IsValid(target) and IsValid(ply) and target ~= ply then
        ply:SetMoveType(MOVETYPE_NOCLIP)
        ply:SetPos(target:GetPos() + Vector(0, 45, 0))
        ply:SetVelocity(Vector(0, 0, 0))
    end
end)
