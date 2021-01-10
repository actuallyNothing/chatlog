-- Chatlog data variables
local playerNick 
local text
local teamChat
local role
local timestamp

-- Receive data for the current round
function Chatlog.Data()
	playerNick = net.ReadString()
	text = net.ReadString()
	teamChat = net.ReadBool()
	role = net.ReadString()
	timestamp = net.ReadString()
	table.insert(Chatlog.CurrentRound, {playerNick = playerNick, text = text, teamChat = teamChat, role = role, timestamp = timestamp})
end

net.Receive("ChatlogData", Chatlog.Data)

-- Receive a previous round from the server
function Chatlog:ReceiveRound(dlistview, textpanel, plyfilter,playerFilter)
	roundtable = {}
	net.Receive("GetChatlogRound", function()

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

		self:LoadRound(roundtable,dlistview,textpanel,plyfilter,playerFilter)
	end)
end