AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
    self:SetMaterial( "models/debug/debugwhite" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self:SetDSE_TopColor( Vector(1, 1, 1) )
    self:SetDSE_EntityName( "Доходяга" )
    self:SetDSE_MaxHP( 100 )
    self:SetDSE_CurrentHP( 100 )
    self:SetDSE_HPDisplay( true )
    self:SetDSE_Size( 10 )
    self:SetDSE_y_Position( 10 )
end