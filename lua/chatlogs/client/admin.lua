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
    usergroups:AddColumn("Usergroups")
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
    addGroup:SetText("New group")

    addGroup.DoClick = function()
        local addGroupFrame = self.Menu:Add("DFrame")
        addGroupFrame:SetBackgroundBlur(true)
        addGroupFrame:SetDraggable(false)
        addGroupFrame:Center()
        addGroupFrame:SetSize(245, 100)
        addGroupFrame:SetTitle("Adding a group")
        addGroupFrame:ShowCloseButton(false)
        addGroupFrame:MakePopup()
        local title = addGroupFrame:Add("DLabel")
        title:SetText("Enter the name for the new group:")
        title:Dock(TOP)
        title:DockMargin(5, 0, 5, -5)
        local groupEntry = addGroupFrame:Add("DTextEntry")
        groupEntry:Dock(TOP)
        groupEntry:DockMargin(5, 5, 5, 5)
        local w, h = addGroupFrame:GetWide() / 2 - 10, 20
        local confirm = addGroupFrame:Add("DButton")
        confirm:SetSize(w, h)
        confirm:SetPos(5, 75)
        confirm:SetText("Add Group")

        confirm.DoClick = function()
            local group = groupEntry:GetText()

            if localConfig.privileges[group] ~= nil then
                addGroupFrame:Close()
                chat.AddText(Chatlog.Colors["YELLOW"], "Error adding group: ", Chatlog.Colors["WHITE"], "That group already exists!")
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
        cancel:SetText("Cancel")

        cancel.DoClick = function()
            addGroupFrame:Close()
        end
    end

    local mySqlConfig = sidebar:Add("DButton")
    mySqlConfig:Dock(TOP)
    mySqlConfig:DockMargin(5, 0, 5, 5)
    mySqlConfig:SetText("MySQL settings")

    local commit = sidebar:Add("DButton")
    commit:Dock(TOP)
    commit:DockMargin(5, 0, 5, 5)
    commit:SetText("Save changes")

    commit.DoClick = function()
        local confirmFrame = self.Menu:Add("DFrame")
        confirmFrame:SetSize(245, 90)
        confirmFrame:SetBackgroundBlur(true)
        confirmFrame:SetDraggable(false)
        confirmFrame:Center()
        confirmFrame:SetTitle("Commit configuration changes")
        confirmFrame:ShowCloseButton(false)
        local warn = confirmFrame:Add("DLabel")
        warn:SetText("Commiting changes will re-send the configuration\nfile to all players. Confirm?")
        warn:SetColor(Chatlog.Colors["YELLOW"])
        warn:SizeToContents()
        warn:Dock(TOP)
        local w, h = confirmFrame:GetWide() / 2 - 10, 20
        local confirm = confirmFrame:Add("DButton")
        confirm:SetSize(w, h)
        confirm:SetPos(5, 65)
        confirm:SetText("Confirm")
        confirm:SetColor(Chatlog.Colors["MAGENTA"])

        confirm.DoClick = function()
            chat.AddText(Chatlog.Colors["YELLOW"], "Commiting...")
            confirmCommit(localConfig)
            confirmFrame:Close()

            if Chatlog.Menu:IsValid() then
                Chatlog.Menu:Close()
            end
        end

        local cancel = confirmFrame:Add("DButton")
        cancel:SetSize(w, h)
        cancel:SetPos(confirmFrame:GetWide() - w - 5, 65)
        cancel:SetText("Cancel")

        cancel.DoClick = function()
            confirmFrame:Close()
        end
    end

    -- Privilege settings 

    local groupView = managerPanel:Add("DPanel")
    groupView:Dock(TOP)
    groupView:DockMargin(0, 5, 5, 5)
    groupView:SetHeight(130)
    groupView:SetBackgroundColor(Chatlog.Colors["PANEL_ADMIN_GROUPVIEW"])

    local readPresentLabel = groupView:Add("DLabel")
    readPresentLabel:SetText("Can read messages in the current round:")
    readPresentLabel:Dock(TOP)
    readPresentLabel:DockMargin(5, 25, 5, 5)

    local readPresent = groupView:Add("DComboBox")
    readPresent:SetText("Select a group to edit")
    readPresent:SetDisabled(true)
    readPresent:Dock(TOP)
    readPresent:DockMargin(5, -5, 5, 5)
    readPresent:AddChoice("Always", "true", false, "icon16/accept.png")
    readPresent:AddChoice("Only when dead or spectating", "spec_only", false, "icon16/eye.png")
    readPresent:AddChoice("Never", "false", false, "icon16/delete.png")

    function readPresent:OnSelect(_, _, data)
        -- option data sucks ass holy shit
        if data == "false" or data == "true" then
            data = tobool(data)
        end

        localConfig.privileges[selGroup]["can_read_current_round"] = data
    end

    local readTeam = groupView:Add("DCheckBoxLabel")
    readTeam:SetText("Can read team chat messages (traitor and detective)")
    readTeam:SetDisabled(true)
    readTeam:Dock(TOP)
    readTeam:DockMargin(5, 0, 5, 5)

    function readTeam:OnChange(val)
        localConfig.privileges[selGroup]["can_read_team_messages"] = val
    end

    local readDead = groupView:Add("DCheckBoxLabel")
    readDead:SetText("Can read messages from dead players / spectators")
    readDead:SetDisabled(true)
    readDead:Dock(TOP)
    readDead:DockMargin(5, 0, 5, 5)

    function readDead:OnChange(val)
        localConfig.privileges[selGroup]["can_read_dead_players"] = val
    end

    local groupViewTitle = groupView:Add("DLabel")
    groupViewTitle:SetText("Privilege configuration")
    groupViewTitle:SetFont("ChatlogPanelTitle")
    groupViewTitle:SizeToContents()
    groupViewTitle:SetColor(Chatlog.Colors["WHITE"])
    groupViewTitle:SetPos(6, 3)

    local groupName = groupView:Add("DLabel")
    groupName:Dock(BOTTOM)
    groupName:DockMargin(5, 0, 0, 5)
    groupName:Center()
    groupName:SetText("Select a group to edit.")
    groupName:SetColor(Chatlog.Colors["YELLOW"])
    groupName:SizeToContents()

    -- Server settings

    local serverView = managerPanel:Add("DPanel")
    serverView:Dock(FILL)
    serverView:DockMargin(0, 0, 5, 5)
    serverView:SetBackgroundColor(Chatlog.Colors["PANEL_ADMIN_SERVERVIEW"])

    local serverViewTitle = serverView:Add("DLabel")
    serverViewTitle:SetText("Server configuration")
    serverViewTitle:SetFont("ChatlogPanelTitle")
    serverViewTitle:SizeToContents()
    serverViewTitle:SetColor(Chatlog.Colors["BLACK"])
    serverViewTitle:SetPos(6, 3)
    
    local quickKeybind = serverView:Add("DCheckBoxLabel")
    quickKeybind:SetText("Enable opening Chatlog window with F7")
    quickKeybind:SetTooltip("When disabled, users must use the 'chatlog' console command to open the menu.")
    quickKeybind:SetTextColor(Chatlog.Colors["BLACK"])
    quickKeybind:SetChecked(localConfig.keybind)
    quickKeybind:Dock(TOP)
    quickKeybind:DockMargin(5, 25, 5, 5)

    function quickKeybind:OnChange(val)
        localConfig.keybind = val
    end

    local dbUseMySQL = serverView:Add("DCheckBoxLabel")
    dbUseMySQL:SetText("Use MySQL")
    dbUseMySQL:SetTooltip("When disabled, the server will use its SQLite database for any queries.")
    dbUseMySQL:SetTextColor(Chatlog.Colors["BLACK"])
    dbUseMySQL:SetChecked(localConfig.database_use_mysql)
    dbUseMySQL:Dock(TOP)
    dbUseMySQL:DockMargin(5, 0, 5, 5)

    function dbUseMySQL:OnChange(val)
        localConfig.database_use_mysql = val
    end

    local dbDayLimit = serverView:Add("DNumSlider")
    dbDayLimit:SetText("Database entries day limit")
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
            groupName:SetText(string.format("Editing: (%s)", group))
            -- readPresent:SetEnabled(true)
            readPresent:SetText(readPresent:GetOptionTextByData(tostring(localConfig.privileges[group]["can_read_current_round"])))
            -- readTeam:SetEnabled(true)
            readTeam:SetChecked(localConfig.privileges[group]["can_read_team_messages"])
            -- readDead:SetEnabled(true)
            readDead:SetChecked(localConfig.privileges[group]["can_read_dead_players"])

            if group == "superadmin" and LocalPlayer():GetUserGroup() ~= group then
                readPresent:SetEnabled(false)
                readTeam:SetEnabled(false)
                readDead:SetEnabled(false)
            else
                readPresent:SetEnabled(true)
                readTeam:SetEnabled(true)
                readDead:SetEnabled(true)
            end
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

        menu:AddOption("Copy this group's name to clipboard", function()
            SetClipboardText(group)
            chat.AddText(Chatlog.Colors["WHITE"], "Copied groupname to clipboard!")
        end):SetIcon("icon16/page_copy.png")

        if group ~= LocalPlayer():GetUserGroup() and group ~= "user" then
            menu:AddOption("Delete this group", function()
                localConfig.privileges[group] = {
                    ["markedForDeletion"] = true
                }

                usergroups:RemoveLine(id)
            end):SetIcon("icon16/cross.png")
        end

        menu:Open()
    end

    tabs:AddSheet("Manage", managerPanel, "icon16/application_xp_terminal.png")
end
