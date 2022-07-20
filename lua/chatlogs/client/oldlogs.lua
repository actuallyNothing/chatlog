local serverResponses = {
    [1] = function()
        chat.AddText(Color(255, 0, 0), "No round found with that code.")
    end,

    [2] = function()
        chat.AddText(Color(255, 255, 0), "Code is invalid.")
    end,

    [3] = function(tabs)
        chat.AddText(Color(0, 255, 0), "Loading round...")
        tabs:SwitchToName(Chatlog.Translate("ChatTab"))
    end
}

Chatlog.Dates = Chatlog.Dates or {
    oldest = 0,
    latest = 0
}

Chatlog.OldLogsDays = Chatlog.OldLogsDays or {}

local loading = {}

local function LoadLogs(node)

    if node.received or node.receiving then
        return
    end

    node.receiving = true
    local id = table.insert(loading, node)
    net.Start("AskOldChatlogRounds")
    net.WriteUInt(id, 32)
    net.WriteUInt(node.year, 32)
    net.WriteUInt(node.month, 32)
    net.WriteUInt(node.day, 32)
    net.SendToServer()

end

local function requestOldChatlog(code, tabs)

    if (Chatlog.OldRounds[code]) then
        Chatlog.LoadRound(Chatlog.OldRounds[code])
        serverResponses[3](tabs)
        Chatlog.Menu.roundFilter:SetText("Old Chatlog round")
        return
    else
        for _, v in ipairs(Chatlog.Rounds) do
            if (v.code == code) then
                Chatlog.LoadRound(v)
                serverResponses[3](tabs)
                Chatlog.Menu.roundFilter:SetText("Old Chatlog round")
                return
            end
        end
    end

    net.Start("AskOldChatlog")
    net.WriteString(code)
    net.SendToServer()

end

