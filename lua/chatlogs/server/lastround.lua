Chatlog.LastRoundPrevMap = Chatlog.LastRoundMap or {}

function Chatlog.LastRoundPrevMapSetup()

    Chatlog.Query("SELECT code FROM chatlog_v2_lastround LIMIT 1", function(success, code)

        Chatlog.Query("SELECT * FROM chatlog_v2_oldlogs WHERE code = \'" .. code[1].code .. "\'", function(success, data)

            if (not success or not data or table.IsEmpty(data)) then
                SetGlobalBool("ChatlogLastMapExists", false)
                return
            end

            data = data[1]

            data.Log = util.JSONToTable(data.log)
            data.log = nil
            data.Players = util.JSONToTable(data.players)
            data.players = nil

            Chatlog.LastRoundPrevMap = data

            SetGlobalBool("ChatlogLastMapExists", true)

        end)

    end)

end

hook.Add("TTTEndRound", "ChatlogLastRound", function()

    local code = Chatlog.Rounds[GetGlobalInt("ChatlogRoundNumber")].code

    Chatlog.Query("DELETE FROM chatlog_v2_lastround", function(_, data)

        Chatlog.Query("INSERT INTO chatlog_v2_lastround (code) VALUES (\'" .. code .. "\');")

    end)

end)