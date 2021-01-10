--[[

	Chatlog v1.1.0
	Made by actuallyNothing for the Trouble in Terrorist Town gamemode
	Based on the "Simple logs" base made by fghdx https://github.com/fghdx/Gmod-Simple-Logs/
	and the Damagelogs addon made by Tommy228 https://github.com/Tommy228/tttdamagelogs

	https://steamcommunity.com/id/actuallyNothing/
--]]

Chatlog = Chatlog or {}
Chatlog.Version = "v1.1.0"
Chatlog.Privileges = Chatlog.Privileges or {}
Chatlog.TeamChatAccess = Chatlog.TeamChatAccess or {}
ChatlogLanguage = ChatlogLanguage or {}

if not file.Exists("chatlog", "DATA") then
    file.CreateDir("chatlog")
end

function Chatlog:AddUser(user, privileges, teamChat)
    self.Privileges[user] = privileges
    self.TeamChatAccess[user] = teamChat
end

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("chatlogs/client/cl_init.lua")
    include("chatlogs/server/sv_init.lua")
else
    include("chatlogs/client/cl_init.lua")
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
