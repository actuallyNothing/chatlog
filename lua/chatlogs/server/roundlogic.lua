-- Get a round and send it to the client
function Chatlog.SendTable(index, ply, oldTable)

    local plyperms = {
        readpresent = Chatlog:CanReadPresent(ply),
        readdead = Chatlog:CanReadDead(ply),
        readteam = Chatlog:CanReadTeam(ply)
    }

    local chatlogTable = {}
    local isOld = (oldTable ~= nil)

    if (not isOld) then

        -- Index 0: Current round
        -- Index -1: Last round from previous map
        if index == 0 then
            if plyperms.readpresent then
                chatlogTable = table.Copy(Chatlog.CurrentRound)
            else
                chatlogTable.Log = {
                    -- Unauthorized
                    [1] = {
                        playerNick = "",
                        role = "144",
                        teamChat = false,
                        text = "",
                        timestamp = "",
                        steamID = ""
                    }
                }
            end
        else
            chatlogTable = index == -1 and table.Copy(Chatlog.LastRoundPrevMap) or Chatlog.Rounds[index]
        end

    else

        chatlogTable = table.Copy(oldTable)
        Chatlog.OldRounds[oldTable.code] = chatlogTable

    end

    if (chatlogTable.Log == nil or table.IsEmpty(chatlogTable.Log)) then
        chatlogTable.Log = {
            -- Empty log / No round found
            [1] = {
                playerNick = "",
                role = "404",
                teamChat = false,
                text = "",
                timestamp = "",
                steamID = ""
            }
        }
    end

    for i = 1, #chatlogTable.Log do
        if chatlogTable.Log[i].role == "spectator" and not plyperms.readdead or chatlogTable.Log[i].teamChat and not plyperms.readteam then
            chatlogTable.Log[i].playerNick = ""
            chatlogTable.Log[i].role = "100"
            chatlogTable.Log[i].teamChat = ""
            chatlogTable.Log[i].text = ""
            chatlogTable.Log[i].timestamp = ""
            chatlogTable.Log[i].steamID = ""
        end
    end

    chatlogTable = util.Compress(util.TableToJSON(chatlogTable))

    local bytes = #chatlogTable

    net.Start("GetChatlogRound")
    net.WriteUInt(bytes, 32)
    net.WriteData(chatlogTable, bytes)
    net.WriteInt(index, 16)
    net.WriteBool(oldTable ~= nil)
    net.Send(ply)

end

net.Receive("AskChatlogRound", function(len, ply)
    local index
    index = net.ReadInt(16)

    Chatlog.SendTable(index, ply)
end)

net.Receive("AskOldChatlog", function(len, ply)

    local code
    code = net.ReadString():upper()

    if (#code ~= 6) then
        net.Start("SendOldChatlogResult")
        net.WriteUInt(2, 2)
        net.Send(ply)

        return
    end

    if (Chatlog.OldRounds[code]) then
        net.Start("SendOldChatlogResult")
        net.WriteUInt(3, 2)
        net.Send(ply)

        Chatlog.SendTable(-2, ply, Chatlog.OldRounds[code])
    else
        Chatlog.Query("SELECT * FROM chatlog_v2_oldlogs WHERE code = " .. SQLStr(code), function(success, data)

            if (not data or table.IsEmpty(data)) then
                net.Start("SendOldChatlogResult")
                net.WriteUInt(1, 2)
                net.Send(ply)

                return
            end

            local tosend = data[1]

            tosend.Log = util.JSONToTable(tosend.log)
            tosend.log = nil
            tosend.Players = util.JSONToTable(tosend.players)
            tosend.players = nil

            net.Start("SendOldChatlogResult")
            net.WriteUInt(3, 2)
            net.Send(ply)

            Chatlog.SendTable(-2, ply, tosend)
        end)
    end

end)

local function setValidCode()

    local code = Chatlog.randomCode()

    local q = string.format("SELECT * FROM chatlog_v2_oldlogs WHERE code = \'%s\'", code)

    Chatlog.Query(q, function(_, data)

        if (not data or table.IsEmpty(data)) then
            Chatlog.CurrentRound.code = code
            return
        end

        setValidCode()

    end)

end

-- Reset this timer every round start
-- Also, keep track of rounds through this hook 
hook.Add("TTTBeginRound", "ChatlogRoundStart", function()
    SetGlobalInt("ChatlogRoundNumber", GetGlobalInt("ChatlogRoundNumber") + 1)
    Chatlog.CurrentRound.Log = {}
    Chatlog.CurrentRound.Players = {}
    Chatlog.CurrentRound.unix = os.time()
    Chatlog.CurrentRound.curtime = CurTime()
    Chatlog.CurrentRound.map = game.GetMap()

    for k,v in pairs(player.GetAll()) do
        Chatlog.CurrentRound.Players[v:SteamID()] = {
            nick = v:Nick(),
            role = v:GetRole()
        }
    end

    setValidCode()
end)

-- On round end, insert the current round onto the previous rounds and clear it
hook.Add("TTTEndRound", "ChatlogRoundEnd", function()

    local roundNumber = GetGlobalInt("ChatlogRoundNumber") or 1

    local round = {
        Log = Chatlog.CurrentRound.Log,
        Players = Chatlog.CurrentRound.Players,
        unix = Chatlog.CurrentRound.unix,
        curtime = Chatlog.CurrentRound.curtime,
        map = game.GetMap(),
        code = Chatlog.CurrentRound.code
    }

    Chatlog.SaveOldLog(round, roundNumber)

    Chatlog.Rounds[roundNumber] = round
end)