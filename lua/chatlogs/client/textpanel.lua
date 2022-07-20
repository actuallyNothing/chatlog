local textColors = {
    innocent = {0, 255, 0, 255},
    traitor = {255, 0, 0, 255},
    detective = {64, 64, 255, 255},
    spectator = {200, 200, 200, 255},

    name_alive = {0, 201, 0, 255},
    name_traitor = {255, 201, 12, 255},
    name_detective = {18, 201, 255, 255},
    name_spectator = {255, 255, 0, 255},

    text_traitor = {255, 255, 201, 255},
    text_detective = {201, 255, 255, 255},
}

function Chatlog.DrawTextPanel(chatlogTab)

    -- Full text panel
    local frame = vgui.Create("DPanel", chatlogTab)
    frame:Dock(BOTTOM)
    frame:DockMargin(5, 2, 5, 0)
    frame:SetHeight(80)
    frame:SetBackgroundColor(Chatlog.Colors["TEXTPANEL_BACKGROUND"])

    -- Full text
    local richText = vgui.Create("RichText", frame)
    richText:Dock(FILL)
    richText:DockMargin(7, 5, 7, 5)
    richText:SetVerticalScrollbarEnabled(true)

    function richText:PerformLayout()
        self:SetFontInternal( "ChatFont" )
        self:SetFGColor( color_white )
    end

    function Chatlog.ClearTextPanel()
        richText:SetText("")

        richText:InsertColorChange(255, 255, 255, 255)
        richText:AppendText("[00:00] ")
        richText:InsertColorChange(255, 255, 0, 255)
        richText:AppendText(Chatlog.Translate("TextPanelMessageInfo") .. "\n")
        richText:InsertColorChange(0, 255, 0, 255)
        richText:AppendText("Chatlog: ")
        richText:InsertColorChange(255, 255, 255, 255)
        richText:AppendText(Chatlog.Translate("TextPanelTip"))
    end

    function Chatlog.UpdateTextPanel(round, log)

        local ply = round.Players[log.steamID]

        richText:SetText("")

        richText:InsertColorChange(255, 255, 255, 255)
        richText:AppendText(string.format("[%s] ", Chatlog.FormatTime(log.curtime - round.curtime)))
        richText:InsertColorChange(unpack(textColors[log.role]))
        richText:AppendText(Chatlog.Translate(log.role) .. Chatlog.Translate("TextPanelTo") .. (log.teamChat and Chatlog.Translate("TextPanelTeam") or Chatlog.Translate("TextPanelAll")) .. ":\n")

        if (log.teamChat) then
            richText:InsertColorChange(unpack(textColors[log.role]))
            richText:AppendText(string.format("(%s) ", log.role:upper()))
            richText:InsertColorChange(unpack(textColors["name_" .. log.role]))
            richText:AppendText(ply.nick .. ": ")
            richText:InsertColorChange(unpack(textColors["text_" .. log.role]))
            richText:AppendText(log.text)

            return
        end

        if (log.role == "spectator") then
            richText:InsertColorChange(255, 0, 0, 255)
            richText:AppendText(Chatlog.Translate("TextPanelDeadPrefix"))
            richText:InsertColorChange(unpack(textColors["name_spectator"]))
            richText:AppendText(ply.nick .. ": ")
            richText:InsertColorChange(255, 255, 255, 255)
            richText:AppendText(log.text)

            return
        end

        richText:InsertColorChange(unpack(textColors["name_" .. (log.role == "detective" and "detective" or "alive")]))
        richText:AppendText(ply.nick .. ": ")

        richText:InsertColorChange(255, 255, 255, 255)
        richText:AppendText(log.text)

    end

    Chatlog.ClearTextPanel()
end
