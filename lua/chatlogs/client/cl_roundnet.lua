-- Chatlog data variables
local playerNick 
local text
local teamChat
local role
local timestamp

-- Receive a round from the server
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
