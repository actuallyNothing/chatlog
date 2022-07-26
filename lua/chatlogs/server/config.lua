--[[
    Server configuration is managed through chatlog_config.json in /data/chatlog/
    or in-game through the "Manage" tab

    This file manages communications between server and client
    regarding the configuration file and generating the default one
]]
function Chatlog:SendConfiguration(ply, partial, config)
    -- We'll check whether the config is partial or not so
    -- we know which one to send. Then we'll delete the "mysql" key
    local tosend

    if partial then
        tosend = table.Copy(config)
    else
        tosend = table.Copy(self.Config)
    end

    if tosend["mysql"] ~= nil then
        tosend["mysql"] = nil
    end

    if next(tosend) == nil then return end -- only sql changes, no point in sending
    net.Start("ChatlogSendConfiguration")
    net.WriteString(util.TableToJSON(tosend))
    net.WriteBool(partial)

    if ply == "all" then
        net.Broadcast()
    else
        net.Send(ply)
    end
end

local function completeTable(table1, table2, onlyNil)
    for k, v in pairs(table2) do
        if type(v) == "table" and type(table1[k]) == "table" then
            table1[k] = completeTable(table1[k], v, onlyNil)
        elseif not onlyNil or (onlyNil and table1[k] == nil) then
            table1[k] = v
        end
    end

    return table1
end

-- Takes a partial config table and implements it
-- into the full one, returning the complete table
function Chatlog:CompleteConfiguration(partial)
    partial = util.JSONToTable(partial)
    local full = table.Copy(Chatlog.Config)

    return completeTable(full, partial)
end

function Chatlog:UpdateConfiguration(broadcast)
    self.JSONconfig = file.Read("chatlog/chatlog_config.json", "data")
    local refreshDB = false
    local configTable = util.JSONToTable(self.JSONconfig)

    if (self.Config and self.Config.database_use_mysql ~= configTable.database_use_mysql) then
        refreshDB = true
    end

    self.Config = configTable
    if (refreshDB) then
        print("[Chatlog] Switched to " .. (self.Config.database_use_mysql and "MySQL" or "SQLite"))
        Chatlog.InitializeDB()
    end

    if broadcast then
        self:SendConfiguration("all", false)
    end
end

function Chatlog:SaveCurrentConfiguration()
    file.Write("chatlog/chatlog_config.json", util.TableToJSON(self.Config, true))
    Chatlog:UpdateConfiguration(true)
end

--[[
	If no "chatlog_config.json" file is found, 'defaultConfig'
	will be the one created by the addon, and will be used as
	a blank slate to compare against the file in /data/chatlog/.

	After this, the file will be editable in-game through
	a superadmin-exclusive tab in the Chatlog window. You
    can also edit the file directly in /data/chatlog/chatlog_config.json
    and synchronize the changes by typing "chatlog_sync_config"
    in the server's console.
]]
local defaultConfig = {
    ["privileges"] = {
        ["superadmin"] = {
            can_read_current_round = true,
            can_read_dead_players = true,
            can_read_team_messages = true,
            can_search_old_logs_by_date = true
        },
        ["admin"] = {
            can_read_current_round = "spec_only",
            can_read_dead_players = true,
            can_read_team_messages = true,
            can_search_old_logs_by_date = true
        },
        ["operator"] = {
            can_read_current_round = "spec_only",
            can_read_dead_players = false,
            can_read_team_messages = true,
            can_search_old_logs_by_date = true
        },
        ["user"] = {
            can_read_current_round = false,
            can_read_dead_players = false,
            can_read_team_messages = false,
            can_search_old_logs_by_date = true
        }
    },
    ["database_day_limit"] = 30,
    ["keybind"] = true,
    ["database_use_mysql"] = false,
    ["mysql"] = {
        ip = "127.0.0.1",
        username = "",
        password = "",
        database = "",
        port = "3306"
    }
}

local function writeConfiguration(table, broadcast)
    file.Write("chatlog/chatlog_config.json", util.TableToJSON(table or defaultConfig, true))
    Chatlog:UpdateConfiguration(broadcast)
end

