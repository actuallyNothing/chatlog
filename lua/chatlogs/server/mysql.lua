Chatlog.MySQL = Chatlog.MySQL or {}

function Chatlog.MySQL.Initialize()

    require("mysqloo")

    print("[Chatlog] Initializing MySQL...")

    local connectionData = Chatlog.Config.mysql
    Chatlog.MySQL.Database = mysqloo.connect(connectionData.ip, connectionData.username, connectionData.password, connectionData.database, connectionData.port)

    function Chatlog.MySQL.Database.onConnected(self)

        Chatlog.MySQL.Connected = true

        print("Connected to MySQL database")

        Chatlog.CreateDBTables()


    end

    function Chatlog.MySQL.Database.onConnectionFailed(self, err)

        file.Append("chatlog/mysql_errors.txt", err)

        print("[Chatlog] MySQL connection failed: " .. err)

    end

    Chatlog.MySQL.Database:connect()

end

function Chatlog.MySQL.Disconnect()

    if (not Chatlog.MySQL.Connected) then return end

    print("[Chatlog] Disconnecting from MySQL...")

    Chatlog.MySQL.Database:disconnect()
    Chatlog.MySQL.Connected = false

    print("[Chatlog] Disconnected from MySQL database")

end