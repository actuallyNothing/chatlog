-- Chatlog data variables
local playerNick 
local text
local teamChat
local role
local timestamp

net.Receive("GetChatlogRound", function()
	roundtable = {}

	messages = net.ReadInt(16)
	for i=1, messages do
		roundtable[i] = {}
		roundtable[i].playerNick = net.ReadString()
		roundtable[i].role = net.ReadString()
		roundtable[i].teamChat = net.ReadBool()
		roundtable[i].text = net.ReadString()
		roundtable[i].timestamp = net.ReadString()
		roundtable[i].steamID = net.ReadString()
	end

	index = net.ReadInt(16)
	if index != 0 then
		Chatlog.Rounds[index] = roundtable
	end

	Chatlog:LoadRound(roundtable, Chatlog.chatLogList,Chatlog.textPanel,Chatlog.filteredPlayer,Chatlog.playerFilter)	
end)