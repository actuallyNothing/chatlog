function Chatlog:DrawSettings(tabs)

    -- Settings tab
    local settingsPanel = vgui.Create("DPanel")
    settingsPanel.Height = 440

    settingsPanel:SetBackgroundColor(Color(0, 0, 0, 0))

    -- Create a DForm
    local languageForm = vgui.Create("DForm", settingsPanel)
    languageForm:SetSize(settingsPanel:GetWide() - 10, tabs:GetTall() - 30)
    languageForm:SetName(self.Translate("LanguageTab"))
    languageForm:Dock(FILL)
    languageForm:DockMargin(5, 5, 5, 5)

    -- DComboBox for language selection
    local languageSelect = vgui.Create("DComboBox")

    for k, v in pairs(ChatlogLanguage) do
        languageSelect:AddChoice(v.DisplayName, k, false, "flags16/" .. v.Flag .. ".png")
    end

    -- Set initial text to current language
    languageSelect:SetValue(ChatlogLanguage[GetConVar("chatlog_language"):GetString()].DisplayName)

    -- On select, change language CVar and update GetChatlogLanguage
    languageSelect.OnSelect = function(panel, index, value, data)

        local currentLanguage = GetConVar("chatlog_language"):GetString()
        local newLang = string.lower(data)

        if (currentLanguage == newLang) then return end
        GetChatlogLanguage = newLang

        RunConsoleCommand("chatlog_language", newLang)
        self.Menu:Close()

        chat.AddText(Color(255, 255, 255), self.Translate("SwitchedLanguage"))
        RunConsoleCommand("chatlog")

    end

    languageForm:SetSize(settingsPanel:GetWide() - 10, tabs:GetTall() - 30)
    languageForm:SetName(self.Translate("LanguageTab"))
    languageForm:Dock(FILL)
    languageForm:DockMargin(5, 5, 5, 5)

    -- Chatlog versioning and licensing label
    local versioning = vgui.Create("DLabel")
    versioning:SetTextColor(Color(0, 0, 0))
    versioning:SetFont("ChatlogVersioning")
    versioning:SetText(self.Translate("Licensing"))
    versioning:SizeToContents()

    -- Add all elements
    languageForm:AddItem(languageSelect)
    languageForm:AddItem(versioning)

    -- Add tab
    tabs:AddSheet(self.Translate("SettingsTab"), settingsPanel, "icon16/cog.png")

end
