function Chatlog:OpenMenu()
	client = client
	-- Don't open the menu if the player is not allowed to
	if Chatlog:GetAccessLevel(client) <= 0 then 
		chat.AddText( Color( 255, 0, 0 ), Chatlog.Translate("Unauthorized"))
		return
	end

	local setting
	local filteredPlayer

	-- Create the frame
	self.Menu = vgui.Create("DFrame")
	self.Menu:SetSize(600, 400)
	self.Menu:SetTitle("Chatlog | " .. os.date("%a %x", os.time()))
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

	local column = chatLoglist:AddColumn( Chatlog.Translate("Time") )
	column:SetFixedWidth(40)
	column = chatLoglist:AddColumn( Chatlog.Translate("Player") )
	column:SetFixedWidth(80)
	column = chatLoglist:AddColumn( Chatlog.Translate("Message") )
	column:SetFixedWidth(chatLoglist:GetWide() - 110)

	-- "Selected message" panel
	local textPanel = {}
	self.DrawTextPanel(textPanel, chatlogTab)

	-- Filter-by-round DComboBox
	setting = vgui.Create("DLabel", chatlogTab)
	setting:SetPos(10,0)
	setting:SetColor(Color(0,0,0))
	setting:SetText(Chatlog.Translate("RoundFilter"))
	setting:SetSize(125, 20)

	local roundFilter = vgui.Create("DComboBox", chatlogTab)
	roundFilter:SetSize((chatlogTab:GetWide() - 20) / 2, 20)
	roundFilter:SetPos(5, 20)
	roundFilter:SetText(Chatlog.Translate("RoundSelect"))
	roundFilter:SetSortItems(false)

	-- If possible, add the previous map's last round as a choice
	if GetGlobalBool("ChatlogLastMapExists") == true then
		roundFilter:AddChoice(Chatlog.Translate("LastRoundMap"), nil, false, "icon16/page_save.png")
	end

	-- Add each round from the current map
	for i = 1, GetConVar("ttt_round_limit"):GetInt() - GetGlobalInt("ttt_rounds_left") do
		roundFilter:AddChoice(Chatlog.Translate("Round") .. i, nil, false, "icon16/page.png")
	end

	-- ghosting rates drop to 0%
	if Chatlog:CanReadPresent(client) then
		roundFilter:AddChoice(Chatlog.Translate("RoundSelectCurrent"), nil, false, "icon16/page_lightning.png")
	end

	-- Player filter DComboBox
	setting = vgui.Create("DLabel", chatlogTab)
	setting:SetPos(295,0)
	setting:SetColor(Color(0,0,0))
	setting:SetText(Chatlog.Translate("PlayerFilter"))
	setting:SetSize(125, 20)

	local playerFilter = vgui.Create("DComboBox", chatlogTab)
	playerFilter:SetSize((chatlogTab:GetWide() - 20) / 2, 20)
	playerFilter:SetPos(290,20)
	playerFilter:AddChoice(Chatlog.Translate("PlayerFilterNone"), nil, true, "icon16/cancel.png")
	playerFilter:SetSortItems(false)

	-- Set the filtered player if one is selected
	function playerFilter:OnSelect(index, text)
		if text != Chatlog.Translate("PlayerFilterNone") && text != Chatlog.Translate("PlayerFilterRemove") then
			filteredPlayer = text
		else
			filteredPlayer = nil
		end
	end

	-- Add a "hide dead" checkbox if the player has the privilege to
	if Chatlog:CanReadDead(client) then
		local deathCheck = vgui.Create("DCheckBoxLabel", chatlogTab)
		deathCheck:SetConVar("chatlog_hide_dead")
		deathCheck:SetText(Chatlog.Translate("DeadFilter"))
		deathCheck:SetTextColor(Color(0,0,0))
		deathCheck:SetPos(290,45)
		deathCheck:SizeToContents()
	end

	-- Refresh button for filters and current round
	local refreshButton = vgui.Create("DButton", chatlogTab)
	refreshButton:SetText(Chatlog.Translate("Refresh"))
	refreshButton:SetPos(230,2)
	refreshButton:SetSize(50,16)
	refreshButton.DoClick = function()
		if roundFilter:GetSelected() then
			roundFilter:ChooseOption(roundFilter:GetSelected(), roundFilter:GetSelectedID())
		else
			roundFilter:ChooseOption(Chatlog.Translate("RoundSelectCurrent"))
		end
	end

	-- Manage round selection
	function roundFilter:OnSelect(i, text)
		local index = i

		-- Define the round we're looking for
		-- Having the previous map's last round as a choice
		-- kinda messes with round indexes, so this is a workaround
		if text == Chatlog.Translate("RoundSelectCurrent") then index = 0
		elseif text == Chatlog.Translate("LastRoundMap") then index = -1
		elseif GetGlobalBool("ChatlogLastMapExists") == true then index = index - 1 end
			
		if Chatlog.Rounds[index] != nil then
			-- Load the round from the client if possible
			Chatlog:LoadRound(Chatlog.Rounds[index], chatLoglist, textPanel, filteredPlayer, playerFilter)
		else
			-- Ask the server for the round
			net.Start("AskChatlogRound")
			net.WriteInt(index, 16)
			net.SendToServer()
			Chatlog:ReceiveRound(chatLoglist, textPanel, filteredPlayer, playerFilter)
		end
	end

	-- Add to the DPropertySheet
	tabs:AddSheet(Chatlog.Translate("ChatTab"), chatlogTab, false, false )
	self.DrawSettings(tabs)
end

concommand.Add("chatlog", Chatlog.OpenMenu)