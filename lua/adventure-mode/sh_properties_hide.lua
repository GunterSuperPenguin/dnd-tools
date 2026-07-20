if SERVER then
    CreateConVar( "dndt_adventuremode", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
        "Включение (1) или отключение (0) режима приключений для игроков.", 0, 1 )
end

local adventure_mode = GetConVar( "dndt_adventuremode" )

local properties_to_hide = {
    -- "collision_off",
    -- "collision_on",
    "bodygroups",
    "bone_manipulate",
    "bone_manipulate_end",
    "drive",
    -- "gravity",
    "ignite",
    "extinguish",
    "keepupright",
    "keepupright_stop",
    "motioncontrol_ragdoll",
    "npc_bigger",
    "npc_smaller",
    "persist",
    "persist_end",
    "remove",
    "skin",
    "statue",
    "statue_stop"
}

hook.Add( "InitPostEntity", "DNDT_ModifyMultipleProperties", function()
    if not adventure_mode then
        adventure_mode = GetConVar( "dndt_adventuremode" )
    end

    for _, prop_name in ipairs( properties_to_hide ) do
        local prop = properties.List[ prop_name ]

        if prop then
            local original_filter = prop.Filter

            prop.Filter = function( self, ent, ply )
                if not IsValid( ply ) then return false end

                if adventure_mode and adventure_mode:GetInt() == 1 then
                    return false
                end

                if original_filter then
                    return original_filter( self, ent, ply )
                else
                    return true
                end
            end
        end
    end
end )
