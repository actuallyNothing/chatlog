function Chatlog.randomCode()

    -- GreedyTactician @ https://gist.github.com/haggen/2fd643ea9a261fea2094
    local charset = "QWERTYUIOPASDFGHJKLZXCVBNM1234567890"
    local ret = {}
    local r
    for i = 1, 6 do
        r = math.random(1, #charset)
        table.insert(ret, charset:sub(r, r))
    end

    return table.concat(ret)

end

function Chatlog.SaveOldLog(round, roundNumber)

    local log = util.TableToJSON(round.Log)
    local players = util.TableToJSON(round.Players)
    local unix = round.unix
    local map = round.map
    local code = round.code
    local curtime = round.curtime
    local year = os.date("%Y")
    local month = os.date("%m")
    local day = os.date("%d")

    Chatlog.Query(string.format("INSERT INTO chatlog_v2_oldlogs (code, year, month, day, unix, round, curtime, map, log, players) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",

        SQLStr(code),
        year,
        month,
        day,
        unix,
        roundNumber,
        curtime,
        SQLStr(map),
        SQLStr(log),
        SQLStr(players)
    ))

end