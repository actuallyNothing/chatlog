function Chatlog:OpenMenu()
	local client = LocalPlayer()
	-- Don't open the menu if the player is not allowed to
	if Chatlog:GetAccessLevel(client) <= 0 then 
		chat.AddText( Color( 255, 0, 0 ), ChatlogTranslate(GetChatlogLanguage, "Unauthorized"))
		return
	end

	local setting
	local filteredPlayer

	-- Create the frame
	self.Menu = vgui.Create("DFrame")
	self.Menu:SetSize(600, 400)
	self.Menu:SetTitle("Chatlogs | " .. os.date("%a %x", os.time()))
	self.Menu:MakePopup()
	self.Menu:Center()
	self.Menu:SetKeyboardInputEnabled(false)
	
	-- DPropertySheet for tabs
	local tabs = vgui.Create( "DPropertySheet", self.Menu )
	tabs:SetPos( 5, 30 )
	tabs:SetSize( self.Menu:GetWide() - 10, self.Menu:GetTall() - 35 )

	-- Main Chatlog tab
	local chatlogTab = vgui.Create("DPanel", tabs)
	chatlogTab:SetSize(tabs:GetWide() - 10, tabs:GetTall() - 50) 
	chatlogTab:SetPos(5, 90)

	local chatLoglist = vgui.Create("DListView", chatlogTab)
	chatLoglist:SetSize(chatlogTab:GetWide() - 15, chatlogTab:GetTall() - 125) 
	chatLoglist:SetPos(5, 120)
	chatLoglist:SetSortable(false)

	local column = chatLoglist:AddColumn( ChatlogTranslate(GetChatlogLanguage, "Time") )
	column:SetFixedWidth(40)
	column = chatLoglist:AddColumn( ChatlogTranslate(GetChatlogLanguage, "Player") )
	column:SetFixedWidth(80)
	column = chatLoglist:AddColumn( ChatlogTranslate(GetChatlogLanguage, "Message") )
	column:SetFixedWidth(chatLoglist:GetWide() - 110)

	-- "Selected message" panel
	local textPanel = {}
	self.DrawTextPanel(textPanel, chatlogTab)

	-- Filter-by-round DComboBox
	setting = vgui.Create("DLabel", chatlogTab)
	setting:SetPos(10,0)
	setting:SetColor(Color(0,0,0))
	setting:SetText(ChatlogTranslate(GetChatlogLanguage, "RoundFilter"))
	setting:SetSize(125, 20)

	local roundFilter = vgui.Create("DComboBox", chatlogTab)
	roundFilter:SetSize((chatlogTab:GetWide() - 20) / 2, 20)
	roundFilter:SetPos(5, 20)
	roundFilter:SetText(ChatlogTranslate(GetChatlogLanguage, "RoundSelect"))
	for i = 1, GetConVar("ttt_round_limit"):GetInt() - GetGlobalInt("ttt_rounds_left") do
		roundFilter:AddChoice(ChatlogTranslate(GetChatlogLanguage, "Round") .. i, nil, false, "icon16/page.png")
	end
	roundFilter:SetSortItems(false)

	-- ghosting rates drop to 0%
	if Chatlog:CanReadPresent() then
		roundFilter:AddChoice(ChatlogTranslate(GetChatlogLanguage, "RoundSelectCurrent"), nil, false, "icon16/page_lightning.png")
	end

	-- Player filter DComboBox
	setting = vgui.Create("DLabel", chatlogTab)
	setting:SetPos(295,0)
	setting:SetColor(Color(0,0,0))
	setting:SetText(ChatlogTranslate(GetChatlogLanguage, "PlayerFilter"))
	setting:SetSize(125, 20)

	local playerFilter = vgui.Create("DComboBox", chatlogTab)
	playerFilter:SetSize((chatlogTab:GetWide() - 20) / 2, 20)
	playerFilter:SetPos(290,20)
	playerFilter:AddChoice(ChatlogTranslate(GetChatlogLanguage, "PlayerFilterNone"), nil, true, "icon16/cancel.png")

	-- for k,v in pairs(player.GetHumans()) do
	-- 	playerFilter:AddChoice(v:Nick(), nil, false, "icon16/user.png")
	-- end

	function playerFilter:OnSelect(index, text)
		if text != ChatlogTranslate(GetChatlogLanguage, "PlayerFilterNone") then
			filteredPlayer = text
		else
			filteredPlayer = nil
		end
	end

	-- Add a "hide dead" checkbox if the player has the privilege to
	if Chatlog:CanReadDead() then
		local deathCheck = vgui.Create("DCheckBoxLabel", chatlogTab)
		deathCheck:SetConVar("chatlog_hide_dead")
		deathCheck:SetText(ChatlogTranslate(GetChatlogLanguage, "DeadFilter"))
		deathCheck:SetTextColor(Color(0,0,0))
		deathCheck:SetPos(290,45)
		deathCheck:SizeToContents()
	end

	-- Refresh button for filters and current round
	local refreshButton = vgui.Create("DButton", chatlogTab)
	refreshButton:SetText(ChatlogTranslate(GetChatlogLanguage, "Refresh"))
	refreshButton:SetPos(230,2)
	refreshButton:SetSize(50,16)
	refreshButton.DoClick = function()
		if roundFilter:GetSelected() then
			roundFilter:ChooseOption(roundFilter:GetSelected(), roundFilter:GetSelectedID())
		else 
			roundFilter:ChooseOption(ChatlogTranslate(GetChatlogLanguage, "RoundSelectCurrent"))
		end
	end

	-- Manage round selection
	function roundFilter:OnSelect(index, text)
		if text != ChatlogTranslate(GetChatlogLanguage, "RoundSelectCurrent") then
			-- Load the round from the client if possible
			if Chatlog.Rounds[index] then
				Chatlog:LoadRound(Chatlog.Rounds[index], chatLoglist, textPanel, filteredPlayer, playerFilter)
			else
			-- If the client doesn't have it, ask the server
				net.Start("AskChatlogRound")
				net.WriteInt(index, 4)
				net.SendToServer()
				Chatlog:ReceiveRound(chatLoglist, textPanel, filteredPlayer, playerFilter)
			end
		else
			-- Load current round from the client
			Chatlog:LoadRound(Chatlog.CurrentRound, chatLoglist, textPanel, filteredPlayer, playerFilter)
		end
	end

	-- Add to the DPropertySheet
	tabs:AddSheet(ChatlogTranslate(GetChatlogLanguage,"ChatTab"), chatlogTab, false, false )
	self.DrawSettings(tabs)
end

concommand.Add("chatlog", Chatlog.OpenMenu)