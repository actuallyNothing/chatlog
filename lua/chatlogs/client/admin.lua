local function removeExcessValues(table1, table2)
    for k, v in pairs(table1) do
        if type(v) == "table" and type(table2[k]) == "table" then
            table1[k] = removeExcessValues(v, table2[k])
        elseif table1[k] == table2[k] and k ~= "markedForDeletion" then
            table1[k] = nil
        end
    end

    return table1
end

local function confirmCommit(config)
    local full = table.Copy(Chatlog.Config)
    config = removeExcessValues(config, full)
    net.Start("ChatlogCommitConfiguration")
    net.WriteString(util.TableToJSON(config))
    net.SendToServer()
end

function Chatlog:DrawManagerPanel(tabs)
    local localConfig = table.Copy(Chatlog.Config)

    local selGroup
    local managerPanel = vgui.Create("DPanel")
    local sidebar = managerPanel:Add("DPanel")
    sidebar:Dock(LEFT)
    sidebar:SetWidth(125)

    -- Sidebar

    local usergroups = sidebar:Add("DListView")
    usergroups:AddColumn(Chatlog.Translate("AdminUsergroups"))
    usergroups:Dock(TOP)
    usergroups:DockMargin(5, 5, 5, 5)
    usergroups:SetMultiSelect(false)
    usergroups:SetHeight(280)

    for k, _ in pairs(Chatlog.Config.privileges) do
        usergroups:AddLine(k)
    end

    local addGroup = sidebar:Add("DButton")
    addGroup:Dock(TOP)
    addGroup:DockMargin(5, 0, 5, 5)
    addGroup:SetText(Chatlog.Translate("AdminNewGroup"))

    addGroup.DoClick = function()
        local addGroupFrame = self.Menu:Add("DFrame")
        addGroupFrame:SetBackgroundBlur(true)
        addGroupFrame:SetDraggable(false)
        addGroupFrame:Center()
        addGroupFrame:SetSize(245, 100)
        addGroupFrame:SetTitle(Chatlog.Translate("AdminNewGroupTitle"))
        addGroupFrame:ShowCloseButton(false)
        addGroupFrame:MakePopup()

        local title = addGroupFrame:Add("DLabel")
        title:SetText(Chatlog.Translate("AdminNewGroupTip"))
        title:Dock(TOP)
        title:DockMargin(5, 0, 5, -5)

        local groupEntry = addGroupFrame:Add("DTextEntry")
        groupEntry:Dock(TOP)
        groupEntry:DockMargin(5, 5, 5, 5)

        local w, h = addGroupFrame:GetWide() / 2 - 10, 20
        local confirm = addGroupFrame:Add("DButton")
        confirm:SetSize(w, h)
        confirm:SetPos(5, 75)
        confirm:SetText(Chatlog.Translate("AdminNewGroupAdd"))

        confirm.DoClick = function()
            local group = groupEntry:GetText()

            if localConfig.privileges[group] ~= nil then
                addGroupFrame:Close()
                chat.AddText(Chatlog.Colors["YELLOW"], Chatlog.Translate("AdminNewGroupError"), Chatlog.Colors["WHITE"], Chatlog.Translate("AdminGroupExists"))
            else
                localConfig.privileges[group] = table.Copy(localConfig.privileges["user"])
                addGroupFrame:Close()
                usergroups:AddLine(group)
            end
        end

        function confirm:Think()
            if groupEntry:GetText() == "" then
                confirm:SetEnabled(false)
            else
                confirm:SetEnabled(true)
            end
        end

        local cancel = addGroupFrame:Add("DButton")
        cancel:SetSize(w, h)
        cancel:SetPos(addGroupFrame:GetWide() - w - 5, 75)
        cancel:SetText(Chatlog.Translate("Cancel"))

        cancel.DoClick = function()
            addGroupFrame:Close()
        end
    end

    local mySqlConfig = sidebar:Add("DButton")
    mySqlConfig:Dock(TOP)
    mySqlConfig:DockMargin(5, 0, 5, 5)
    mySqlConfig:SetText(Chatlog.Translate("AdminMySQLSettings"))

    mySqlConfig.DoClick = function(self, reviewing)
        local mySqlConfigFrame = vgui.Create("DFrame")
        mySqlConfigFrame:SetBackgroundBlur(true)
        mySqlConfigFrame:SetSize(245, 290)
        mySqlConfigFrame:Center()
        mySqlConfigFrame:SetTitle(Chatlog.Translate("AdminMySQLSettings"))
        mySqlConfigFrame:MakePopup()

        if (reviewing) then
            local reviewLabel = mySqlConfigFrame:Add("DLabel")
            reviewLabel:SetWrap(true)
            reviewLabel:SetAutoStretchVertical(true)
            reviewLabel:SetContentAlignment(5)
            reviewLabel:SetText(Chatlog.Translate("AdminMySQLReview"))
            reviewLabel:Dock(TOP)
            reviewLabel:DockMargin(5, 0, 5, 5)
            reviewLabel:SetTextColor(Chatlog.Colors.YELLOW)
            reviewLabel:SetAutoStretchVertical(true)
        end

        local ipLabel = mySqlConfigFrame:Add("DLabel")
        ipLabel:SetText(Chatlog.Translate("MySQLHost"))
        ipLabel:Dock(TOP)
        ipLabel:DockMargin(5, 0, 5, -5)
        ipLabel:SetTextColor(Chatlog.Colors.WHITE)

        local fields = {}

        local ip = mySqlConfigFrame:Add("DTextEntry")
        ip:SetPlaceholderText("127.0.0.1")
        ip:Dock(TOP)
        ip:DockMargin(5, 5, 5, 5)
        ip:SetHeight(20)
        ip:SetValue(localConfig.mysql.ip)

        table.insert(fields, ip)

        function ip:OnValueChange(text)
            localConfig.mysql.ip = text
        end

        local portLabel = mySqlConfigFrame:Add("DLabel")
        portLabel:SetText(Chatlog.Translate("MySQLPort"))
        portLabel:Dock(TOP)
        portLabel:DockMargin(5, 0, 5, -5)
        portLabel:SetTextColor(Chatlog.Colors.WHITE)

        local port = mySqlConfigFrame:Add("DTextEntry")
        port:SetPlaceholderText("3306")
        port:Dock(TOP)
        port:DockMargin(5, 5, 5, 5)
        port:SetHeight(20)
        port:SetValue(localConfig.mysql.port)

        table.insert(fields, port)

        function port:OnValueChange(text)
            localConfig.mysql.port = text
        end

        local usernameLabel = mySqlConfigFrame:Add("DLabel")
        usernameLabel:SetText(Chatlog.Translate("MySQLUsername"))
        usernameLabel:Dock(TOP)
        usernameLabel:DockMargin(5, 0, 5, -5)
        usernameLabel:SetTextColor(Chatlog.Colors.WHITE)

        local username = mySqlConfigFrame:Add("DTextEntry")
        username:SetPlaceholderText("root")
        username:Dock(TOP)
        username:DockMargin(5, 5, 5, 5)
        username:SetHeight(20)
        username:SetValue(localConfig.mysql.username)

        table.insert(fields, username)

        function username:OnValueChange(text)
            localConfig.mysql.username = text
        end

        local passwordLabel = mySqlConfigFrame:Add("DLabel")
        passwordLabel:SetText(Chatlog.Translate("MySQLPassword"))
        passwordLabel:Dock(TOP)
        passwordLabel:DockMargin(5, 0, 5, -5)
        passwordLabel:SetTextColor(Chatlog.Colors.WHITE)

        local password = mySqlConfigFrame:Add("DTextEntry")
        password:SetPlaceholderText("admin")
        password:Dock(TOP)
        password:DockMargin(5, 5, 5, 5)
        password:SetHeight(20)
        password:SetValue(localConfig.mysql.password)

        table.insert(fields, password)

        function password:OnValueChange(text)
            localConfig.mysql.password = text
        end

        local databaseLabel = mySqlConfigFrame:Add("DLabel")
        databaseLabel:SetText(Chatlog.Translate("MySQLDatabase"))
        databaseLabel:Dock(TOP)
        databaseLabel:DockMargin(5, 0, 5, -5)
        databaseLabel:SetTextColor(Chatlog.Colors.WHITE)

        local database = mySqlConfigFrame:Add("DTextEntry")
        database:SetPlaceholderText("chatlog")
        database:Dock(TOP)
        database:DockMargin(5, 5, 5, 5)
        database:SetHeight(20)
        database:SetValue(localConfig.mysql.database)

        table.insert(fields, database)

        function database:OnValueChange(text)
            localConfig.mysql.database = text
        end

        for _, field in pairs(fields) do
            function field:PaintOver(w, h)
                -- WilliamVenner @ SQLWorkbench
                -- https://github.com/WilliamVenner/SQLWorkbench
                if (not self:IsHovered()) then
                    surface.SetDrawColor(Chatlog.Colors.BLACK)
                    surface.DrawRect(2,2,w-4,h-4)
                    draw.SimpleText(Chatlog.Translate("AdminHoverToShow"), "DermaDefaultBold", w / 2, h / 2, Chatlog.Colors.WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end

        local saveButton = mySqlConfigFrame:Add("DButton")
        saveButton:SetText(Chatlog.Translate("SaveChanges"))
        saveButton:Dock(TOP)
        saveButton:DockMargin(5, 5, 5, 5)

        function saveButton:DoClick()
            localConfig.mysql.ip = ip:GetValue()
            localConfig.mysql.port = port:GetValue()
            localConfig.mysql.username = username:GetValue()
            localConfig.mysql.password = password:GetValue()
            localConfig.mysql.database = database:GetValue()
            mySqlConfigFrame:Close()
        end

        mySqlConfigFrame:InvalidateChildren(true)
        mySqlConfigFrame:SizeToChildren(false, true)
    end

    local commit = sidebar:Add("DButton")
    commit:Dock(TOP)
    commit:DockMargin(5, 0, 5, 5)
    commit:SetText(Chatlog.Translate("SaveChanges"))

    commit.DoClick = function()

        Derma_Query(Chatlog.Translate("AdminCommitWarning"),
            Chatlog.Translate("AdminCommitTitle"),
            Chatlog.Translate("Confirm"),
            function()
                chat.AddText(Chatlog.Colors["YELLOW"], "Commiting...")
                confirmCommit(localConfig)

                if Chatlog.Menu:IsValid() then
                    Chatlog.Menu:Close()
                end
            end,

            Chatlog.Translate("Cancel")
        )
    end

    -- Privilege settings 

    local groupView = managerPanel:Add("DPanel")
    groupView:Dock(TOP)
    groupView:DockMargin(0, 5, 5, 5)
    groupView:SetHeight(150)
    groupView:SetBackgroundColor(Chatlog.Colors["PANEL_DARK"])

    local groupViewTitle = groupView:Add("DLabel")
    groupViewTitle:SetText(Chatlog.Translate("AdminPrivilegeTitle"))
    groupViewTitle:SetFont("ChatlogPanelTitle")
    groupViewTitle:SizeToContents()
    groupViewTitle:SetColor(Chatlog.Colors["WHITE"])
    groupViewTitle:SetPos(6, 3)

    local readPresentLabel = groupView:Add("DLabel")
    readPresentLabel:SetText(Chatlog.Translate("AdminPrivilegeReadPresent"))
    readPresentLabel:Dock(TOP)
    readPresentLabel:DockMargin(5, 25, 5, 5)

    local readPresent = groupView:Add("DComboBox")
    readPresent:SetText(Chatlog.Translate("AdminPrivilegeSelectGroup"))
    readPresent:SetDisabled(true)
    readPresent:Dock(TOP)
    readPresent:DockMargin(5, -5, 5, 5)
    readPresent:AddChoice(Chatlog.Translate("AdminPrivilegeReadPresentAlways"), "true", false, "icon16/accept.png")
    readPresent:AddChoice(Chatlog.Translate("AdminPrivilegeReadPresentSpecOnly"), "spec_only", false, "icon16/eye.png")
    readPresent:AddChoice(Chatlog.Translate("AdminPrivilegeReadPresentNever"), "false", false, "icon16/delete.png")

    function readPresent:OnSelect(_, _, data)
        -- option data sucks ass holy shit
        if data == "false" or data == "true" then
            data = tobool(data)
        end

        localConfig.privileges[selGroup]["can_read_current_round"] = data
    end

    local readTeam = groupView:Add("DCheckBoxLabel")
    readTeam:SetText(Chatlog.Translate("AdminPrivilegeReadTeam"))
    readTeam:SetDisabled(true)
    readTeam:Dock(TOP)
    readTeam:DockMargin(5, 0, 5, 5)

    function readTeam:OnChange(val)
        localConfig.privileges[selGroup]["can_read_team_messages"] = val
    end

    local readDead = groupView:Add("DCheckBoxLabel")
    readDead:SetText(Chatlog.Translate("AdminPrivilegeReadDead"))
    readDead:SetDisabled(true)
    readDead:Dock(TOP)
    readDead:DockMargin(5, 0, 5, 5)

    function readDead:OnChange(val)
        localConfig.privileges[selGroup]["can_read_dead_players"] = val
    end

    local searchByDate = groupView:Add("DCheckBoxLabel")
    searchByDate:SetText(Chatlog.Translate("AdminPrivilegeSearchByDate"))
    searchByDate:SetDisabled(true)
    searchByDate:Dock(TOP)
    searchByDate:DockMargin(5, 0, 5, 5)

    function searchByDate:OnChange(val)
        localConfig.privileges[selGroup]["can_search_old_logs_by_date"] = val
    end

    local groupName = groupView:Add("DLabel")
    groupName:Dock(BOTTOM)
    groupName:DockMargin(5, 0, 0, 5)
    groupName:Center()
    groupName:SetText(Chatlog.Translate("AdminPrivilegeSelectGroup"))
    groupName:SetColor(Chatlog.Colors["YELLOW"])
    groupName:SizeToContents()

    -- Server settings

    local serverView = managerPanel:Add("DPanel")
    serverView:Dock(FILL)
    serverView:DockMargin(0, 0, 5, 5)
    serverView:SetBackgroundColor(Chatlog.Colors["PANEL_LIGHT"])

    local serverViewTitle = serverView:Add("DLabel")
    serverViewTitle:SetText(Chatlog.Translate("AdminServerTitle"))
    serverViewTitle:SetFont("ChatlogPanelTitle")
    serverViewTitle:SizeToContents()
    serverViewTitle:SetColor(Chatlog.Colors["BLACK"])
    serverViewTitle:SetPos(6, 3)

    local quickKeybind = serverView:Add("DCheckBoxLabel")
    quickKeybind:SetText(Chatlog.Translate("AdminServerKeybind"))
    quickKeybind:SetTooltip(Chatlog.Translate("AdminServerKeybindTooltip"))
    quickKeybind:SetTextColor(Chatlog.Colors["BLACK"])
    quickKeybind:SetChecked(localConfig.keybind)
    quickKeybind:Dock(TOP)
    quickKeybind:DockMargin(5, 25, 5, 5)

    function quickKeybind:OnChange(val)
        localConfig.keybind = val
    end

    local dbUseMySQL = serverView:Add("DCheckBoxLabel")
    dbUseMySQL:SetText(Chatlog.Translate("AdminServerUseMySQL"))
    dbUseMySQL:SetTooltip(Chatlog.Translate("AdminServerUseMySQLTooltip"))
    dbUseMySQL:SetTextColor(Chatlog.Colors["BLACK"])
    dbUseMySQL:SetChecked(localConfig.database_use_mysql)
    dbUseMySQL:Dock(TOP)
    dbUseMySQL:DockMargin(5, 0, 5, 5)

    function dbUseMySQL:OnChange(val)
        localConfig.database_use_mysql = val
        if (val) then
            mySqlConfig:DoClick(true)
        end
    end

    local dbDayLimit = serverView:Add("DNumSlider")
    dbDayLimit:SetText(Chatlog.Translate("AdminServerDayLimit"))
    dbDayLimit:SetDark(true)
    dbDayLimit:Dock(TOP)
    dbDayLimit:DockMargin(5, 0, 5, 5)
    dbDayLimit:SetDecimals(0)
    dbDayLimit:SetMin(1)
    dbDayLimit:SetMax(60)
    dbDayLimit:SetValue(localConfig.database_day_limit)

    function dbDayLimit:OnValueChanged(val)
        localConfig.database_day_limit = math.Round(val)
    end

    local function updateData(group, resetUsergroups)
        if resetUsergroups then
            usergroups:Clear()

            for k, _ in pairs(localConfig.privileges) do
                if not localConfig.privileges[k].markedForDeletion then
                    usergroups:AddLine(k)
                end
            end
        end

        if group then
            groupName:SetText(string.format(Chatlog.Translate("AdminPrivilegeEditing"), group))

            readPresent:SetText(readPresent:GetOptionTextByData(tostring(localConfig.privileges[group]["can_read_current_round"])))

            readTeam:SetChecked(localConfig.privileges[group]["can_read_team_messages"])

            readDead:SetChecked(localConfig.privileges[group]["can_read_dead_players"])

            searchByDate:SetChecked(localConfig.privileges[group]["can_search_old_logs_by_date"])

            readPresent:SetEnabled(true)
            readTeam:SetEnabled(true)
            readDead:SetEnabled(true)
            searchByDate:SetEnabled(true)
        end

        quickKeybind:SetChecked(localConfig.keybind)
        dbUseMySQL:SetChecked(localConfig.database_use_mysql)
        dbDayLimit:SetValue(localConfig.database_day_limit)
    end

    usergroups.OnRowSelected = function(_, _, row)
        selGroup = row:GetValue(1)
        updateData(selGroup, false)
    end

    usergroups.OnRowRightClick = function(list, id, line)
        local group = line:GetColumnText(1)
        local menu = DermaMenu()

        menu:AddOption(Chatlog.Translate("AdminCopyGroup"), function()
            SetClipboardText(group)
            chat.AddText(Chatlog.Colors["WHITE"], Chatlog.Translate("AdminCopiedGroup"))
        end):SetIcon("icon16/page_copy.png")

        if group ~= LocalPlayer():GetUserGroup() and group ~= "user" then
            menu:AddOption(Chatlog.Translate("AdminDeleteGroup"), function()
                localConfig.privileges[group] = {
                    ["markedForDeletion"] = true
                }

                usergroups:RemoveLine(id)
            end):SetIcon("icon16/cross.png")
        end

        menu:Open()
    end

    tabs:AddSheet(Chatlog.Translate("AdminTab"), managerPanel, "icon16/application_xp_terminal.png")
end
