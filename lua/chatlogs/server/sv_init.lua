AddCSLuaFile("chatlogs/shared/lang.lua")
AddCSLuaFile("chatlogs/config/config.lua")
AddCSLuaFile("chatlogs/shared/privileges.lua")
AddCSLuaFile("chatlogs/client/cl_preferences.lua")
AddCSLuaFile("chatlogs/client/cl_textpanel.lua")
AddCSLuaFile("chatlogs/client/cl_settings.lua")
AddCSLuaFile("chatlogs/client/cl_menu.lua")
AddCSLuaFile("chatlogs/client/cl_roundnet.lua")
include("chatlogs/shared/privileges.lua")
include("chatlogs/server/sv_roundnet.lua")
include("chatlogs/config/config.lua")
include("chatlogs/server/sv_lastround.lua")

-- Include network strings 
util.AddNetworkString( "ChatlogData" )
util.AddNetworkString( "AskChatlogRound" )
util.AddNetworkString( "GetChatlogRound" )

-- Initial round tables
Chatlog.Rounds = {}
Chatlog.CurrentRound = {}

Chatlog.roleStrings = {
	[0] = "innocent",
	[1] = "traitor",
	[2] = "detective"
}

-- Format seconds into an easy to read timestamp
function Chatlog.FormatTime(seconds)
  local seconds = tonumber(seconds)
  if seconds <= 0 then
    return "00:00";
  else
    mins = string.format("%02.f", math.floor(seconds/60));
    secs = string.format("%02.f", math.floor(seconds - mins *60));
    return mins..":"..secs
  end
end

-- Process every message and save it for the server
-- Saving it into Chatlog.CurrentRound for later, too
function Chatlog.Message( ply, text, teamChat )
	
	-- Only run if a round is ongoing
	if GetRoundState() != ROUND_ACTIVE then return end

	playerNick = ply:Name()
	timestamp = Chatlog.FormatTime(timerSeconds)
	steamID = ply:SteamID()
	role = Chatlog.roleStrings[ply:GetRole()]

	if ply:Team() == TEAM_SPECTATOR || ply:Alive() == false then
		role = 'spectator'
		teamChat = false
	end

	if role == 'innocent' then teamChat = false	end

	-- Insert this line into the server's current round
	table.insert(Chatlog.CurrentRound, {playerNick = playerNick, text = text, teamChat = teamChat, role = role, timestamp = timestamp, steamID = steamID})
end

hook.Add("PlayerSay", "ChatlogMessage", Chatlog.Message)