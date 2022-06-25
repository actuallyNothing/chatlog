function Chatlog.DrawTextPanel(textPanel, chatlogTab)
    -- Full text panel
    textPanel.frame = vgui.Create("DPanel", chatlogTab)
    textPanel.frame:Dock(BOTTOM)
    textPanel.frame:DockMargin(5, 2, 5, 0)
    textPanel.frame:SetHeight(50)
    textPanel.frame:SetBackgroundColor(Chatlog.Colors["TEXTPANEL_BACKGROUND"])
    -- Full text title label
    textPanel.label = vgui.Create("DLabel", chatlogTab)
    textPanel.label:Dock(BOTTOM)
    textPanel.label:DockMargin(7, 5, 0, 0)
    textPanel.label:SetText(Chatlog.Translate("SelectedMessage"))
    textPanel.label:SetFont("ChatlogMessageLabel")
    textPanel.label:SetColor(Chatlog.Colors["BLACK"])
    textPanel.label:SizeToContents()
    -- Full text
    -- We're passing this on to LoadRound() so it can modify the
    -- text whenever we click on a line, and declaring it
    -- as a function so we can clear it when changing rounds
    textPanel.fulltext = vgui.Create("DLabel", textPanel.frame)
    textPanel.fulltext:SetFont("ChatlogMessage")
    textPanel.timestamp = vgui.Create("DLabel", textPanel.frame)
    textPanel.timestamp:SetFont("ChatlogAuthor")
    textPanel.author = vgui.Create("DLabel", textPanel.frame)
    textPanel.author:SetFont("ChatlogAuthor")

    function Chatlog.ClearTextPanel()
        textPanel.timestamp:SetColor(Chatlog.Colors["BLACK"])
        textPanel.timestamp:SetText("[00:00]")
        textPanel.timestamp:Dock(LEFT)
        textPanel.timestamp:DockMargin(7, 0, 5, 32)
        textPanel.timestamp:SizeToContents()
        textPanel.author:SetText(Chatlog.Translate("Player"))
        textPanel.author:SetColor(Chatlog.Colors["BLACK"])
        textPanel.author:Dock(LEFT)
        textPanel.author:DockMargin(0, 0, 2, 32)
        textPanel.author:SizeToContents()
        textPanel.fulltext:SetColor(Chatlog.Colors["BLACK"])
        textPanel.fulltext:SetSize(chatlogTab:GetWide() - 15, 40)
        textPanel.fulltext:SetWrap(true)
        textPanel.fulltext:Dock(BOTTOM)
        textPanel.fulltext:DockMargin(7, -43, 0, 0)
        textPanel.fulltext:SetText(Chatlog.Translate("SelectedMessageNone"))
    end

    Chatlog.ClearTextPanel()
end
