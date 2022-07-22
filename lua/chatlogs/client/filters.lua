function Chatlog.DrawMoreFilters(parent, y, height)

    if (not IsValid(parent)) then return end

    parent.moreFilters = vgui.Create("DPanel", parent)
    local panel = parent.moreFilters

    panel:SetSize(570, 215)
    panel:SetPos(-575, y)

    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Chatlog.Colors.PANEL_SLIDE)
    end

    local title = vgui.Create("DLabel", panel)
    title:SetText(Chatlog.Translate("FiltersTitle"))
    title:SetFont("ChatlogMessageLabel")
    title:SetTextColor(Chatlog.Colors.BLACK)
    title:SetPos(10, 5)

    local filterTeam = vgui.Create("DCheckBoxLabel", panel)
    filterTeam:SetText(Chatlog.Translate("FiltersOnlyTeam"))
    filterTeam:SetTextColor(Chatlog.Filters.team and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
    filterTeam:SetPos(10, 30)
    filterTeam:SizeToContents()

    local filterRoles = vgui.Create("DCheckBoxLabel", panel)
    filterRoles:SetText(Chatlog.Translate("FiltersRoles"))
    filterRoles:SetTextColor(Chatlog.Colors.BLACK)
    filterRoles:SetPos(10, 50)
    filterRoles:SizeToContents()

    local filterRolesInnocent = vgui.Create("DCheckBoxLabel", panel)
    filterRolesInnocent:SetText(Chatlog.Translate("FiltersRolesInnocent"))
    filterRolesInnocent:SetTextColor(Chatlog.Filters.roles.innocent and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
    filterRolesInnocent:SetPos(25, 70)
    filterRolesInnocent:SizeToContents()

    local filterRolesTraitor = vgui.Create("DCheckBoxLabel", panel)
    filterRolesTraitor:SetText(Chatlog.Translate("FiltersRolesTraitor"))
    filterRolesTraitor:SetTextColor(Chatlog.Colors.BLACK)
    filterRolesTraitor:SetPos(25, 90)
    filterRolesTraitor:SizeToContents()

    local filterRolesDetective = vgui.Create("DCheckBoxLabel", panel)
    filterRolesDetective:SetText(Chatlog.Translate("FiltersRolesDetective"))
    filterRolesDetective:SetTextColor(Chatlog.Colors.BLACK)
    filterRolesDetective:SetPos(25, 110)
    filterRolesDetective:SizeToContents()

    local hideRadioCommands = vgui.Create("DCheckBoxLabel", panel)
    hideRadioCommands:SetText(Chatlog.Translate("FiltersHideRadio"))
    hideRadioCommands:SetTextColor(Chatlog.Filters.hideRadio and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
    hideRadioCommands:SetPos(10, 130)
    hideRadioCommands:SizeToContents()

    filterTeam.OnChange = function(self, val)
        Chatlog.Filters.team = val
        filterTeam:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)

        if (val and Chatlog.Filters.roles.innocent) then
            filterRolesInnocent:SetValue(false)
            Chatlog.Filters.roles.innocent = false
        end
    end

    filterRoles.OnChange = function(self, val)
        Chatlog.Filters.roles.enabled = val
        filterRoles:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)

        filterRolesInnocent:SetEnabled(val)
        filterRolesTraitor:SetEnabled(val)
        filterRolesDetective:SetEnabled(val)
    end

    filterRolesInnocent.OnChange = function(self, val)
        Chatlog.Filters.roles.innocent = val
        filterRolesInnocent:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)

        if (val and Chatlog.Filters.team) then
            filterTeam:SetValue(false)
            Chatlog.Filters.team = false
        end
    end

    filterRolesTraitor.OnChange = function(self, val)
        Chatlog.Filters.roles.traitor = val
        filterRolesTraitor:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
    end

    filterRolesDetective.OnChange = function(self, val)
        Chatlog.Filters.roles.detective = val
        filterRolesDetective:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
    end

    hideRadioCommands.OnChange = function(self, val)
        Chatlog.Filters.hideRadio = val
        hideRadioCommands:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
    end

    filterTeam:SetValue(Chatlog.Filters.team)
    filterRoles:SetValue(Chatlog.Filters.roles.enabled)
    hideRadioCommands:SetValue(Chatlog.Filters.hideRadio)
    filterRolesInnocent:SetValue(Chatlog.Filters.roles.innocent)
    filterRolesTraitor:SetValue(Chatlog.Filters.roles.traitor)
    filterRolesDetective:SetValue(Chatlog.Filters.roles.detective)
    filterRolesInnocent:SetEnabled(Chatlog.Filters.roles.enabled)
    filterRolesTraitor:SetEnabled(Chatlog.Filters.roles.enabled)
    filterRolesDetective:SetEnabled(Chatlog.Filters.roles.enabled)

    local filterText = vgui.Create("DCheckBoxLabel", panel)
    filterText:SetText(Chatlog.Translate("FiltersOnlySubstringsTitle"))
    filterText:SetTextColor(Chatlog.Colors.BLACK)
    filterText:SetPos(10, 150)
    filterText:SizeToContents()

    local filterTextEntry = vgui.Create("DTextEntry", panel)
    filterTextEntry:SetPos(10, 170)
    filterTextEntry:SetSize(300, 20)
    filterTextEntry:SetPlaceholderText(Chatlog.Translate("FiltersOnlySubstringsPlaceholder"))
    filterTextEntry:SetEditable(true)

    filterText.OnChange = function(self, val)
        Chatlog.Filters.text.enabled = val
        filterText:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
        filterTextEntry:SetEnabled(val)
    end

    filterText:SetValue(Chatlog.Filters.text.enabled)
    filterTextEntry:SetEnabled(Chatlog.Filters.text.enabled)

    filterTextEntry.OnChange = function(self)
        local text = self:GetValue()
        if (not text) then return end

        local strings = string.Explode(",", text)
        for k, v in ipairs(strings) do
            strings[k] = string.Trim(v)
            if (not strings[k] or strings[k] == "") then
                table.remove(strings, k)
            end
        end
        Chatlog.Filters.text.strings = strings
    end

    local filterTextTip = vgui.Create("DLabel", panel)
    filterTextTip:SetText(Chatlog.Translate("FiltersOnlySubstringsTip"))
    filterTextTip:SetTextColor(Chatlog.Colors.BLACK)
    filterTextTip:SetPos(10, 195)
    filterTextTip:SizeToContents()

    local filterPlayers = vgui.Create("DCheckBoxLabel", panel)
    filterPlayers:SetText(Chatlog.Translate("FiltersPlayers"))
    filterPlayers:SetTextColor(Chatlog.Colors.BLACK)
    filterPlayers:SetPos(320, 10)
    filterPlayers:SizeToContents()

    local filterPlayersList = vgui.Create("DListView", panel)
    filterPlayersList:SetPos(320, 30)
    filterPlayersList:SetSize(240, 160)
    filterPlayersList:AddColumn(""):SetFixedWidth(16)
    filterPlayersList:AddColumn("Player")
    filterPlayersList:SetMultiSelect(false)
    filterPlayersList:SetHideHeaders(true)

    filterPlayers.OnChange = function(self, val)
        Chatlog.Filters.players.enabled = val
        filterPlayers:SetTextColor(val and Chatlog.Colors.YELLOW or Chatlog.Colors.BLACK)
        filterPlayersList:SetEnabled(val)
    end

    filterPlayers:SetValue(Chatlog.Filters.players.enabled)

    filterPlayersList:AddLine("", Chatlog.Translate("SelectARound"))

    hook.Add("ChatlogRoundLoaded", "ChatlogAddPlayersToPlayerFilter", function(round)
        filterPlayersList:Clear()
        for k, v in pairs(round.Players) do
            Chatlog.Filters.players.steamids[k] = {
                nick = v.nick,
                show = Chatlog.Filters.players.steamids[k] and Chatlog.Filters.players.steamids[k].show or false
            }
        end

        for k, v in pairs(Chatlog.Filters.players.steamids) do
            local line = filterPlayersList:AddLine("", v.nick)
            line.showPlayer = v.show
            line.icon = vgui.Create("DImage", line)
            line.icon:SetImage(line.showPlayer and "icon16/accept.png" or "icon16/cancel.png")
            line.icon:SetSize(16, 16)
            line.icon:SetPos(0, 1)

            line.OnMousePressed = function(self, code)
                if (code == MOUSE_LEFT) then
                    self.showPlayer = not self.showPlayer
                    Chatlog.Filters.players.steamids[k].show = self.showPlayer

                    self.icon:SetImage(line.showPlayer and "icon16/accept.png" or "icon16/cancel.png")
                end
            end
        end

        if (#filterPlayersList:GetLines() < 1) then
            filterPlayersList:AddLine("", Chatlog.Translate("FiltersPlayersNoPlayersFound"))
        end
    end)

    function panel.showFilters()
        if (panel.showing) then return end

        panel.showing = true
        panel:SetVisible(true)
        panel:MoveTo(5, y, 0.2, 0, 1, function() end)

        if (IsValid(Chatlog.Menu)) then
            Chatlog.Menu:SetKeyboardInputEnabled(true)
        end
    end

    function panel.hideFilters()
        if (not panel.showing) then return end

        panel.showing = false
        panel:MoveTo(-575, y, 0.2, 0, 1, function() panel:SetVisible(false) end)

        if (IsValid(Chatlog.Menu)) then
            Chatlog.Menu:SetKeyboardInputEnabled(false)
        end
    end

end