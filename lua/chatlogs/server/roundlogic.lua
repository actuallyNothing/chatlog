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
        Chatlog.OldLogs[oldTable.code] = chatlogTable

    end

    if (not isOld and (chatlogTable.Log == nil or table.IsEmpty(chatlogTable.Log))) then
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

    local tosend

    if (Chatlog.OldLogs[code]) then
        tosend = Chatlog.OldLogs[code]
    else
        tosend = Chatlog.Query("SELECT * FROM chatlog_v2_oldlogs WHERE code = \'" .. code .. "\'")

        if (not tosend) then
            net.Start("SendOldChatlogResult")
            net.WriteUInt(1, 2)
            net.Send(ply)

            return
        end

        tosend = tosend[1]

        tosend.Log = util.JSONToTable(tosend.log)
        tosend.log = nil
        tosend.Players = util.JSONToTable(tosend.players)
        tosend.players = nil
    end


    net.Start("SendOldChatlogResult")
    net.WriteUInt(3, 2)
    net.Send(ply)

    Chatlog.SendTable(-2, ply, tosend)
end)

-- Manage the timer used for timestamping messages
function Chatlog:Timer()
    self.timerSeconds = 0

    if timer.Exists("chatlogTimer") then
        timer.Remove("chatlogTimer")
    end

    timer.Create("chatlogTimer", 1, 0, function()
        self.timerSeconds = self.timerSeconds + 1
    end)
end

-- Reset this timer every round start
-- Also, keep track of rounds through this hook 
hook.Add("TTTBeginRound", "ChatlogRoundStart", function()
    SetGlobalInt("ChatlogRoundNumber", GetGlobalInt("ChatlogRoundNumber") + 1)
    Chatlog.CurrentRound.Log = {}
    Chatlog.CurrentRound.Players = {}
    Chatlog.CurrentRound.unix = os.time()
    Chatlog.CurrentRound.map = game.GetMap()

    local code
    repeat
        code = Chatlog.randomCode()
    until (not Chatlog.codeExists(code))

    Chatlog.CurrentRound.code = code

    Chatlog:Timer()
end)

-- On round end, insert the current round onto the previous rounds and clear it
hook.Add("TTTEndRound", "ChatlogRoundEnd", function()

    local roundNumber = GetGlobalInt("ChatlogRoundNumber") or 1

    local round = {
        Log = Chatlog.CurrentRound.Log,
        Players = Chatlog.CurrentRound.Players,
        unix = Chatlog.CurrentRound.unix,
        map = game.GetMap(),
        code = Chatlog.CurrentRound.code
    }

    Chatlog.SaveOldLog(round, roundNumber)

    Chatlog.Rounds[roundNumber] = round
end)