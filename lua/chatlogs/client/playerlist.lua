local function onlyFirstLetterCapital(str)
    return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

function Chatlog.DrawPlayerList(parent, y, height)

    if (not IsValid(parent)) then return end

    parent.playerList = vgui.Create("DPanel", parent)
    local panel = parent.playerList

    panel:SetSize(570, 140)
    panel:SetPos(580, y)

    panel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(172, 172, 172))
    end

    local title = vgui.Create("DLabel", panel)
    title:SetText(Chatlog.Translate("PlayerList"))
    title:SetFont("ChatlogMessageLabel")
    title:SetTextColor(Color(0, 0, 0))
    title:SetPos(10, 5)

    local listview = vgui.Create("DListView", panel)
    listview:SetSize(550, 100)
    listview:SetPos(10, 30)
    listview:SetMultiSelect(false)
    listview:AddColumn(Chatlog.Translate("PlayerListName"))
    listview:AddColumn("SteamID")
    listview:AddColumn(Chatlog.Translate("Role"))
    listview:AddLine(Chatlog.Translate("SelectARound"), "")

    hook.Add("ChatlogRoundLoaded", "ChatlogPlayerList", function(round)
        listview:Clear()

        if (not round.Players) then round.Players = {} end
        local rolestr

        for k, v in pairs(round.Players) do

            rolestr = onlyFirstLetterCapital(Chatlog.Translate(Chatlog.roleStrings[v.role]))

            local line = listview:AddLine(v.nick, k, rolestr)

            line.OnRightClick = function()
                local contextMenu = DermaMenu()
                local contextOption

                contextOption = contextMenu:AddOption(string.format(Chatlog.Translate("GetSteamID"), v.nick), function()
                    SetClipboardText(k)
                    chat.AddText(Chatlog.Colors["WHITE"], string.format(Chatlog.Translate("CopiedSteamID"), v.nick, k))
                end)

                contextOption:SetIcon("icon16/key.png")
                contextMenu:Open()
            end

        end

        if (table.Count(round.Players) < 1) then
            listview:AddLine(Chatlog.Translate("PlayerListNoPlayers"), "")
        end
    end)

    function panel.showPlayers()
        panel.showing = true
        panel:SetVisible(true)
        panel:MoveTo(5, y, 0.2, 0, 1, function() end)
    end

    function panel.hidePlayers()
        panel.showing = false
        panel:MoveTo(580, y, 0.2, 0, 1, function() panel:SetVisible(false) end)
    end

end