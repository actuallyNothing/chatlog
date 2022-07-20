Chatlog.Dates = Chatlog.Dates or {
    oldest = 0,
    latest = 0
}

Chatlog.OldLogsDays = Chatlog.OldLogsDays or {}

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

function Chatlog.OldLogsSetup()

    local entryLimit = os.time() - Chatlog.Config.database_day_limit * 86400

    Chatlog.Query("DELETE FROM chatlog_v2_oldlogs WHERE unix <= " .. entryLimit .. ";", function()

        Chatlog.Query("SELECT MIN(unix), MAX(unix) FROM chatlog_v2_oldlogs;", function(success, data)

            if (not success or not data or table.IsEmpty(data)) then return end
            local oldest, latest = data[1]["MIN(unix)"], data[1]["MAX(unix)"]

            if (oldest == "NULL" or latest == "NULL") then return end

            Chatlog.Dates.oldest = oldest
            Chatlog.Dates.latest = latest

        end)

        Chatlog.Query("SELECT DISTINCT year FROM chatlog_v2_oldlogs;", function(success, data)

            if (not success or not data or table.IsEmpty(data)) then return end

            for _, year in pairs(data[1]) do
                year = tonumber(year)

                if (year) then

                    Chatlog.OldLogsDays[year] = {}

                    Chatlog.Query("SELECT DISTINCT month FROM chatlog_v2_oldlogs WHERE year = " .. year .. ";", function(success, data)

                        if (not success or not data or table.IsEmpty(data)) then return end

                        for _, month in pairs(data[1]) do

                            month = tonumber(month)

                            if (month) then

                                Chatlog.OldLogsDays[year][month] = {}

                                Chatlog.Query("SELECT DISTINCT day FROM chatlog_v2_oldlogs WHERE year = " .. year .. " AND month = " .. month .. ";", function(success, data)
                                    if (not success or not data or table.IsEmpty(data)) then return end

                                    for _, day in pairs(data) do

                                        day = tonumber(day.day)

                                        if (day and day) then
                                            Chatlog.OldLogsDays[year][month][day] = true
                                        end

                                    end

                                end)

                            end

                        end

                    end)

                end
            end

        end)

    end)

end

net.Receive("AskChatlogDates", function(_, ply)

    if not (Chatlog.Dates.oldest or Chatlog.Dates.latest) then return end

    local days = util.Compress(util.TableToJSON(Chatlog.OldLogsDays))

    net.Start("SendChatlogDates")
    net.WriteUInt(Chatlog.Dates.oldest, 32)
    net.WriteUInt(Chatlog.Dates.latest, 32)
    net.WriteUInt(string.len(days), 32)
    net.WriteData(days, string.len(days))
    net.Send(ply)

end)

local function getOldRoundsQuery(mysql, date)

    if (mysql) then
        return"SELECT unix,map,round,code FROM chatlog_v2_oldlogs WHERE unix BETWEEN UNIX_TIMESTAMP(\"" .. date .. " 00:00:00\") AND UNIX_TIMESTAMP(\"" .. date .. " 23:59:59\") ORDER BY unix ASC;"
    end

    return "SELECT unix,map,round,code FROM chatlog_v2_oldlogs WHERE unix BETWEEN strftime('%s', \"" .. date .. " 00:00:00\") AND strftime('%s', \"" .. date .. " 23:59:59\") ORDER BY unix ASC;"

end

net.Receive("AskOldChatlogRounds", function(_, ply)

    local id = net.ReadUInt(32)
    local year = net.ReadUInt(32)
    local month = string.format("%02d", net.ReadUInt(32))
    local day = string.format("%02d", net.ReadUInt(32))
    local _date = year .. "-" .. month .. "-" .. day

    local queryStr = getOldRoundsQuery(Chatlog.Config.database_use_mysql, _date)

    Chatlog.Query(queryStr, function(success, data)

        if (not success or not data or table.IsEmpty(data) or not IsValid(ply)) then return end

        local data = data
        net.Start("SendOldChatlogRounds")
        net.WriteUInt(id, 32)
        net.WriteTable(data)
        net.Send(ply)
    end)

end)