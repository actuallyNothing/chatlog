-- Modify privileges in config/config.lua
-- these are some helper functions

-- Return a player's access level to the addon
function Chatlog:GetAccessLevel()
	if LocalPlayer():GetUserGroup() then
		return Chatlog.Privileges[LocalPlayer():GetUserGroup()]
	else return 0 end
end

-- Return a boolean on whether the player should get team lines 
function Chatlog:CanReadTeam()
	if LocalPlayer():GetUserGroup() then
		return Chatlog.TeamChatAccess[LocalPlayer():GetUserGroup()]
	else return false end
end

-- Return a boolean on whether the player should get dead lines
function Chatlog:CanReadDead()
	return Chatlog.GetAccessLevel(LocalPlayer()) >= 2
end

-- Return a boolean on whether the player should be able to see the logs from an ongoing round
function Chatlog:CanReadPresent()
	if Chatlog.GetAccessLevel(LocalPlayer()) == 4 || Chatlog.GetAccessLevel(LocalPlayer()) == 3 && LocalPlayer():Alive() == false then
		return true
	end
end