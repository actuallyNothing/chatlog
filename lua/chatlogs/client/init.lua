CreateClientConVar("chatlog_language", "en", FCVAR_ARCHIVE)
include("chatlogs/client/preferences.lua")
include("chatlogs/shared/lang.lua")
include("chatlogs/shared/privileges.lua")
include("chatlogs/client/loadround.lua")
include("chatlogs/client/net.lua")
include("chatlogs/client/textpanel.lua")
include("chatlogs/client/settings.lua")
include("chatlogs/client/admin.lua")
include("chatlogs/client/menu.lua")
-- Language
GetChatlogLanguage = GetConVar("chatlog_language"):GetString()
-- Initial tables
Chatlog.Rounds = {}
Chatlog.Menu = {}