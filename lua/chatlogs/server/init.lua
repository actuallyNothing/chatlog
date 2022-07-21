Chatlog.Rounds = Chatlog.Rounds or {}
Chatlog.OldRounds = {}
Chatlog.CurrentRound = Chatlog.CurrentRound or {}

AddCSLuaFile("chatlogs/shared/lang.lua")
AddCSLuaFile("chatlogs/shared/privileges.lua")
AddCSLuaFile("chatlogs/client/preferences.lua")
AddCSLuaFile("chatlogs/client/textpanel.lua")
AddCSLuaFile("chatlogs/client/settings.lua")
AddCSLuaFile("chatlogs/client/admin.lua")
AddCSLuaFile("chatlogs/client/filters.lua")
AddCSLuaFile("chatlogs/client/playerlist.lua")
AddCSLuaFile("chatlogs/client/oldlogs.lua")
AddCSLuaFile("chatlogs/client/menu.lua")
AddCSLuaFile("chatlogs/client/loadround.lua")
AddCSLuaFile("chatlogs/client/net.lua")
include("chatlogs/server/config.lua")
include("chatlogs/shared/privileges.lua")
include("chatlogs/server/roundlogic.lua")
include("chatlogs/server/mysql.lua")
include("chatlogs/server/sqlite.lua")
include("chatlogs/server/db.lua")
include("chatlogs/server/oldlogs.lua")
include("chatlogs/server/lastround.lua")

util.AddNetworkString("ChatlogClientReady")
util.AddNetworkString("AskChatlogRound")
util.AddNetworkString("GetChatlogRound")
util.AddNetworkString("ChatlogRequestConfiguration")
util.AddNetworkString("ChatlogSendConfiguration")
util.AddNetworkString("ChatlogGetMySQLConfiguration")
util.AddNetworkString("ChatlogSendMySQLConfiguration")
util.AddNetworkString("ChatlogCommitConfiguration")
util.AddNetworkString("ChatlogSendLastMapData")
util.AddNetworkString("AskOldChatlog")
util.AddNetworkString("SendOldChatlogResult")
util.AddNetworkString("AskChatlogDates")
util.AddNetworkString("SendChatlogDates")
util.AddNetworkString("AskOldChatlogRounds")
util.AddNetworkString("SendOldChatlogRounds")

Chatlog:ValidateConfiguration()
Chatlog.InitializeDB()

function Chatlog.RoleStringFromPlayer(ply)
    return (ply:Team() == TEAM_SPECTATOR or not ply:Alive()) and "spectator" or Chatlog.roleStrings[ply:GetRole()]
end

function Chatlog.Message(ply, text, teamChat, isRadio, radioTarget)
    if GetRoundState() ~= ROUND_ACTIVE then return end

    local steamID = ply:SteamID()
    local role = Chatlog.RoleStringFromPlayer(ply)

    if (role == "innocent" or role == "spectator") then
        teamChat = false
    end

    -- Insert this line into the server's current round
    local line = {
        steamID = steamID,
        role = role,
        curtime = CurTime(),
    }

    if (not isRadio) then
        line.text = text
        line.teamChat = teamChat
    else
        line.radio = true
        line.cmd = text
        line.teamChat = false

        if (not table.IsEmpty(radioTarget)) then
            line.target = {
                name = radioTarget.name,
                steamID = radioTarget.steamID
            }
        end
    end

    if (not Chatlog.CurrentRound.Players[steamID]) then
        Chatlog.CurrentRound.Players[steamID] = {
            nick = ply:Nick(),
            role = Chatlog.RoleStringFromPlayer(ply)
        }
    end

    table.insert(Chatlog.CurrentRound.Log, line)
end

function Chatlog.RadioMessage(ply, cmdName, cmdTarget)

    local target = {}

    if isstring(cmdTarget) then
        -- target.name = LANG.NameParam(cmdTarget)
        target.name = cmdTarget
        target.isTranslationString = true
    else
        if IsValid(cmdTarget) then
            if cmdTarget:IsPlayer() then
                target.name = cmdTarget:Nick()
                target.steamID = cmdTarget:SteamID()
            elseif cmdTarget:GetClass() == "prop_ragdoll" then
                -- target.name = LANG.NameParam("quick_corpse_id")
                    -- tab breaks JSON so we'll let the
                    -- client do the job of translating
                    -- this by themselves
                target.name = "quick_corpse_id"
                target.isTranslationString = true
                target.steamID = cmdTarget.sid
            end
        end
    end

    Chatlog.Message(ply, cmdName, nil, true, target)

end

hook.Add("PlayerSay", "ChatlogMessage", Chatlog.Message)
hook.Add("TTTPlayerRadioCommand", "ChatlogRadio", Chatlog.RadioMessage)

hook.Add("InitPostEntity", "ChatlogServerInit", function()
    Chatlog:UpdateConfiguration(false)
end)

net.Receive("ChatlogClientReady", function(len, ply)
    Chatlog:SendConfiguration(ply)

    if (GetGlobalBool("ChatlogLastMapExists")) then
        local data = Chatlog.LastRoundPrevMap

        data = util.Compress(util.TableToJSON(Chatlog.LastRoundPrevMap))

        net.Start("ChatlogSendLastMapData")
        net.WriteUInt(#data, 16)
        net.WriteData(data)
        net.Send(ply)
    end
end)