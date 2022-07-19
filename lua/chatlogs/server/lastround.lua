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

    local round = Chatlog.Rounds[GetGlobalInt("ChatlogRoundNumber")]

    local log = round.Log
    log = util.TableToJSON(log)

    local players = round.Players
    players = util.TableToJSON(players)

    sql.Begin()

    Chatlog.Query("DELETE FROM chatlog_v2_lastround WHERE id = 1")

    Chatlog.Query(string.format("INSERT INTO chatlog_v2_lastround (id, map, unix, log, players, code) VALUES (1, %s, %s, %s, %s %s);",
        SQLStr(round.map),
        round.unix,
        SQLStr(log),
        SQLStr(players),
        SQLStr(round.code)
    ))

    sql.Commit()

end)