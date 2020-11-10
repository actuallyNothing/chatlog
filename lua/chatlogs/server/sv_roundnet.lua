-- Allow the client to ask the server for a previous round if it doesn't have it
-- Get a round number and send it to the client
function Chatlog.SendTable(index, ply)
	local chatlogTable = {}
	if Chatlog.Rounds[index] == nil then
		chatlogTable[1] = 404
	else
		chatlogTable = Chatlog.Rounds[index]
	end
	net.Start("GetChatlogRound")
	net.WriteTable(chatlogTable)
	net.WriteInt(index, 4)
	net.Send(ply)
end

net.Receive("AskChatlogRound", function(len, ply)
	local index
	index = net.ReadInt(4)
	Chatlog.SendTable(index, ply)
end)

-- Manage the timer used for timestamping messages
function Chatlog.Timer()
	timer.Create("chatlogTimer", 1, 0, function()
		timerSeconds = timerSeconds + 1
	end)
end

-- Reset this timer every round start
-- Also, keep track of rounds through this hook 
hook.Add("TTTBeginRound", "ChatlogRoundStart", function()
	timerSeconds = 0
	if not timer.Exists("chatlogTimer") then
		Chatlog.Timer()
	else
		timer.Remove("chatlogTimer")
		Chatlog.Timer()
	end

	SetGlobalInt("ChatlogRoundNumber", (GetGlobalInt("ChatlogRoundNumber") + 1))
end)

-- On round end, insert the current round onto the previous rounds and clear it
hook.Add("TTTEndRound", "ChatlogRoundEnd", function()
	table.insert(Chatlog.Rounds, GetGlobalInt("ChatlogRoundNumber", 1), Chatlog.CurrentRound)
	Chatlog.CurrentRound = {}
end)