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

-- Include network strings
util.AddNetworkString( "ChatlogData" )
util.AddNetworkString( "AskChatlogRound" )
util.AddNetworkString( "GetChatlogRound" )

-- Initial round tables
Chatlog.Rounds = {}
Chatlog.CurrentRound = {}

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

-- Process every message and send it to the client
-- Saving it into Chatlog.CurrentRound for later, too
function Chatlog.Message( ply, text, teamChat )
	
	-- Only run if a round is ongoing
	if GetRoundState() != ROUND_ACTIVE then return end

	playerNick = ply:Name()
	isAlive = ply:Alive()
	timestamp = Chatlog.FormatTime(timerSeconds)
	role = ''

	if ply:GetRole() == ROLE_TRAITOR then
		role = 'traitor'
	elseif ply:GetRole() == ROLE_DETECTIVE then
		role = 'detective'
	else
		role = 'innocent'
	end

	if ply:Team() == TEAM_SPECTATOR then
		role = 'spectator'
	end

	-- Innocents/spectators have no team chat, but the game still 
	-- registers messagemode2 as a team message for them 
	-- so... this negates that nonsense
	if role == 'innocent' && teamChat == true || role == 'spectator' && teamChat == true then
		teamChat = false
	end

	net.Start("ChatlogData")
	net.WriteString(playerNick)
	net.WriteString(text)
	net.WriteBool(teamChat)
	net.WriteString(role)
	net.WriteBool(isAlive)
	net.WriteString(timestamp)
	net.Broadcast()

	-- Insert this line into the server's current round, just in case
	table.insert(Chatlog.CurrentRound, {playerNick = playerNick, text = text, teamChat = teamChat, isAlive = isAlive, role = role, timestamp = timestamp})
end

hook.Add("PlayerSay", "ChatlogMessage", Chatlog.Message)