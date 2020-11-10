function Chatlog.DrawSettings(tabs)
	-- Settings tab
	local settingsPanel = vgui.Create("DPanel")
	settingsPanel:SetSize(tabs:GetWide() - 10, tabs:GetTall() - 50)
	settingsPanel:SetPos(5, 50)
	settingsPanel:SetBackgroundColor(Color(0,0,0,0))

	-- Create a DForm
	local languageForm = vgui.Create("DForm", settingsPanel)
	languageForm:SetSize(settingsPanel:GetWide() - 10, tabs:GetTall() - 30)
	languageForm:SetName(ChatlogTranslate(GetChatlogLanguage, "LanguageTab"))
	languageForm:Dock(FILL)
	languageForm:DockMargin(5, 5, 5, 5)

	-- DComboBox for language selection
	local languageSelect = vgui.Create("DComboBox")
	for k in pairs(ChatlogLanguage) do
		languageSelect:AddChoice(string.upper(string.sub(k, 1, 1)) .. string.sub(k, 2, 100))
	end

	languageSelect:ChooseOption(string.upper(string.sub(GetConVar("chatlog_language"):GetString(), 1, 1)) .. string.sub(GetConVar("chatlog_language"):GetString(), 2, 100))

	-- On select, change language CVar and update GetChatlogLanguage
	languageSelect.OnSelect = function(panel, index, value, data, Chatlog)
        local currentLanguage = GetConVar("chatlog_language"):GetString()
        local newLang = string.lower(value)
        if currentLanguage == newLang then return end
        GetChatlogLanguage = newLang
        RunConsoleCommand("chatlog_language", newLang)
    end

	languageForm:SetSize(settingsPanel:GetWide() - 10, tabs:GetTall() - 30)
	languageForm:SetName(ChatlogTranslate(GetChatlogLanguage, "LanguageTab"))
	languageForm:Dock(FILL)
	languageForm:DockMargin(5, 5, 5, 5)

	-- Chatlog versioning and licensing label
    local versioning = vgui.Create("DLabel")
	versioning:SetTextColor(Color(0,0,0))
	versioning:SetFont("ChatlogVersioning")
	versioning:SetText(ChatlogTranslate(GetChatlogLanguage,"Licensing"))
	versioning:SizeToContents()

	-- Add all elements
    languageForm:AddItem(languageSelect)
    languageForm:AddItem(versioning)
    languageForm:AddItem(community)

    -- Add tab
	tabs:AddSheet(ChatlogTranslate(GetChatlogLanguage, "SettingsTab"), settingsPanel, false, false)
end