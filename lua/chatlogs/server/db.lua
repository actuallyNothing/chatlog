function Chatlog.CreateDBTables()

    if (not Chatlog.Config.database_use_mysql) then

        print("Chatlog: Creating SQLite database tables...")

        Chatlog.SQLite.Query("CREATE TABLE IF NOT EXISTS chatlog_v1_oldlogs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, year INTEGER NOT NULL, month INTEGER NOT NULL, day INTEGER NOT NULL, unix INTEGER NOT NULL, round INTEGER NOT NULL, map TEXT NOT NULL, log TEXT NOT NULL);")
        Chatlog.SQLite.Query("CREATE TABLE IF NOT EXISTS chatlog_v1_lastround (id INTEGER NOT NULL, map TEXT, unix INTEGER, log TEXT, players TEXT)")
    else

        -- MySQL queries
        print("Chatlog: Creating MySQL database tables...")

    end

end

function Chatlog.Query(query)

    if (not Chatlog.Config.database_use_mysql) then

        print("Querying with SQLite: " .. query)

        return Chatlog.SQLite.Query(query)

    else

        -- MySQL query
        print("Querying with MySQL: " .. query)

    end

end