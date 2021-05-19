CreateClientConVar("chatlog_language", "en", FCVAR_ARCHIVE)
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

-- Initial tables
Chatlog.Rounds = {}
Chatlog.Menu = {}

function Chatlog:LoadRound(round, loglist, textPanel, plyFilter, playerFilter)
	-- Clear the loglist and loop through each line
	local client = LocalPlayer()
	local playerList = {}
	loglist:Clear()

	-- Handle error codes from the server
	-- 144: Unauthorized reading of current round logs
	-- 404: Empty logs / No round found
	if round[1] == nil || tonumber(round[1]['role']) == 404 then
		-- Show an error message if the round is empty or if it doesn't exist
		loglist:AddLine('00:00','Chatlog',Chatlog.Translate("EmptyLog"))
		return false
	elseif tonumber(round[1]['role']) == 144 then
		-- Show an error message if an unauthorized player tries to see the current round
		loglist:AddLine('00:00','Chatlog',Chatlog.Translate("CantReadPresent"))
		loglist:AddLine('00:00','Chatlog',Chatlog.Translate("NoFilterChosen"))
		return false
	end

	-- We're loading a round, so we shouldn't be
	-- seeing info from another one
	Chatlog.ClearTextPanel()

	-- Loop through all messages
	for i = #round, 1, -1 do
	  v = round[i]

	  	-- Filtering and privileges
	 	if v['teamChat'] && !self:CanReadTeam(client) || v['role'] == 'spectator' && !self:CanReadDead(client) then goto cont
	  	elseif plyFilter != nil && v['playerNick'] != plyFilter then goto cont
	  	elseif GetConVar("chatlog_hide_dead"):GetBool() && v['role'] == 'spectator' then goto cont end

	  	local lineMessage = v['text']
	  	local lineNick = v['playerNick']
	  	local lineRole = v['role']
	  	local lineTimestamp = v['timestamp']
	  	local lineSteamID = v['steamID']
	  	-- Only using this variable for full text display
	  	local lineAuthor = lineNick

	  	-- Author prefixes
	  	if v['teamChat'] || lineRole == 'spectator' then
	  		lineAuthor = string.format("(%s) %s", string.upper(Chatlog.Translate(lineRole)), lineNick)
	  	end

	  	-- Add every line according to privileges
	  	-- If the player shouldn't be allowed to see this line, scrap it
	  	local line
		line = loglist:AddLine(lineTimestamp, lineNick, lineMessage, chat_teamChat)

	  	-- Paint team and dead chat lines
	  	if v['teamChat'] == true || lineRole == 'spectator' then
	  		function line:PaintOver(w, h)
	  			draw.RoundedBox( 0, 0, 0, w, h, Chatlog.GetColor('highlight', lineRole))
	  		end
	  	end

	  	-- Right-click context menu
	  	line.OnRightClick = function()
			local contextMenu = DermaMenu()

			-- Copy message to clipboard
			-- example: [01:23] actuallyNothing: hello
			local contextOption = contextMenu:AddOption(Chatlog.Translate("ClipboardCopy"), function()
				SetClipboardText(string.format("[%s] %s: %s", lineTimestamp, lineNick, lineMessage))
				chat.AddText( Color( 255, 255, 255 ), Chatlog.Translate("ClipboardCopied"))
			end)
			contextOption:SetIcon("icon16/comment.png")

			-- Copy player's SteamID
			contextOption = contextMenu:AddOption(string.format(Chatlog.Translate("GetSteamID"), lineNick), function()
				SetClipboardText(lineSteamID)
				chat.AddText( Color( 255, 255, 255 ), string.format(Chatlog.Translate("CopiedSteamID"), lineNick, lineSteamID))
			end)
			contextOption:SetIcon("icon16/key.png")
			contextMenu:Open()
		end

		-- Set the 'selected message' text labels
		line.OnSelect = function()
			textPanel.author:SetText(string.format("%s:", lineAuthor))
			textPanel.timestamp:SetText(string.format("[%s]", lineTimestamp))
			-- Color the author's name with their role (if they're alive)
			textPanel.author:SetTextColor(Chatlog.GetColor('role', lineRole))
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
	
	-- Add players to player filter
	-- if a filter is already selected, only 'Remove Filter' option is available
	playerFilter:Clear()
	if not plyFilter then
		for _, v in pairs(playerList) do
			playerFilter:AddChoice(v, nil, false, "icon16/user.png")
		end
		playerFilter:AddChoice(Chatlog.Translate("PlayerFilterNone"), nil, true, "icon16/cancel.png")
	else
		playerFilter:AddChoice(Chatlog.Translate("PlayerFilterRemove"), nil, true, "icon16/cancel.png")
	end

	loglist:SortByColumn(1, false)

end

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

hook.Add("Think", "ThinkChatlog", function(version)
    Chatlog:Think()
end)

-- Check if there's a newer version on Github
-- if there is, alert the player

Chatlog.outdated = false

http.Fetch("https://raw.githubusercontent.com/actuallyNothing/chatlog/master/VERSION.md",
	function(version)
		local cur_version = string.Explode(".", Chatlog.Version)
        local tbl = string.Explode(".", version)

        for i = 1, 3 do
            tbl[i] = tonumber(tbl[i])
            cur_version[i] = tonumber(cur_version[i])
        end

        if tbl[1] > cur_version[1] then
            Chatlog.outdated = true
        elseif tbl[1] == cur_version[1] and tbl[2] > cur_version[2] then
            Chatlog.outdated = true
        elseif tbl[1] == cur_version[1] and tbl[2] == cur_version[2] and tbl[3] > cur_version[3] then
            Chatlog.outdated = true
        end

	end)
