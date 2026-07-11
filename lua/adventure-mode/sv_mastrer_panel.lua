
local pl = LocalPlayer()

if pl:IsListenServerHost() then
    pl:SetNWBool("m_bIsDNDMaster", false) -- server-side code
end
