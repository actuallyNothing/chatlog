-- Privilege helper functions
local function getGroup(ply)
    local group = ply:GetUserGroup()

    if Chatlog.Config.privileges[group] ~= nil then
        return group
    else
        return "user"
    end
end

-- Return a boolean on whether the player should get team lines
function Chatlog:CanReadTeam(ply)
    local group = getGroup(ply)

    return Chatlog.Config.privileges[group]["can_read_team_messages"] or Chatlog.Config.privileges["user"]["can_read_team_messages"]
end

-- Return a boolean on whether the player should get dead lines
function Chatlog:CanReadDead(ply)
    local group = getGroup(ply)

    return Chatlog.Config.privileges[group]["can_read_dead_players"] or Chatlog.Config.privileges["user"]["can_read_dead_players"]
end

-- Return a boolean on whether the player should be able to see the logs from an ongoing round
function Chatlog:CanReadPresent(ply)
    local group = getGroup(ply)
    if Chatlog.Config.privileges[group]["can_read_current_round"] == true or Chatlog.Config.privileges[group]["can_read_current_round"] == "spec_only" and ply:Alive() == false then return true end
end