-- This function is in charge of loading a round into the listview and informing files of relevant information

-- Format seconds into an easy to read timestamp
function Chatlog.FormatTime(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00"
    else
        local mins = string.format("%02.f", math.floor(seconds / 60))
        local secs = string.format("%02.f", math.floor(seconds - mins * 60))

        return mins .. ":" .. secs
    end
end

function Chatlog.LoadRound(round, isOld)

    local loglist = Chatlog.chatLogList

    if (not IsValid(loglist)) then return end

    local playerList = round.Players
    local log = round.Log

    loglist:Clear()

    local foundError = false

    -- Handle error codes from the server
    -- 144: Unauthorized reading of current round logs
    -- 404: Empty logs / No round found
    if log[1] == nil or tonumber(log[1]["role"]) == 404 then
        loglist:AddLine(" N/A", "Chatlog", Chatlog.Translate("EmptyLog"))

        foundError = true
    elseif tonumber(log[1]["role"]) == 144 then
        loglist:AddLine(" N/A", "Chatlog", Chatlog.Translate("CantReadPresent"))
        loglist:AddLine(" N/A", "Chatlog", Chatlog.Translate("NoFilterChosen"))

        foundError = true
    end

    Chatlog.ClearTextPanel()

    if (not foundError) then
        for i = 1, #log do
            local v = log[i]
            local isValid = true

            -- Filtering and privileges

            if ((not Chatlog:CanReadTeam() and v["teamChat"]) or (not Chatlog:CanReadDead() and v.role == "spectator")) then isValid = false end

            -- if (plyFilter ~= nil and playerList[v.steamID].nick ~= plyFilter) then isValid = false end

            if (Chatlog.Filters.team and not v["teamChat"]) then isValid = false end

            if (Chatlog.Filters.hideDead and v.role == "spectator") then isValid = false end

            if (isValid and Chatlog.Filters.text.enabled and not table.IsEmpty(Chatlog.Filters.text.strings)) then
                local show = false

                for _, substr in ipairs(Chatlog.Filters.text.strings) do
                    if (string.find(v.text, substr:lower()) ~= nil) then show = true end
                end

                if (not show) then isValid = false end
            end

            if (isValid and Chatlog.Filters.players.enabled and not table.IsEmpty(Chatlog.Filters.players.steamids)) then
                isValid = Chatlog.Filters.players.steamids[v.steamID].show
            end

            if (isValid and Chatlog.Filters.roles.enabled and not Chatlog.Filters.roles[v.role]) then
                isValid = false
            end

            if isValid then
                print(v.curtime, round.curtime)
                print(Chatlog.FormatTime(v.curtime - round.curtime))

                local lineMessage = v["text"]
                local lineNick = playerList[v.steamID]["nick"]
                local lineRole = v["role"]
                local lineTimestamp = Chatlog.FormatTime(v.curtime - round.curtime)
                local lineSteamID = v["steamID"]

                if (v["teamChat"] or lineRole == "spectator") then
                    lineAuthor = string.format("(%s) %s", string.upper(Chatlog.Translate(lineRole)), lineNick)
                end

                local line = loglist:AddLine(lineTimestamp, lineNick, lineMessage, v.curtime)

                -- Paint team and dead chat lines
                if (v["teamChat"] == true or lineRole == "spectator") then
                    function line:PaintOver(w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Chatlog.GetColor("highlight", lineRole))
                    end
                end

                line.OnRightClick = function()
                    local contextMenu = DermaMenu()
                    local contextOption

                    -- Copy message to clipboard
                    -- example: [01:23] actuallyNothing: hello
                    contextOption = contextMenu:AddOption(Chatlog.Translate("ClipboardCopy"), function()
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
                    Chatlog.UpdateTextPanel(round, v)
                end
            end
        end
    end

    if (#loglist:GetLines() < 1) then
        loglist:AddLine(" N/A", "Chatlog", Chatlog.Translate("EmptyLogFilters"))
    end

    loglist:SortByColumn(4, false)

    if (isOld) then Chatlog.Menu.roundFilter:SetText("Old Chatlog round") end

    hook.Run("ChatlogRoundLoaded", round)

end
