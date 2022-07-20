--[[

	Chatlog v2.0.0
	Made by actuallyNothing for the Trouble in Terrorist Town gamemode
	Format and date browser code based on the Damagelogs addon made by Tommy228 https://github.com/Tommy228/tttdamagelogs
	
    contact:
    Steam: https://steamcommunity.com/id/actuallyNothing/
    GitHub: https://github.com/actuallyNothing/

--]]

Chatlog = Chatlog or {}
Chatlog.Version = "2.0.0"
Chatlog.Privileges = Chatlog.Privileges or {}
Chatlog.TeamChatAccess = Chatlog.TeamChatAccess or {}
ChatlogLanguage = ChatlogLanguage or {}

if not file.Exists("chatlog", "DATA") then
    file.CreateDir("chatlog")
end

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("chatlogs/client/init.lua")
    include("chatlogs/server/init.lua")
else
    include("chatlogs/client/init.lua")
end

-- Load all language files, for some reason it only works in here
for _, v in pairs(file.Find("chatlogs/shared/languages/*.lua", "LUA")) do
    local f = "chatlogs/shared/languages/" .. v

    if SERVER then
        AddCSLuaFile(f)
    else
        include(f)
    end
end