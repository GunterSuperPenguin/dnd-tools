local plycol = CreateConVar("dndt_playercollision", "1", FCVAR_ARCHIVE,
    "Включение (1) или отключение (0) коллизии между игроками.", 0, 1)

---@param pl Player
---@param state boolean
local function update_player_collision(pl, state)
    pl:SetNoCollideWithTeammates(not state)
    pl:SetAvoidPlayers(state)
end

local function update_player_collision_all(state)
    for _, pl in player.Iterator() do
        update_player_collision(pl, state)
    end
end

cvars.AddChangeCallback("dndt_playercollision", function(_, _, val)
    update_player_collision_all(tonumber(val) == 1)
end, "Fuck Garry")

hook.Add("PlayerSpawn", "Fuck Garry", function(pl)
    pl:SetNoCollideWithTeammates(plycol:GetBool())
end)
