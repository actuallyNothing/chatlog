function Chatlog:OpenMenu()
    client = LocalPlayer()
    local setting
    self.filteredPlayer = nil
    self.Menu = vgui.Create("DFrame")
    self.Menu:SetSize(600, 400)
    self.Menu:SetTitle("Chatlog | " .. os.date("%a %x", os.time()))
    self.Menu:MakePopup()
    self.Menu:Center()
    self.Menu:SetKeyboardInputEnabled(false)

    -- "This version is outdated" warning
    if Chatlog.outdated then
        local outd = vgui.Create("DPanel", self.Menu)
        outd:SetSize(400, 18)
        outd:SetPos(175, 30)

        function outd:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
            draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(255, 255, 0))
        end

        local outlabel = vgui.Create("DLabel", outd)
        outlabel:SetFont("ChatlogMessage")
        outlabel:SetText("This version is outdated! Download latest at github.com/actuallyNothing/chatlog")
        outlabel:SizeToContents()
        outlabel:SetColor(Color(0, 0, 0))
        outlabel:SetMouseInputEnabled(true)
        outlabel:Center()
    end

    -- DPropertySheet for tabs
    local tabs = vgui.Create("DPropertySheet", self.Menu)
    tabs:Dock(FILL)
    -- Main Chatlog tab
    local chatlogTab = vgui.Create("DPanel", tabs)
    chatlogTab:Dock(FILL)
    chatlogTab:DockMargin(5, -2, 5, 5)
    self.chatLogList = vgui.Create("DListView", chatlogTab)
    local chatLoglist = self.chatLogList
    chatLoglist:Dock(BOTTOM)
    chatLoglist:DockMargin(5, 5, 5, 5)
    chatLoglist:SetSortable(false)
    chatLoglist:SetHeight(200)
    chatLoglist:SetMultiSelect(false)
    local column = chatLoglist:AddColumn(Chatlog.Translate("Time"))
    column:SetFixedWidth(40)
    column = chatLoglist:AddColumn(Chatlog.Translate("Player"))
    column:SetFixedWidth(80)
    column = chatLoglist:AddColumn(Chatlog.Translate("Message"))
    column:SetFixedWidth(450)
    -- "Selected message" panel
    self.textPanel = {}
    local textPanel = self.textPanel
    self.DrawTextPanel(textPanel, chatlogTab)
    -- Filter-by-round DComboBox
    setting = vgui.Create("DLabel", chatlogTab)
    setting:Dock(TOP)
    setting:DockMargin(7, 5, 5, 0)
    setting:SetColor(Color(0, 0, 0))
    setting:SetText(Chatlog.Translate("RoundFilter"))
    local roundFilter = vgui.Create("DComboBox", chatlogTab)
    roundFilter:Dock(LEFT)
    roundFilter:DockMargin(5, 0, 5, 4)
    roundFilter:SetWidth(250)
    roundFilter:SetText(Chatlog.Translate("RoundSelect"))
    roundFilter:SetSortItems(false)

    -- If possible, add the previous map's last round as a choice
    if GetGlobalBool("ChatlogLastMapExists") == true then
        roundFilter:AddChoice(Chatlog.Translate("LastRoundMap"), nil, false, "icon16/page_save.png")
    end

    -- Add each round from the current map
    for i = 1, GetGlobalInt("ChatlogRoundNumber") - 1 do
        roundFilter:AddChoice(Chatlog.Translate("Round") .. i, nil, false, "icon16/page.png")
    end

    if Chatlog:CanReadPresent(client) then
        roundFilter:AddChoice(Chatlog.Translate("RoundSelectCurrent"), nil, false, "icon16/page_lightning.png")
    end

    -- Player filter DComboBox
    setting = vgui.Create("DLabel", chatlogTab)
    setting:Dock(TOP)
    setting:DockMargin(40, -20, 0, 0)
    setting:SetColor(Color(0, 0, 0))
    setting:SetText(Chatlog.Translate("PlayerFilter"))
    setting:SetSize(125, 20)
    self.playerFilter = vgui.Create("DComboBox", chatlogTab)
    local playerFilter = self.playerFilter
    playerFilter:Dock(RIGHT)
    playerFilter:DockMargin(8, 0, 5, 4)
    playerFilter:SetWidth(275)
    playerFilter:AddChoice(Chatlog.Translate("PlayerFilterNone"), nil, true, "icon16/cancel.png")
    playerFilter:SetSortItems(false)

    -- Set the filtered player if one is selected
    function playerFilter:OnSelect(index, text)
        if text ~= Chatlog.Translate("PlayerFilterNone") and text ~= Chatlog.Translate("PlayerFilterRemove") then
            Chatlog.filteredPlayer = text
        else
            Chatlog.filteredPlayer = nil
        end
    end

    if Chatlog:CanReadDead(client) then
        local deathCheck = vgui.Create("DCheckBoxLabel", chatlogTab)
        deathCheck:SetConVar("chatlog_hide_dead")
        deathCheck:SetPos(300, 53)
        deathCheck:SetTextColor(Color(0, 0, 0))
        deathCheck:SetText(Chatlog.Translate("DeadFilter"))
        deathCheck:SizeToContents()
    end

    -- Refresh button for filters and current round
    local refreshButton = vgui.Create("DButton", chatlogTab)
    refreshButton:Dock(BOTTOM)
    refreshButton:DockMargin(3, 0, 0, 6)
    refreshButton:SetImage("icon16/arrow_refresh.png")
    refreshButton:SetText("")
    refreshButton:SetTooltip("Refresh")

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
        if text == Chatlog.Translate("RoundSelectCurrent") then
            index = 0
        elseif text == Chatlog.Translate("LastRoundMap") then
            index = -1
        elseif GetGlobalBool("ChatlogLastMapExists") == true then
            index = index - 1
        end

        if Chatlog.Rounds[index] ~= nil then
            -- Load the round from the client if possible
            Chatlog:LoadRound(Chatlog.Rounds[index], chatLoglist, textPanel, Chatlog.filteredPlayer, playerFilter)
        else
            -- Ask the server for the round
            net.Start("AskChatlogRound")
            net.WriteInt(index, 16)
            net.SendToServer()
        end
    end

    tabs:AddSheet(Chatlog.Translate("ChatTab"), chatlogTab, "icon16/page.png")
    self:DrawSettings(tabs)

    if client:GetUserGroup() == "superadmin" then
        self:DrawManagerPanel(tabs)
    end
end

concommand.Add("chatlog", function()
    if not IsValid(Chatlog.Menu) then
        Chatlog:OpenMenu()
    else
        Chatlog.Menu:Close()
    end
end)
