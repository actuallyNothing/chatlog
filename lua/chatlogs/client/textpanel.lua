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

function Chatlog.DrawTextPanel(textPanel, chatlogTab)

    -- Full text panel
    textPanel.frame = vgui.Create("DPanel", chatlogTab)
    textPanel.frame:Dock(BOTTOM)
    textPanel.frame:DockMargin(5, 2, 5, 0)
    textPanel.frame:SetHeight(80)
    textPanel.frame:SetBackgroundColor(Chatlog.Colors["TEXTPANEL_BACKGROUND"])

    -- Full text
    textPanel.richText = vgui.Create("RichText", textPanel.frame)
    textPanel.richText:Dock(FILL)
    textPanel.richText:DockMargin(7, 5, 7, 5)
    textPanel.richText:SetVerticalScrollbarEnabled(true)

    function textPanel.richText:PerformLayout()
        self:SetFontInternal( "ChatFont" )
        self:SetFGColor( color_white )
    end

    function Chatlog.ClearTextPanel()
        textPanel.richText:SetText("")

        textPanel.richText:InsertColorChange(255, 255, 255, 255)
        textPanel.richText:AppendText("[00:00] ")
        textPanel.richText:InsertColorChange(255, 255, 0, 255)
        textPanel.richText:AppendText("Message Information\n")
        textPanel.richText:InsertColorChange(0, 255, 0, 255)
        textPanel.richText:AppendText("Chatlog: ")
        textPanel.richText:InsertColorChange(255, 255, 255, 255)
        textPanel.richText:AppendText("Select a message to display here!")
    end

    function Chatlog.UpdateTextPanel(log, player, author)
        textPanel.richText:SetText("")

        textPanel.richText:InsertColorChange(255, 255, 255, 255)
        textPanel.richText:AppendText(string.format("[%s] ", log.timestamp))
        textPanel.richText:InsertColorChange(unpack(textColors[log.role]))
        textPanel.richText:AppendText(log.role:upper() .. " to " .. (log.teamChat and "TEAM" or "ALL") .. ":\n")

        if (log.teamChat) then
            textPanel.richText:InsertColorChange(unpack(textColors[log.role]))
            textPanel.richText:AppendText(string.format("(%s) ", log.role:upper()))
            textPanel.richText:InsertColorChange(unpack(textColors["name_" .. log.role]))
            textPanel.richText:AppendText(player.nick .. ": ")
            textPanel.richText:InsertColorChange(unpack(textColors["text_" .. log.role]))
            textPanel.richText:AppendText(log.text)

            return
        end

        if (log.role == "spectator") then
            textPanel.richText:InsertColorChange(255, 0, 0, 255)
            textPanel.richText:AppendText("*DEAD* ")
            textPanel.richText:InsertColorChange(unpack(textColors["name_spectator"]))
            textPanel.richText:AppendText(player.nick .. ": ")
            textPanel.richText:InsertColorChange(255, 255, 255, 255)
            textPanel.richText:AppendText(log.text)

            return
        end

        textPanel.richText:InsertColorChange(unpack(textColors["name_" .. (log.role == "detective" and "detective" or "alive")]))
        textPanel.richText:AppendText(player.nick .. ": ")

        textPanel.richText:InsertColorChange(255, 255, 255, 255)
        textPanel.richText:AppendText(log.text)
    end

    Chatlog.ClearTextPanel()
end
