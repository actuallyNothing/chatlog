-- Modify privileges in config/config.lua
-- these are some helper functions

-- Return a player's access level to the addon
function Chatlog:GetAccessLevel(ply)
	if ply:GetUserGroup() then
		return Chatlog.Privileges[ply:GetUserGroup()]
	else return 0 end
end

-- Return a boolean on whether the player should get team lines 
function Chatlog:CanReadTeam(ply)
	if ply:GetUserGroup() then
		return Chatlog.TeamChatAccess[ply:GetUserGroup()]
	else return false end
end

-- Return a boolean on whether the player should get dead lines
function Chatlog:CanReadDead(ply)
	return Chatlog:GetAccessLevel(ply) >= 2
end

-- Return a boolean on whether the player should be able to see the logs from an ongoing round
function Chatlog:CanReadPresent(ply)
	if Chatlog:GetAccessLevel(ply) == 4 || Chatlog:GetAccessLevel(ply) == 3 && ply:Alive() == false then
		return true
	end
end