function Chatlog:DrawOldLogs(tabs)

    Chatlog.OldLogs = vgui.Create("DPanel")
    local panel = Chatlog.OldLogs

    -- Search by code

    local codePanel = vgui.Create("DPanel", panel)
    codePanel:Dock(TOP)
    codePanel:DockMargin(5, 5, 5, 5)
    codePanel:SetHeight(100)
    codePanel:SetBackgroundColor(Chatlog.Colors["PANEL_DARK"])

    local codeTitle = vgui.Create("DLabel", codePanel)
    codeTitle:SetText(Chatlog.Translate("OldLogsCodeTitle"))
    codeTitle:SetFont("ChatlogPanelTitle")
    codeTitle:SizeToContents()
    codeTitle:SetColor(Chatlog.Colors["WHITE"])
    codeTitle:SetPos(6, 3)

    local codeTip = vgui.Create("DLabel", codePanel)
    codeTip:SetText(Chatlog.Translate("OldLogsCodeTip"))
    codeTip:SizeToContents()
    codeTip:SetColor(Chatlog.Colors["WHITE"])
    codeTip:SetPos(6, codeTitle:GetTall() + codeTitle:GetY() + 3)

    local codeEntryTitle = vgui.Create("DLabel", codePanel)
    codeEntryTitle:SetText(Chatlog.Translate("OldLogsCodeLabel"))
    codeEntryTitle:SizeToContents()
    codeEntryTitle:SetColor(Chatlog.Colors["WHITE"])
    codeEntryTitle:SetPos(6, codeTip:GetTall() + codeTip:GetY() + 8)

    local codeEntry = vgui.Create("DTextEntry", codePanel)
    codeEntry:SetSize(80, 20)
    codeEntry:SetPos(codeEntryTitle:GetWide() + codeEntryTitle:GetX() + 3, codeEntryTitle:GetY() - 3)
    codeEntry:SetText("")
    codeEntry:SetPlaceholderText("ABC123")
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
    codeEnterButton:SetText(Chatlog.Translate("OldLogsCodeButton"))
    codeEnterButton:SetSize(60, 20)
    codeEnterButton:SetPos(codeEntry:GetWide() + codeEntry:GetX() + 3, codeEntryTitle:GetY() - 3)

    function codeEnterButton:Think()
        self:SetEnabled(#codeEntry:GetValue() == 6)
    end

    function codeEnterButton:DoClick()
        local code = codeEntry:GetValue()
        requestOldChatlog(code, tabs)
    end

    if (not Chatlog:CanSearchByDate()) then
        codePanel:Dock(FILL)
        tabs:AddSheet(Chatlog.Translate("OldLogsTab"), panel, "icon16/time.png")
        return
    end

    -- Search by date

    local datePanel = vgui.Create("DPanel", panel)
    datePanel:Dock(FILL)
    datePanel:DockMargin(5, 5, 5, 5)
    datePanel:SetBackgroundColor(Chatlog.Colors["PANEL_LIGHT"])

    local dateTitle = vgui.Create("DLabel", datePanel)
    dateTitle:SetText(Chatlog.Translate("OldLogsDateTitle"))
    dateTitle:SetFont("ChatlogPanelTitle")
    dateTitle:SizeToContents()
    dateTitle:SetColor(Chatlog.Colors["BLACK"])
    dateTitle:SetPos(6, 3)

    local dateTip = vgui.Create("DLabel", datePanel)
    dateTip:SetText(Chatlog.Translate("OldLogsDateTip"))
    dateTip:SizeToContents()
    dateTip:SetColor(Chatlog.Colors["BLACK"])
    dateTip:SetPos(6, dateTitle:GetTall() + dateTitle:GetY() + 3)

    local dateTree = vgui.Create("DTree", datePanel)
    dateTree:SetPos(6, dateTip:GetTall() + dateTip:GetY() + 3)
    dateTree:SetSize(300, 200)

    local rounds = vgui.Create("DListView", datePanel)
    rounds:SetPos(dateTree:GetX() + dateTree:GetWide() + 5, dateTree:GetY())
    rounds:SetSize(250, 165)

    local roundColumn = rounds:AddColumn("")

    local loadButton = vgui.Create("DButton", datePanel)
    loadButton:SetText(Chatlog.Translate("OldLogsDateLoad"))
    loadButton:SetSize(rounds:GetWide(), 23)
    loadButton:SetPos(rounds:GetX(), rounds:GetTall() + loadButton:GetTall() + 30)
    loadButton:SetEnabled(false)

    tabs:AddSheet(Chatlog.Translate("OldLogsTab"), panel, "icon16/time.png")

    function Chatlog.OldLogs:UpdateDates()

        local older = string.Explode(",", os.date("%Y,%m,%d,%H,%M", Chatlog.Dates.oldest))
        local latest = string.Explode(",", os.date("%Y,%m,%d,%H,%M", Chatlog.Dates.latest))

        for _, v in pairs({older, latest}) do
            for k, data in pairs(v) do
                v[k] = tonumber(data)
            end
        end

        local years = latest[1] - older[1]

        for y = 0, years do
            local year = latest[1] - y

            if Chatlog.OldLogsDays[year] then
                local node_year = dateTree:AddNode(tostring(year))
                node_year.year = year
                local start_range
                local end_range

                if years == 0 then
                    start_range = older[2]
                    end_range = latest[2]
                elseif year == latest[1] then
                    start_range = 1
                    end_range = latest[2]
                elseif year == older[1] then
                    start_range = older[2]
                    end_range = 12
                else
                    start_range = 1
                    end_range = 12
                end

                for m = start_range, end_range do
                    if Chatlog.OldLogsDays[year][m] then
                        local month = Chatlog.Translate("Month" .. m)
                        local node_month = node_year:AddNode(month)
                        node_month.year = year
                        node_month.month = m
                        node_month.received = false
                        local number_of_days

                        if m == 2 then
                            local real_year = 2000 + year

                            if real_year % 4 == 0 and not (real_year % 100 == 0 and real_year % 400 ~= 0) then
                                number_of_days = 29
                            else
                                number_of_days = 28
                            end
                        else
                            number_of_days = (m % 2 == 0) and 31 or 30
                        end

                        for d = 1, number_of_days do
                            if Chatlog.OldLogsDays[year][m][d] then
                                local day = node_month:AddNode(tostring(d))
                                day.year = node_month.year
                                day.month = node_month.month
                                day.day = d
                                day:SetForceShowExpander(true)
                                day.old_SetExpanded = day.SetExpanded

                                day.SetExpanded = function(pnl, expand, animation)
                                    if expand then
                                        LoadLogs(day)
                                    end

                                    return pnl.old_SetExpanded(pnl, expand, animation)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    dateTree.OnNodeSelected = function(tree, node)

        if (node.rounds) then

            rounds:Clear()
            lunix = nil
            roundColumn:SetName(string.format(Chatlog.Translate("OldLogsDateBetween"), node.hour .. "hs", node.hour + 1 .. "hs"))

            local linestr = "[%s] %s - " .. Chatlog.Translate("Round")  .. "%s [%s]"

            for _, v in ipairs(node.rounds) do

                if (v.unix ~= lunix) then

                    local hour = (string.sub(tostring(os.date("%I:%M", v.unix)), 1, 1) == "0" and string.sub(tostring(os.date("%I:%M", v.unix)), 2, 5) or (tostring(os.date("%I:%M", v.unix))))
                    local line = rounds:AddLine(string.format(linestr, hour, v.map, v.round, v.code))
                    line.time = v.unix
                    line.code = v.code
                    lunix = v.unix


                end

            end

        end

    end

    rounds.OnRowSelected = function(list, index, line)
        loadButton:SetEnabled(true)
    end

    loadButton.DoClick = function()

        local _, round = rounds:GetSelectedLine()

        requestOldChatlog(round.code, tabs)

    end

    net.Start("AskChatlogDates")
    net.SendToServer()

end

net.Receive("SendOldChatlogResult", function()
    local result = net.ReadUInt(2)

    serverResponses[result](Chatlog.Menu.tabs)
end)

net.Receive("SendChatlogDates", function()

    if (not IsValid(Chatlog.OldLogs) or not Chatlog:CanSearchByDate()) then return end

    Chatlog.Dates.oldest = net.ReadUInt(32)
    Chatlog.Dates.latest = net.ReadUInt(32)

    local length = net.ReadUInt(32)
    Chatlog.OldLogsDays = util.JSONToTable(util.Decompress(net.ReadData(length)))

    Chatlog.OldLogs:UpdateDates()

end)

net.Receive("SendOldChatlogRounds", function()
    local id = net.ReadUInt(32)
    local list = net.ReadTable()
    local node = loading[id]

    if not node then
        return
    end

    if #list <= 0 then
        node:Remove()
    else
        local dates = {}

        for _, v in pairs(list) do
            local _time = string.Explode(",", os.date("%H,%M", v.date))
            local hour = _time[1]
            hour = tonumber(hour)
            v.min = tonumber(_time[2])

            if not dates[hour] then
                dates[hour] = {v}
            end

            table.insert(dates[hour], v)
        end

        for i = 0, 24 do
            local hour = dates[i]

            if hour then
                local node = node:AddNode(i .. "hs")
                table.SortByMember(hour, "unix")
                node.rounds = hour
                node.hour = i
                node.min = hour.min
            end
        end
    end
end)