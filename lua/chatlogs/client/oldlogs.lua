local serverResponses = {
    [1] = function()
        chat.AddText(Color(255, 0, 0), "No round found with that code.")
    end,

    [2] = function()
        chat.AddText(Color(255, 255, 0), "Code is invalid.")
    end,

    [3] = function(tabs)
        chat.AddText(Color(0, 255, 0), "Loading round...")
        tabs:SwitchToName("Chatlog")
    end
}

function Chatlog:DrawOldLogs(tabs)

    local oldLogsPanel = vgui.Create("DPanel")
    -- oldLogsPanel.Paint = function() end

    -- Search by code

    local codePanel = vgui.Create("DPanel", oldLogsPanel)
    codePanel:Dock(TOP)
    codePanel:DockMargin(5, 5, 5, 5)
    codePanel:SetHeight(100)
    codePanel:SetBackgroundColor(Chatlog.Colors["PANEL_ADMIN_GROUPVIEW"])

    local codeTitle = vgui.Create("DLabel", codePanel)
    codeTitle:SetText("Search by code")
    codeTitle:SetFont("ChatlogPanelTitle")
    codeTitle:SizeToContents()
    codeTitle:SetColor(Chatlog.Colors["WHITE"])
    codeTitle:SetPos(6, 3)

    local codeTip = vgui.Create("DLabel", codePanel)
    codeTip:SetText("Rounds have a unique 6-character code that can be used to search for a specific round.")
    codeTip:SizeToContents()
    codeTip:SetColor(Chatlog.Colors["WHITE"])
    codeTip:SetPos(6, codeTitle:GetTall() + codeTitle:GetY() + 3)

    local codeEntryTitle = vgui.Create("DLabel", codePanel)
    codeEntryTitle:SetText("Code: ")
    codeEntryTitle:SizeToContents()
    codeEntryTitle:SetColor(Chatlog.Colors["WHITE"])
    codeEntryTitle:SetPos(6, codeTip:GetTall() + codeTip:GetY() + 8)

    local codeEntry = vgui.Create("DTextEntry", codePanel)
    codeEntry:SetSize(60, 20)
    codeEntry:SetPos(codeEntryTitle:GetWide() + codeEntryTitle:GetX() + 3, codeEntryTitle:GetY() - 3)
    codeEntry:SetText("")
    codeEntry:SetTextColor(Chatlog.Colors["WHITE"])
    codeEntry:SetEditable(true)
    codeEntry:SetUpdateOnType(true)

    function codeEntry:OnValueChange(value)
        if (#value ~= 6) then
            self:SetTextColor(Chatlog.Colors["RED"])
        else
            self:SetTextColor(Chatlog.Colors["BLACK"])
        end
    end

    function codeEntry:OnLoseFocus()
        if (#self:GetValue() > 6) then
            self:SetValue(self:GetValue():sub(1, 6))
            self:SetText(self:GetValue():sub(1, 6))
        end

        self:SetValue(self:GetValue():upper())
        self:SetText(self:GetValue():upper())
    end

    local codeEnterButton = vgui.Create("DButton", codePanel)
    codeEnterButton:SetText("Search")
    codeEnterButton:SetSize(60, 20)
    codeEnterButton:SetPos(codeEntry:GetWide() + codeEntry:GetX() + 3, codeEntryTitle:GetY() - 3)

    function codeEnterButton:Think()
        self:SetEnabled(#codeEntry:GetValue() == 6)
    end

    function codeEnterButton:DoClick()
        local code = codeEntry:GetValue()

        if (Chatlog.OldLogs[code]) then
            Chatlog.LoadRound(Chatlog.OldLogs[code])
            serverResponses[3](tabs)
            return
        end

        net.Start("AskOldChatlog")
        net.WriteString(code)
        net.SendToServer()

        net.Receive("SendOldChatlogResult", function()
            local result = net.ReadUInt(2)

            serverResponses[result](tabs)
        end)
    end

    return tabs:AddSheet("Old logs", oldLogsPanel, "icon16/time.png")
end