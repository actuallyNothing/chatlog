Chatlog.LastRoundPrevMap = Chatlog.LastRoundMap or {}

function Chatlog.LastRoundPrevMapSetup()

    local q = Chatlog.Query("SELECT * FROM chatlog_v2_lastround ORDER BY id DESC LIMIT 1")

    if (q and q[1]) then
        local round = q[1]

        round.Log = util.JSONToTable(round.log)
        round.log = nil

        round.Players = util.JSONToTable(round.players)
        round.players = nil

        Chatlog.LastRoundPrevMap = round

        SetGlobalBool("ChatlogLastMapExists", true)
    else
        SetGlobalBool("ChatlogLastMapExists", false)
    end

end

hook.Add("TTTEndRound", "ChatlogLastRound", function()

    local code = Chatlog.Rounds[GetGlobalInt("ChatlogRoundNumber")].code

    Chatlog.Query("DELETE FROM chatlog_v2_lastround", function(_, data)

        Chatlog.Query(string.format("INSERT INTO chatlog_v2_lastround (code) VALUES (\'%s\');",
            SQLStr(code)
        ))

    end)

end)