﻿function Chatlog:OpenMenu()

    local client = LocalPlayer()
    local height = ScrH() > 600 and 600 or 440

    Chatlog.Filters.players.steamids = {}

    local setting
    self.filteredPlayer = nil
    self.Menu = vgui.Create("DFrame")
    self.Menu:SetSize(600, height)
    self.Menu:SetTitle("TTT Chatlog - v" .. self.Version)
    self.Menu:MakePopup()
    self.Menu:Center()
    self.Menu:SetKeyboardInputEnabled(false)

    -- DPropertySheet for tabs
    self.Menu.tabs = vgui.Create("DPropertySheet", self.Menu)
    local tabs = self.Menu.tabs
    tabs:Dock(FILL)
    tabs:InvalidateLayout(true)

    -- Main Chatlog tab
    local chatlogTab = vgui.Create("DPanel", tabs)
    chatlogTab:Dock(FILL)
    chatlogTab:DockMargin(5, -2, 5, 5)
    chatlogTab:InvalidateLayout(true)
    chatlogTab.Height = height

    local roundInfo = vgui.Create("DPanel", chatlogTab)
    roundInfo:Dock(BOTTOM)
    roundInfo:DockMargin(0, 0, 5, 0)
    roundInfo:InvalidateLayout(true)
    roundInfo.Paint = function() end

    roundInfo.mapIcon = vgui.Create("DImage", roundInfo)
    roundInfo.mapIcon:SetImage("icon16/map.png")
    roundInfo.mapIcon:Dock(LEFT)
    roundInfo.mapIcon:DockMargin(5, 4, 4, 4)
    roundInfo.mapIcon:InvalidateLayout(true)
    roundInfo.mapIcon:SetSize(16, 16)

    roundInfo.mapLabel = vgui.Create("DLabel", roundInfo)
    roundInfo.mapLabel:SetFont("ChatlogMessage")
    roundInfo.mapLabel:SetText(Chatlog.Translate("NoRoundSelected"))
    roundInfo.mapLabel:SetColor(Chatlog.Colors.BLACK)
    roundInfo.mapLabel:Dock(LEFT)
    roundInfo.mapLabel:InvalidateLayout(true)
    roundInfo.mapLabel:SizeToContents()

    roundInfo.timeLabel = vgui.Create("DLabel", roundInfo)
    roundInfo.timeLabel:SetFont("ChatlogMessage")
    roundInfo.timeLabel:SetText(Chatlog.Translate("NoRoundSelected"))
    roundInfo.timeLabel:SetColor(Chatlog.Colors.BLACK)
    roundInfo.timeLabel:Dock(RIGHT)
    roundInfo.timeLabel:InvalidateLayout(true)
    roundInfo.timeLabel:SizeToContents()

    roundInfo.timeIcon = vgui.Create("DImage", roundInfo)
    roundInfo.timeIcon:SetImage("icon16/date.png")
    roundInfo.timeIcon:Dock(RIGHT)
    roundInfo.timeIcon:DockMargin(4, 4, 4, 4)
    roundInfo.timeIcon:InvalidateLayout(true)
    roundInfo.timeIcon:SetSize(16, 16)

    roundInfo.codeLabel = vgui.Create("DLabel", roundInfo)
    roundInfo.codeLabel:SetFont("ChatlogMessage")
    roundInfo.codeLabel:SetText(Chatlog.Translate("NoRoundSelected"))
    roundInfo.codeLabel:SetColor(Chatlog.Colors.BLACK)
    roundInfo.codeLabel:SetPos((Chatlog.Menu:GetWide() / 2) - 32, 5)
    roundInfo.codeLabel:InvalidateLayout(true)
    roundInfo.codeLabel:SizeToContents()
    roundInfo.codeLabel:SetMouseInputEnabled(true)

    roundInfo.copyCode = vgui.Create("DImageButton", roundInfo)
    roundInfo.copyCode:SetImage("icon16/tag_blue.png")
    roundInfo.copyCode:SetSize(16, 16)
    roundInfo.copyCode:SetPos(roundInfo.codeLabel:GetX() - 20, 5)
    roundInfo.copyCode:SetTooltip(Chatlog.Translate("CopyRoundCode"))
    roundInfo.copyCode.DoClick = function()
        SetClipboardText(roundInfo.codeLabel:GetText())
        chat.AddText(Chatlog.Colors.WHITE, string.format(Chatlog.Translate("CopiedRoundCode"), roundInfo.codeLabel:GetText()))
    end
    roundInfo.codeLabel.DoClick = roundInfo.copyCode.DoClick

    function roundInfo.copyCode:Think()
        self:SetEnabled(#roundInfo.codeLabel:GetText() == 6)
    end

    hook.Add("ChatlogRoundLoaded", "ChatlogUpdateRoundInfo", function(round)
        roundInfo.mapLabel:SetText(round.map or Chatlog.Translate("RoundInfoError"))
        roundInfo.mapLabel:SizeToContents()

        roundInfo.timeLabel:SetText(round.unix and os.date(Chatlog.Translate("RoundInfoTime"), round.unix) or Chatlog.Translate("RoundInfoError"))
        roundInfo.timeLabel:SizeToContents()

        roundInfo.codeLabel:SetText(round.code or Chatlog.Translate("RoundInfoError"))
        roundInfo.codeLabel:SizeToContents()
    end)

    self.chatLogList = vgui.Create("DListView", chatlogTab)
    local chatLoglist = self.chatLogList
    chatLoglist:Dock(BOTTOM)
    chatLoglist:DockMargin(5, 5, 5, 0)
    chatLoglist:SetSortable(false)
    chatLoglist:SetHeight(370 - (height == 600 and 0 or 160))
    chatLoglist:SetMultiSelect(false)

    local column = chatLoglist:AddColumn(Chatlog.Translate("Time"))
    column:SetFixedWidth(40)
    column = chatLoglist:AddColumn(Chatlog.Translate("Player"))
    column:SetFixedWidth(80)
    column = chatLoglist:AddColumn(Chatlog.Translate("Message"))
    column:SetFixedWidth(450)
    column = chatLoglist:AddColumn(Chatlog.Translate("curtime"))
    column:SetFixedWidth(0)

    local filteringPanel = vgui.Create("DPanel", chatlogTab)
    filteringPanel:Dock(TOP)
    filteringPanel:DockMargin(5, 5, 5, 5)
    filteringPanel:InvalidateLayout(true)
    filteringPanel:SetHeight(50)

    -- "Selected message" panel
    self.DrawTextPanel(chatlogTab)

    -- Filter-by-round DComboBox
    setting = vgui.Create("DLabel", filteringPanel)
    setting:Dock(TOP)
    setting:DockMargin(7, 0, 5, 0)
    setting:SetColor(Chatlog.Colors.BLACK)
    setting:SetText(Chatlog.Translate("RoundFilter"))

    self.Menu.roundFilter = vgui.Create("DComboBox", filteringPanel)
    local roundFilter = self.Menu.roundFilter
    roundFilter:Dock(LEFT)
    roundFilter:DockMargin(5, 0, 0, 4)
    roundFilter:SetWidth(250)
    roundFilter:SetText(Chatlog.Translate("RoundSelect"))
    roundFilter:SetSortItems(false)

    -- Refresh button for filters and current round
    local refreshButton = vgui.Create("DButton", filteringPanel)
    refreshButton:Dock(LEFT)
    refreshButton:DockMargin(3, 0, 0, 4)
    refreshButton:SetImage("icon16/arrow_refresh.png")
    refreshButton:SetText("")
    refreshButton:InvalidateLayout()
    refreshButton:SetSize(24, 24)

    local filtersButton = vgui.Create("DButton", filteringPanel)
    filtersButton:Dock(LEFT)
    filtersButton:DockMargin(3, 0, 0, 4)
    filtersButton:SetImage("icon16/wrench.png")
    filtersButton:SetText(Chatlog.Translate("FiltersButtonShow"))
    filtersButton:InvalidateLayout(true)
    filtersButton:SizeToContents()

    Chatlog.DrawMoreFilters(chatlogTab, filteringPanel:GetTall() + 6)

    local playersButton = vgui.Create("DButton", filteringPanel)
    playersButton:Dock(LEFT)
    playersButton:DockMargin(3, 0, 0, 4)
    playersButton:SetImage("icon16/user.png")
    playersButton:SetText(Chatlog.Translate("PlayerListButtonShow"))
    playersButton:InvalidateLayout(true)
    playersButton:SizeToContents()

    Chatlog.DrawPlayerList(chatlogTab, filteringPanel:GetTall() + 6)

    filtersButton.DoClick = function()
        if (not chatlogTab.moreFilters.showing) then
            filtersButton:SetText(Chatlog.Translate("FiltersButtonHide"))
            filtersButton:SizeToContents()
            chatlogTab.moreFilters.showFilters()

            if (chatlogTab.playerList.showing) then
                playersButton.DoClick()
            end
        else
            filtersButton:SetText(Chatlog.Translate("FiltersButtonShow"))
            filtersButton:SizeToContents()
            chatlogTab.moreFilters.hideFilters()
        end
    end

    playersButton.DoClick = function()
        if (not chatlogTab.playerList.showing) then
            playersButton:SetText(Chatlog.Translate("PlayerListButtonHide"))
            playersButton:SizeToContents()
            chatlogTab.playerList.showPlayers()

            if (chatlogTab.moreFilters.showing) then
                filtersButton.DoClick()
            end
        else
            playersButton:SetText(Chatlog.Translate("PlayerListButtonShow"))
            playersButton:SizeToContents()
            chatlogTab.playerList.hidePlayers()
        end
    end

    refreshButton.DoClick = function()
        if roundFilter:GetSelected() then
            roundFilter:ChooseOption(roundFilter:GetSelected(), roundFilter:GetSelectedID())
        else
            roundFilter:ChooseOption(Chatlog.Translate("RoundSelectCurrent"))
        end

        if (chatlogTab.moreFilters.showing) then
            filtersButton.DoClick()
        end

        if (chatlogTab.playerList.showing) then
            playersButton.DoClick()
        end
    end

    -- If possible, add the previous map's last round as a choice
    if GetGlobalBool("ChatlogLastMapExists") == true then
        roundFilter:AddChoice(Chatlog.Translate("LastRoundMap"), nil, false, "icon16/page_save.png")
    end

    -- Add each round from the current map
    for i = 1, GetGlobalInt("ChatlogRoundNumber") - 1 do
        roundFilter:AddChoice(Chatlog.Translate("Round") .. i, nil, false, "icon16/page.png")
    end

    if Chatlog:CanReadPresent(client) and GetGlobalInt("ChatlogRoundNumber") > 0 then
        roundFilter:AddChoice(Chatlog.Translate("RoundSelectCurrent"), nil, false, "icon16/page_lightning.png")
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
            Chatlog.LoadRound(Chatlog.Rounds[index])
        else
            -- Ask the server for the round
            net.Start("AskChatlogRound")
            net.WriteInt(index, 16)
            net.SendToServer()
        end

        if (chatlogTab.moreFilters.showing) then
            filtersButton.DoClick()
        end

        if (chatlogTab.playerList.showing) then
            playersButton.DoClick()
        end
    end

    -- "This version is outdated" warning
    if (Chatlog.outdated) then
        local outd = vgui.Create("DPanel", chatlogTab)
        outd:SetSize(400, 18)
        outd:SetPos(180, 0)

        function outd:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Chatlog.Colors.BLACK)
            draw.RoundedBox(0, 1, 1, w - 2, h - 2, Chatlog.Colors.YELLOW)
        end

        local outlabel = vgui.Create("DLabel", outd)
        outlabel:SetFont("ChatlogMessage")
        outlabel:SetText("This version is outdated! Download latest at github.com/actuallyNothing/chatlog")
        outlabel:SizeToContents()
        outlabel:SetColor(Chatlog.Colors.BLACK)
        outlabel:SetMouseInputEnabled(true)
        outlabel:Center()
    end

    tabs:AddSheet(Chatlog.Translate("ChatTab"), chatlogTab, "icon16/page.png")
    self:DrawSettings(tabs)
    self:DrawOldLogs(tabs)

    if (client:GetUserGroup() == "superadmin") then
        self:DrawManagerPanel(tabs)
    end

    function tabs:OnActiveTabChanged(old, new)
        Chatlog.Menu:SetKeyboardInputEnabled(new:GetText() == Chatlog.Translate("OldLogsTab"))

        if (new:GetPanel().Height) then
            Chatlog.Menu:SetHeight(new:GetPanel().Height)
        end
    end

end

concommand.Add("chatlog", function()
    if not IsValid(Chatlog.Menu) then
        Chatlog:OpenMenu()
    else
        Chatlog.Menu:Close()
    end
end)