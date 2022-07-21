-- Privilege helper functions
local function getGroup(ply)
    if (CLIENT) then ply = LocalPlayer() end
    local group = ply:GetUserGroup()

    if Chatlog.Config.privileges[group] ~= nil then
        return group
    else
        return "user"
    end
end

-- Return a boolean on whether the player should get team lines
function Chatlog:CanReadTeam(ply)
    if (CLIENT) then ply = LocalPlayer() end
    local group = getGroup(ply)

    return Chatlog.Config.privileges[group]["can_read_team_messages"]
end

-- Return a boolean on whether the player should get dead lines
function Chatlog:CanReadDead(ply)
    if (CLIENT) then ply = LocalPlayer() end
    local group = getGroup(ply)

    return Chatlog.Config.privileges[group]["can_read_dead_players"]
end

-- Return a boolean on whether the player should be able to see the logs from an ongoing round
function Chatlog:CanReadPresent(ply)
    if (CLIENT) then ply = LocalPlayer() end
    local group = getGroup(ply)
    if Chatlog.Config.privileges[group]["can_read_current_round"] == true or Chatlog.Config.privileges[group]["can_read_current_round"] == "spec_only" and ply:Alive() == false then return true end
end

-- Return a boolean on whether the player should be able to search old logs by date
function Chatlog:CanSearchByDate(ply)
    if (CLIENT) then ply = LocalPlayer() end
    local group = getGroup(ply)
    return Chatlog.Config.privileges[group]["can_search_old_logs_by_date"]
end