CreateClientConVar("chatlog_language", "en", FCVAR_ARCHIVE)

Chatlog.Rounds = Chatlog.Rounds or {}
Chatlog.OldRounds = Chatlog.OldRounds or {}
Chatlog.Menu = {}
Chatlog.Filters = {
    text = {
        enabled = false,
        strings = {}
    },
    players = {
        enabled = false,
        steamids = {}
    },
    roles = {
        enabled = false,
        roles = {
            ["innocent"] = false,
            ["traitor"] = false,
            ["detective"] = false
        }
    },
    team = false,
    hideDead = false
}

include("chatlogs/client/preferences.lua")
include("chatlogs/shared/lang.lua")
include("chatlogs/shared/privileges.lua")
include("chatlogs/client/loadround.lua")
include("chatlogs/client/net.lua")
include("chatlogs/client/textpanel.lua")
include("chatlogs/client/settings.lua")
include("chatlogs/client/admin.lua")
include("chatlogs/client/filters.lua")
include("chatlogs/client/playerlist.lua")
include("chatlogs/client/oldlogs.lua")
include("chatlogs/client/menu.lua")

-- Language
GetChatlogLanguage = GetConVar("chatlog_language"):GetString()