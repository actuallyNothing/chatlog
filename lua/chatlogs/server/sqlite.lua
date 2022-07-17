Chatlog.SQLite = {}

function Chatlog.SQLite.Query(queryStr)

    local q = sql.Query(queryStr)

    if (q == false) then

        local err = string.format("[%s] Error in SQLite query:\n%s\n[SQL Error] %s\n\n",
            util.DateStamp(),
            queryStr,
            sql.LastError()
        )

        file.Append("chatlog/sqlite_errors.txt", err)

        ErrorNoHalt(string.format("\n[chatlog] An error has ocurred with the following SQLite query:\n%s\n\nMore information can be found in /data/chatlog/sqlite_errors.txt\n\n", queryStr))

    end

    return q

end