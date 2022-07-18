---------------
-- Round net --
---------------
local function overwriteTable(table1, table2)
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

net.Receive("GetChatlogRound", function()

    roundtable = {}

    local bytes = net.ReadUInt(32)
    roundtable = net.ReadData(bytes)
    roundtable = util.Decompress(roundtable)
    roundtable = util.JSONToTable(roundtable)

    local index = net.ReadInt(16)
    local isOld = net.ReadBool()

    if (index ~= 0 and not isOld) then

        if (index == -1) then
            Chatlog.LastRoundPrevMap = roundtable
        end

        Chatlog.Rounds[index] = roundtable
    end

    if (isOld) then

        Chatlog.OldLogs[roundtable.code] = roundtable

    end

    Chatlog.LoadRound(roundtable)
end)

net.Receive("ChatlogSendLastMapData", function()

    local bytes = net.ReadUInt(16)
    local data = net.ReadData(bytes)
    data = util.JSONToTable(util.Decompress(data))

    if (data) then
        Chatlog.LastRoundPrevMap = data
    end

end)

----------------
-- Config net --
----------------
net.Receive("ChatlogSendConfiguration", function()
    local config = util.JSONToTable(net.ReadString())
    local partial = net.ReadBool()
    local full = table.Copy(Chatlog.Config)

    if partial then
        overwriteTable(full, config)

        for k, v in pairs(full.privileges) do
            if v.markedForDeletion then
                full.privileges[k] = nil
            end
        end

        Chatlog.Config = full
    else
        Chatlog.Config = config
        Chatlog.Ready = true
    end
end)

hook.Add("InitPostEntity", "ChatlogClientInit", function()
    net.Start("ChatlogClientReady")
    net.SendToServer()
    Chatlog.pressedKey = false

    function Chatlog:Think()
        if not Chatlog.Ready or not self.Config.keybind then return end

        if input.IsKeyDown(KEY_F7) and not self.pressedKey then
            self.pressedKey = true

            if not IsValid(self.Menu) then
                self:OpenMenu()
            else
                self.Menu:Close()
            end
        elseif self.pressedKey and not input.IsKeyDown(KEY_F7) then
            self.pressedKey = false
        end
    end

    hook.Add("Think", "ThinkChatlog", function(version)
        Chatlog:Think()
    end)
end)

-- Check if there's a newer version on Github
-- if there is, alert the player
Chatlog.outdated = false

http.Fetch("https://raw.githubusercontent.com/actuallyNothing/chatlog/master/VERSION.md", function(version)
    local cur_version = string.Explode(".", Chatlog.Version)
    local tbl = string.Explode(".", version)

    for i = 1, 3 do
        tbl[i] = tonumber(tbl[i])
        cur_version[i] = tonumber(cur_version[i])
    end

    if tbl[1] > cur_version[1] then
        Chatlog.outdated = true
    elseif tbl[1] == cur_version[1] and tbl[2] > cur_version[2] then
        Chatlog.outdated = true
    elseif tbl[1] == cur_version[1] and tbl[2] == cur_version[2] and tbl[3] > cur_version[3] then
        Chatlog.outdated = true
    end
end)