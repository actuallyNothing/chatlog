-- This function is in charge of loading a round into the listview
function Chatlog:LoadRound(round, loglist, textPanel, plyFilter, playerFilter)
    local client = LocalPlayer()
    local playerList = {}
    loglist:Clear()

    -- Handle error codes from the server
    -- 144: Unauthorized reading of current round logs
    -- 404: Empty logs / No round found
    if round[1] == nil or tonumber(round[1]["role"]) == 404 then
        loglist:AddLine(" N/A", "Chatlog", Chatlog.Translate("EmptyLog"))

        return false
    elseif tonumber(round[1]["role"]) == 144 then
        loglist:AddLine(" N/A", "Chatlog", Chatlog.Translate("CantReadPresent"))
        loglist:AddLine(" N/A", "Chatlog", Chatlog.Translate("NoFilterChosen"))

        return false
    end

    Chatlog.ClearTextPanel()

    for i = #round, 1, -1 do
        v = round[i]
        local isValid = true

        -- Filtering and privileges
        if v["teamChat"] and not self:CanReadTeam(client) or v["role"] == "spectator" and not self:CanReadDead(client) then
            isValid = false
        elseif plyFilter ~= nil and v["playerNick"] ~= plyFilter then
            isValid = false
        elseif GetConVar("chatlog_hide_dead"):GetBool() and v["role"] == "spectator" then
            isValid = false
        end

        if isValid then
            local lineMessage = v["text"]
            local lineNick = v["playerNick"]
            local lineRole = v["role"]
            local lineTimestamp = v["timestamp"]
            local lineSteamID = v["steamID"]
            -- Only using this variable for full text display
            local lineAuthor = lineNick

            if v["teamChat"] or lineRole == "spectator" then
                lineAuthor = string.format("(%s) %s", string.upper(Chatlog.Translate(lineRole)), lineNick)
            end

            local line
            line = loglist:AddLine(lineTimestamp, lineNick, lineMessage, chat_teamChat)

            -- Paint team and dead chat lines
            if v["teamChat"] == true or lineRole == "spectator" then
                function line:PaintOver(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Chatlog.GetColor("highlight", lineRole))
                end
            end

            line.OnRightClick = function()
                local contextMenu = DermaMenu()

                -- Copy message to clipboard
                -- example: [01:23] actuallyNothing: hello
                local contextOption = contextMenu:AddOption(Chatlog.Translate("ClipboardCopy"), function()
                    SetClipboardText(string.format("[%s] %s: %s", lineTimestamp, lineNick, lineMessage))
                    chat.AddText(Chatlog.Colors["WHITE"], Chatlog.Translate("ClipboardCopied"))
                end)

                contextOption:SetIcon("icon16/comment.png")

                -- Copy player's SteamID
                contextOption = contextMenu:AddOption(string.format(Chatlog.Translate("GetSteamID"), lineNick), function()
                    SetClipboardText(lineSteamID)
                    chat.AddText(Chatlog.Colors["WHITE"], string.format(Chatlog.Translate("CopiedSteamID"), lineNick, lineSteamID))
                end)

                contextOption:SetIcon("icon16/key.png")
                contextMenu:Open()
            end

            -- Set the "selected message" text labels
            line.OnSelect = function()
                textPanel.author:SetText(string.format("%s:", lineAuthor))
                textPanel.timestamp:SetText(string.format("[%s]", lineTimestamp))
                -- Color the author's name with their role (if they're alive)
                textPanel.author:SetTextColor(Chatlog.GetColor("role", lineRole))
                textPanel.fulltext:SetText(lineMessage)
                textPanel.author:SizeToContents()
            end

            -- Add player
            if playerList[lineNick] == nil then
                playerList[lineNick] = lineNick .. " (" .. lineSteamID .. ")"
            end
        end
    end

    -- Add players to player filter
    -- if a filter is already selected, only "Remove Filter" option is available
    playerFilter:Clear()

    if not plyFilter then
        for _, v in pairs(playerList) do
            playerFilter:AddChoice(v, nil, false, "icon16/user.png")
        end

        playerFilter:AddChoice(Chatlog.Translate("PlayerFilterNone"), nil, true, "icon16/cancel.png")
    else
        playerFilter:AddChoice(Chatlog.Translate("PlayerFilterRemove"), nil, true, "icon16/cancel.png")
    end

    loglist:SortByColumn(1, false)
end
