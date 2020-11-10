-- Chatlog data variables
local playerNick 
local text
local teamChat
local role
local isAlive
local timestamp

-- Receive data for the current round
function Chatlog.Data()
	playerNick = net.ReadString()
	text = net.ReadString()
	teamChat = net.ReadBool()
	role = net.ReadString()
	isAlive = net.ReadBool()
	timestamp = net.ReadString()
	table.insert(Chatlog.CurrentRound, {playerNick = playerNick, text = text, teamChat = teamChat, isAlive = isAlive, role = role, timestamp = timestamp})
end

net.Receive("ChatlogData", Chatlog.Data)

-- Receive a previous round from the server
function Chatlog:ReceiveRound(dlistview, textpanel, plyfilter,playerFilter)
	local roundtable
	local index
	net.Receive("GetChatlogRound", function()
		roundtable = net.ReadTable()
		index = net.ReadInt(4)
		Chatlog.Rounds[index] = roundtable
		self:LoadRound(roundtable,dlistview,textpanel,plyfilter,playerFilter)
	end)
end