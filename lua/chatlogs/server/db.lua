function Chatlog.InitializeDB()

    if (Chatlog.Config.database_use_mysql) then
        -- Using MySQL
        Chatlog.MySQL.Initialize()
        return
    end

    -- Using SQLite
    Chatlog.CreateDBTables()
    Chatlog.LastRoundPrevMapSetup()
    Chatlog.OldLogsSetup()

end

function Chatlog.CreateDBTables()

    if (not Chatlog.Config.database_use_mysql) then

        print("[Chatlog] Creating SQLite database tables...")

        local q1 = Chatlog.SQLite.Query("CREATE TABLE IF NOT EXISTS chatlog_v2_oldlogs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, code TEXT NOT NULL, year INTEGER NOT NULL, month INTEGER NOT NULL, day INTEGER NOT NULL, unix INTEGER NOT NULL, round INTEGER NOT NULL, curtime DOUBLE NOT NULL, map TEXT NOT NULL, log TEXT NOT NULL, players TEXT NOT NULL);")

        local q2 = Chatlog.SQLite.Query("CREATE TABLE IF NOT EXISTS chatlog_v2_lastround (code TEXT)")

        if (q1 ~= false and q2 ~= false) then
            print("[Chatlog] SQLite database tables created successfully!")
        else
            print("[Chatlog] SQLite database tables creation failed!")
        end
    else

        print("[Chatlog] Creating MySQL database tables...")

        local query1 = Chatlog.MySQL.Database:query("CREATE TABLE IF NOT EXISTS chatlog_v2_oldlogs (id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT, code CHAR(6) NOT NULL, year INTEGER NOT NULL, month INTEGER NOT NULL, day INTEGER NOT NULL, unix INTEGER NOT NULL, round INTEGER NOT NULL, curtime DOUBLE NOT NULL, map VARCHAR(255) NOT NULL, log MEDIUMTEXT NOT NULL, players TEXT NOT NULL);")

        local query2 = Chatlog.MySQL.Database:query("CREATE TABLE IF NOT EXISTS chatlog_v2_lastround (code CHAR(6));")

        local transaction = Chatlog.MySQL.Database:createTransaction()

        transaction:addQuery(query1)
        transaction:addQuery(query2)

        function transaction.onSuccess()
            print("[Chatlog] MySQL database tables created successfully!")
        end

        function transaction.onError(_, err)
            print("[Chatlog] MySQL database tables creation failed!")
            print(err)
        end

        transaction:start()

    end

end

function Chatlog.Query(query, callback, ...)

    local success, results
    local args = {...}

    if (not Chatlog.Config.database_use_mysql) then

        results = Chatlog.SQLite.Query(query)
        success = results ~= nil and results ~= false

        if (callback) then
            local callbackVarargs = unpack(args)

            callback(success, results, callbackVarargs)
        end

    else

        local q = Chatlog.MySQL.Database:query(query)

        function q:onSuccess(data)
            success = true
            results = data

            if (callback) then
                local callbackVarargs = unpack(args)

                callback(success, results, callbackVarargs)
            end
        end

        function q:onError(err)
            print("[Chatlog] MySQL Query failed!")
            print(err)
            success = false
        end

        q:start()

    end

end