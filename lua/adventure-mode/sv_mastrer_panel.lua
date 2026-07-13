hook.Add("PlayerInitialSpawn", "SetDNDMasterForHost", function(pl)
    if pl:IsListenServerHost() then
        pl:SetNWBool("m_bIsDNDMaster", false)
    else
        pl:SetNWBool("m_bIsDNDMaster", false)
    end
end)
