AddCSLuaFile("chatlogs/shared/lang.lua")
AddCSLuaFile("chatlogs/shared/privileges.lua")
AddCSLuaFile("chatlogs/client/preferences.lua")
AddCSLuaFile("chatlogs/client/textpanel.lua")
AddCSLuaFile("chatlogs/client/settings.lua")
AddCSLuaFile("chatlogs/client/admin.lua")
AddCSLuaFile("chatlogs/client/menu.lua")
AddCSLuaFile("chatlogs/client/loadround.lua")
AddCSLuaFile("chatlogs/client/net.lua")
include("chatlogs/shared/privileges.lua")
include("chatlogs/server/roundnet.lua")
include("chatlogs/server/config.lua")
include("chatlogs/server/lastround.lua")

util.AddNetworkString("AskChatlogRound")
util.AddNetworkString("GetChatlogRound")
util.AddNetworkString("ChatlogRequestConfiguration")
util.AddNetworkString("ChatlogSendConfiguration")
util.AddNetworkString("ChatlogCommitConfiguration")
util.AddNetworkString("ChatlogNotify")
util.AddNetworkString("ChatlogManagerModified")
util.AddNetworkString("ChatlogUpdateManager")

Chatlog.Rounds = Chatlog.Rounds or {}
Chatlog.CurrentRound = Chatlog.CurrentRound or {}

Chatlog.roleStrings = {
    [0] = "innocent",
    [1] = "traitor",
    [2] = "detective"
}

Chatlog:ValidateConfiguration()

-- Format seconds into an easy to read timestamp
function Chatlog.FormatTime(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00"
    else
        mins = string.format("%02.f", math.floor(seconds / 60))
        secs = string.format("%02.f", math.floor(seconds - mins * 60))

        return mins .. ":" .. secs
    end
end

function Chatlog.Message(ply, text, teamChat)
    if GetRoundState() ~= ROUND_ACTIVE then return end

    playerNick = ply:Nick()
    timestamp = Chatlog.FormatTime(Chatlog.timerSeconds)
    steamID = ply:SteamID()
    role = Chatlog.roleStrings[ply:GetRole()]

    if ply:Team() == TEAM_SPECTATOR or ply:Alive() == false then
        role = "spectator"
        teamChat = false
    end

    if role == "innocent" then
        teamChat = false
    end

    -- Insert this line into the server's current round
    table.insert(Chatlog.CurrentRound, {
        playerNick = playerNick,
        text = text,
        teamChat = teamChat,
        role = role,
        timestamp = timestamp,
        steamID = steamID
    })
end

hook.Add("PlayerSay", "ChatlogMessage", Chatlog.Message)

hook.Add("InitPostEntity", "ChatlogServerInit", function()
    Chatlog:UpdateConfiguration(false)
end)