local function overwriteTable(table, replacement)
    -- Loop over table2 and add any missing values to table1
    -- If a value in table2 differs from table1, overwrite table1 with table2
    for k, v in pairs(table2) do
        if type(v) == "table" then
            if type(table1[k]) ~= "table" then
                table1[k] = {}
            end

            table1[k] = overwriteTable(table1[k], v)
        else
            if table1[k] ~= v then
                table1[k] = v
            end
        end
    end

    return table1
end

local function validatePrivilegeGroup(group)
    if not group then
        group = defaultConfig.privileges.user
    end

    if group.can_read_current_round == nil or type(group.can_read_current_round) ~= "boolean" and group.can_read_current_round ~= "spec_only" then return defaultConfig.privileges.user end
    if group.can_read_dead_players == nil or type(group.can_read_dead_players) ~= "boolean" then return defaultConfig.privileges.user end
    if group.can_read_team_messages == nil or type(group.can_read_team_messages) ~= "boolean" then return defaultConfig.privileges.user end

    return group
end

function Chatlog:ValidateConfiguration()
    if not file.Exists("chatlog/chatlog_config.json", "DATA") then
        writeConfiguration()
        Chatlog:UpdateConfiguration(true)
    else
        local file = util.JSONToTable(file.Read("chatlog/chatlog_config.json", "DATA"))

        if file == nil then
            writeConfiguration()
            Chatlog:UpdateConfiguration(true)
        else
            -- Validate single variables
            for k, v in pairs(defaultConfig) do
                if type(v) ~= "table" and (defaultConfig[k] ~= nil and file[k] == nil) then
                    file[k] = defaultConfig[k]
                end
            end

            -- Validate tables
            for k, v in pairs(defaultConfig) do
                if type(v) == "table" and (file[k] == nil or type(file[k]) ~= "table" or next(file[k]) == nil) then
                    file[k] = v
                end
            end

            -- Check for existence of "superadmin" and "user" groups
            for _, k in ipairs({"superadmin", "user"}) do
                if file.privileges[k] == nil or next(file.privileges[k]) == nil then
                    file.privileges[k] = defaultConfig.privileges[k]
                end
            end

            -- Validate privileges
            for k, v in pairs(file.privileges) do
                file.privileges[k] = validatePrivilegeGroup(v)
            end

            -- Validate MySQL configuration
            local str = ""
            local count = 1

            for k, v in pairs(defaultConfig.mysql) do
                if file.mysql[k] == nil then
                    str = str .. "	" .. count .. ". missing " .. k .. "\n"
                    count = count + 1
                elseif type(file.mysql[k]) ~= "string" then
                    str = str .. "	" .. count .. ". " .. k .. " is not a string (put quotes around value!)\n"
                    count = count + 1
                end
            end

            if file.database_use_mysql and str ~= "" then
                ErrorNoHalt("\n[chatlog] Chatlog has found an error with your MySQL configuration, and has set SQLite to be used instead.\n	Please check your configuration and restart your server, for an example check the README.\n\n	Errors found:\n" .. str .. "\n\n	Check if your MySQL configuration is valid in \"/garrysmod/data/chatlog/config.json\".\n\n")
                file.database_use_mysql = false
            end

            writeConfiguration(file, true)
        end
    end
end

function Chatlog:CommitConfiguration(config, ply)
    -- Write configuration and send it
    local newConfig = Chatlog:CompleteConfiguration(config)

    self:SendConfiguration("all", true, newConfig)

    for k, v in pairs(newConfig.privileges) do
        if v.markedForDeletion then
            newConfig.privileges[k] = nil
        end
    end

    writeConfiguration(newConfig)
end

net.Receive("ChatlogCommitConfiguration", function(_, ply)
    if (ply:GetUserGroup() ~= "superadmin") then return end

    local config = net.ReadString()
    Chatlog:CommitConfiguration(config, ply)
end)

net.Receive("ChatlogGetMySQLConfiguration", function(_, ply)
    if (ply:GetUserGroup() ~= "superadmin") then return end

    net.Start("ChatlogSendMySQLConfiguration")
    net.WriteTable(Chatlog.Config.mysql)
    net.Send(ply)
end)

concommand.Add("chatlog_sync_config", function()
    Chatlog:UpdateConfiguration(true)
    print("[Chatlog] Configuration synced.")
end, nil, "Synchronize the JSON configuration file with the server")
