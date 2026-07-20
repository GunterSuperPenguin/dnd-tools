util.AddNetworkString( "queue_teleport" )

net.Receive( "queue_teleport", function( len, pl )
    if not pl:IsListenServerHost() then return end

    local entIndex = net.ReadInt( 32 )
    local target = ents.GetByIndex( entIndex )

    if IsValid( target ) and IsValid( pl ) and target ~= pl then
        pl:SetMoveType( MOVETYPE_NOCLIP )
        pl:SetPos( target:GetPos() + Vector( 0, 45, 0 ) )
        pl:SetVelocity( Vector( 0, 0, 0 ) )
    end
end )
