CreateClientConVar("chatlog_language", "english", FCVAR_ARCHIVE)
include("chatlogs/client/cl_preferences.lua")
include("chatlogs/config/config.lua")
include("chatlogs/shared/lang.lua")
include("chatlogs/shared/privileges.lua")
include("chatlogs/client/cl_roundnet.lua")
include("chatlogs/client/cl_textpanel.lua")
include("chatlogs/client/cl_settings.lua")
include("chatlogs/client/cl_menu.lua")

-- Language 
GetChatlogLanguage = GetConVar("chatlog_language"):GetString()

-- An integer to determine what round the client initialized at
-- used in a function below LoadRound()
Chatlog.RoundJoined = GetGlobalInt("Chatlog.RoundNumber", 0)

-- Initial round tables
Chatlog.CurrentRound = {} --A list that will hold all the information when player sends a message
Chatlog.Rounds = {}
Chatlog.Menu = {}

function Chatlog:LoadRound(round, loglist, textPanel, plyFilter, playerFilter)
	-- Clear the loglist and loop through each line
	local client = LocalPlayer()
	local playerList = {}
	loglist:Clear()

	if round[1] == 404 then
		-- Show an error message if neither the client or server were able to get the round
		loglist:AddLine('','',ChatlogTranslate(GetChatlogLanguage, "EmptyLog"))
		return false
	elseif !self.CanReadPresent() && round == self.CurrentRound then
		-- Show an error message if an unauthorized player tries to see the current round
		loglist:AddLine('','',ChatlogTranslate(GetChatlogLanguage, "Unauthorized"))
		return false
	end

	-- Loop through all messages
	for i = #round, 1, -1 do
	  v = round[i]

	  	-- Filtering and privileges
	 	if v['teamChat'] && !self.CanReadTeam() || !v['isAlive'] && !self.CanReadDead() then goto cont
	  	elseif plyFilter != nil && v['playerNick'] != plyFilter then goto cont
	  	elseif GetConVar("chatlog_hide_dead"):GetBool() && !v['isAlive'] || GetConVar("chatlog_hide_dead"):GetBool() && v['role'] == 'spectator' then goto cont end

	  	local lineMessage = v['text']
	  	local lineNick = v['playerNick']
	  	local lineRole = v['role']
	  	local lineTimestamp = v['timestamp']
	  	-- Only using this variable for full text display
	  	local lineAuthor = lineNick

	  	-- Author prefixes
	  	if v['teamChat'] then
	  		lineAuthor = "("..ChatlogTranslate(GetChatlogLanguage,lineRole)..") "..lineNick
	  	elseif !v['isAlive'] || v['role'] == 'spectator' then
	  		lineAuthor = "*"..ChatlogTranslate(GetChatlogLanguage,"dead").."* "..lineNick
	  	end

	  	-- Add every line according to privileges
	  	-- If the player shouldn't be allowed to see this line, scrap it
	  	local line
		line = loglist:AddLine(lineTimestamp, lineNick, lineMessage, chat_isAlive, chat_teamChat)

	  	-- Paint team and dead chat lines
	  	if v['teamChat'] == true then
	  		function line:PaintOver(w, h)
	  			draw.RoundedBox( 0, 0, 0, w, h, Chatlog.GetColor('highlight', lineRole))
	  		end
	  	elseif v['isAlive'] == false || lineRole == 'spectator' then
	  		function line:PaintOver(w, h)
	  			draw.RoundedBox( 0, 0, 0, w, h, Chatlog.GetColor('highlight', 'dead'))
	  		end
	  	end

	  	-- Right-click context menu
	  	line.OnRightClick = function()
			local contextMenu = DermaMenu()
			local contextOption = contextMenu:AddOption(ChatlogTranslate(GetChatlogLanguage, "ClipboardCopy"), function()
				local copy_output = "[" .. lineTimestamp .. "] " .. lineNick .. ": " .. lineMessage
				SetClipboardText(copy_output)
				chat.AddText( Color( 255, 255, 255 ), ChatlogTranslate(GetChatlogLanguage, "ClipboardCopied"))
			end)
			contextOption:SetIcon("icon16/comments_add.png")
			contextMenu:Open()
		end

		-- Set the 'selected message' text labels
		line.OnSelect = function()
			textPanel.author:SetText(lineAuthor..":")
			textPanel.timestamp:SetText("[" .. lineTimestamp .. "]")
			-- Color the author's name with their role (if they're alive)
			if !v['isAlive'] || lineRole == 'spectator' then
				textPanel.author:SetTextColor(Chatlog.GetColor('role', 'dead'))
			else
				textPanel.author:SetTextColor(Chatlog.GetColor('role', lineRole))
			end
			textPanel.fulltext:SetText(lineMessage)
			textPanel.author:SizeToContents()
		end

		-- Add player
		if playerList[lineNick] == nil then
			playerList[lineNick] = lineNick
		end

		-- Skip to next line
		::cont::
	end

	playerFilter:Clear()
	for _, v in pairs(playerList) do
		playerFilter:AddChoice(v, nil, false, "icon16/user.png")
	end
	playerFilter:AddChoice(ChatlogTranslate(GetChatlogLanguage, "PlayerFilterNone"), nil, true, "icon16/cancel.png")
	loglist:SortByColumn(1, false)
end

-- On round end, insert the current round onto the previous rounds and clear it
-- Allows you to take a quick look at the logs if the map's changing and you're in a rush
-- If the client joined in the middle of this round, it will be scrapped so it can ask for it later
-- this should fix issues with players having incomplete logs
hook.Add("TTTEndRound", "ChatlogRoundClear", function()
	local round = GetGlobalInt("ChatlogRoundNumber", 0)
	if round != Chatlog.RoundJoined then
		table.insert(Chatlog.Rounds, GetGlobalInt("ChatlogRoundNumber", 1), Chatlog.CurrentRound)
	end
	Chatlog.CurrentRound = {}
end)

Chatlog.pressedKey = false

function Chatlog:Think()
    if input.IsKeyDown(self.Key) and not self.pressedKey then
        self.pressedKey = true
        if not IsValid(self.Menu) then
            self:OpenMenu()
        else
        	self.Menu:Close()
        end
    elseif self.pressedKey and not input.IsKeyDown(self.Key) then
        self.pressedKey = false
    end
end

hook.Add("Think", "ThinkChatlog", function()
    Chatlog:Think()
end)