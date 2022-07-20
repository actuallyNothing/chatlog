function Chatlog.InitializeDB()

    if (Chatlog.Config.database_use_mysql) then
        print("a")
        Chatlog.MySQL.Initialize()
        return
    end

    Chatlog.CreateDBTables()

end

function Chatlog.CreateDBTables()

    if (not Chatlog.Config.database_use_mysql) then

        print("Chatlog: Creating SQLite database tables...")

        Chatlog.SQLite.Query("CREATE TABLE IF NOT EXISTS chatlog_v2_oldlogs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, code TEXT NOT NULL, year INTEGER NOT NULL, month INTEGER NOT NULL, day INTEGER NOT NULL, unix INTEGER NOT NULL, round INTEGER NOT NULL, curtime DOUBLE NOT NULL, map TEXT NOT NULL, log TEXT NOT NULL, players TEXT NOT NULL);")

        Chatlog.SQLite.Query("CREATE TABLE IF NOT EXISTS chatlog_v2_lastround (id INTEGER NOT NULL, map TEXT, unix INTEGER, log TEXT, players TEXT, code TEXT)")
    else

        print("Chatlog: Creating MySQL database tables...")

        local query1 = Chatlog.MySQL.Database:query("CREATE TABLE IF NOT EXISTS chatlog_v2_oldlogs (id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT, code CHAR(6) NOT NULL, year INTEGER NOT NULL, month INTEGER NOT NULL, day INTEGER NOT NULL, unix INTEGER NOT NULL, round INTEGER NOT NULL, curtime DOUBLE NOT NULL, map VARCHAR(255) NOT NULL, log MEDIUMTEXT NOT NULL, players TEXT NOT NULL);")

        local query2 = Chatlog.MySQL.Database:query("CREATE TABLE IF NOT EXISTS chatlog_v2_lastround (id INTEGER NOT NULL, map VARCHAR(255), unix INTEGER, log MEDIUMTEXT, players TEXT, code CHAR(6));")

        local transaction = Chatlog.MySQL.Database:createTransaction()

        transaction:addQuery(query1)
        transaction:addQuery(query2)

        function transaction.onSuccess()
            print("Chatlog: MySQL Database tables created successfully!")
        end

        function transaction.onError(_, err)
            print("Chatlog: MySQL Database tables creation failed!")
            print(err)
        end

        transaction:start()

    end

end

function Chatlog.Query(query, callback, ...)

    local success, results
    local args = {...}

    if (not Chatlog.Config.database_use_mysql) then

        print("Querying with SQLite: " .. query)

        results = Chatlog.SQLite.Query(query)
        success = results ~= nil and results ~= false

        if (callback) then
            local callbackVarargs = unpack(args)

            callback(success, results, callbackVarargs)
        end

    else

        -- MySQL query
        print("Querying with MySQL: " .. query)

        local q = Chatlog.MySQL.Database:query(query)

        function q:onSuccess(data)
            success = true
            results = data

            if (callback) then
                local callbackVarargs = unpack(args)

                callback(success, results, callbackVarargs)
            end

            print("Chatlog: MySQL query successful!", query)
        end

        function q:onError(err)
            success = falselu
            print("MySQL query error: ", query, err)
        end

        q:start()

    end

end