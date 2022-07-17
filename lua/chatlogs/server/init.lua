Chatlog.Rounds = Chatlog.Rounds or {}
Chatlog.CurrentRound = Chatlog.CurrentRound or {}

Chatlog.roleStrings = {
    [0] = "innocent",
    [1] = "traitor",
    [2] = "detective"
}

AddCSLuaFile("chatlogs/shared/lang.lua")
AddCSLuaFile("chatlogs/shared/privileges.lua")
AddCSLuaFile("chatlogs/client/preferences.lua")
AddCSLuaFile("chatlogs/client/textpanel.lua")
AddCSLuaFile("chatlogs/client/settings.lua")
AddCSLuaFile("chatlogs/client/admin.lua")
AddCSLuaFile("chatlogs/client/filters.lua")
AddCSLuaFile("chatlogs/client/menu.lua")
AddCSLuaFile("chatlogs/client/loadround.lua")
AddCSLuaFile("chatlogs/client/net.lua")
include("chatlogs/server/config.lua")
include("chatlogs/shared/privileges.lua")
include("chatlogs/server/roundlogic.lua")
include("chatlogs/server/sqlite.lua")
include("chatlogs/server/db.lua")
include("chatlogs/server/lastround.lua")

util.AddNetworkString("ChatlogClientReady")
util.AddNetworkString("AskChatlogRound")
util.AddNetworkString("GetChatlogRound")
util.AddNetworkString("ChatlogRequestConfiguration")
util.AddNetworkString("ChatlogSendConfiguration")
util.AddNetworkString("ChatlogCommitConfiguration")
util.AddNetworkString("ChatlogSendLastMapData")

Chatlog:ValidateConfiguration()
Chatlog.CreateDBTables()

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

    local playerNick = ply:Nick()
    local timestamp = Chatlog.FormatTime(Chatlog.timerSeconds)
    local steamID = ply:SteamID()
    local role = (ply:Team() == TEAM_SPECTATOR or not ply:Alive()) and "spectator" or Chatlog.roleStrings[ply:GetRole()]

    if (role == "innocent" or role == "spectator") then
        teamChat = false
    end

    -- Insert this line into the server's current round
    table.insert(Chatlog.CurrentRound.Log, {
        text = text,
        teamChat = teamChat,
        timestamp = timestamp,
        steamID = steamID,
        role = role,
        unix = CurTime()
    })

    -- Save player
    if (not Chatlog.CurrentRound.Players[steamID]) then
        Chatlog.CurrentRound.Players[steamID] = {
            nick = playerNick
        }
    end
end

hook.Add("PlayerSay", "ChatlogMessage", Chatlog.Message)

hook.Add("InitPostEntity", "ChatlogServerInit", function()
    Chatlog:UpdateConfiguration(false)
    Chatlog.LastRoundPrevMapSetup()
end)

net.Receive("ChatlogClientReady", function(len, ply)
    Chatlog:SendConfiguration(ply)

    if (GetGlobalBool("ChatlogLastMapExists")) then
        local data = Chatlog.LastRoundPrevMap
        data.log = nil

        data = util.Compress(util.TableToJSON(Chatlog.LastRoundPrevMap))

        net.Start("ChatlogSendLastMapData")
        net.WriteUInt(#data, 16)
        net.WriteData(data)
        net.Send(ply)
    end
end)