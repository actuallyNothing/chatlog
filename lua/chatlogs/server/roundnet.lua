-- Get a round and send it to the client
function Chatlog.SendTable(index, ply)
    local plyperms = {
        readpresent = Chatlog:CanReadPresent(ply),
        readdead = Chatlog:CanReadDead(ply),
        readteam = Chatlog:CanReadTeam(ply)
    }

    local chatlogTable = {}

    -- Index 0: Current round
    -- Index -1: Last round from previous map
    if index == 0 then
        if plyperms.readpresent then
            chatlogTable = Chatlog.CurrentRound
        else
            chatlogTable = {
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
    elseif index == -1 then
        chatlogTable = Chatlog.LastRoundPrevMap
    else
        chatlogTable = Chatlog.Rounds[index]
    end

    if not chatlogTable then
        chatlogTable = {
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

    net.Start("GetChatlogRound")
    net.WriteUInt(#chatlogTable, 16)

    for i = 1, #chatlogTable do
        if chatlogTable[i].role == "spectator" and not plyperms.readdead or chatlogTable[i].teamChat and not plyperms.readteam then
            -- Message is from a dead player and the recipient shouldn't get the line
            -- or message is a team message and the recipient shouldn't get the line
            net.WriteString("")
            net.WriteString("100")
            net.WriteBool("")
            net.WriteString("")
            net.WriteString("")
            net.WriteString("")
        else
            net.WriteString(chatlogTable[i].playerNick)
            net.WriteString(chatlogTable[i].role)
            net.WriteBool(chatlogTable[i].teamChat)
            net.WriteString(chatlogTable[i].text)
            net.WriteString(chatlogTable[i].timestamp)
            net.WriteString(chatlogTable[i].steamID)
        end
    end

    net.WriteInt(index, 16)
    net.Send(ply)
end

net.Receive("AskChatlogRound", function(len, ply)
    local index
    index = net.ReadInt(16)
    Chatlog.SendTable(index, ply)
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
    local roundnum = GetGlobalInt("ChatlogRoundNumber")

    if roundnum > 0 then
        table.insert(Chatlog.Rounds, roundnum, Chatlog.CurrentRound)
    end

    SetGlobalInt("ChatlogRoundNumber", GetGlobalInt("ChatlogRoundNumber") + 1)
    Chatlog.CurrentRound = {}
    -- Reset timer
    Chatlog:Timer()
end)

-- On round end, insert the current round onto the previous rounds and clear it
hook.Add("TTTEndRound", "ChatlogRoundEnd", function() end) -- Chatlog.SaveOldlog(Chatlog.Rounds[roundnum], roundnum)
