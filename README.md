# ![](https://i.imgur.com/tjmcgjn.png) Chatlog
A chat logging tool for Trouble in Terrorist Town, based on the Damagelogs addon by Tommy228. https://github.com/Tommy228/tttdamagelogs

![](https://i.imgur.com/UWGru8x.png)

This addon **keeps a log of every round's chat and radio/quick messages**, and allows for easy searching, filtering and saving of these logs.
Privileges are usergroup-based, and they can be edited along the server's configuration while in-game or through a JSON file. MySQL is supported for storing logs.

![](https://i.imgur.com/7l3nVev.png)

This tool is meant to facilitate the resolution of reports or conflicts and fulfill any other needs met by having easy access to chat logs.
## Features

* Easy-to-navigate round selector
* Rounds show the map, date, and time they were played
* Message highlights for team messages and spectators
* Comprehensive filtering system (filter by player, text, team messages, etc.)
* Old logs browser to search for chats from past maps
  * Rounds have a 6-character alphanumeric code that can be used to point to a specific round in the database
  * Alternatively, players can search rounds by the date and time they were played
* Radio commands are saved and highlighted
* Easy to add, modify and remove language files (contributions are welcome)

## Configuration

The server's configuration is stored in the **/data/chatlog/chatlog_config.json** file, it can be edited in-game by superadmins through a dedicated tab. Alternatively, **changes can be made directly to the file and then synchronized with the "chatlog_sync_config"** console command.

![](https://i.imgur.com/F1C3lz1.png)

This default configuration is written if there is not one already:

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


## Installation

Drop the 'chatlogs' folder into the garrysmod/addons/ directory, inside your Garry's Mod installation.

You can copy the default configuration, save it as /data/chatlog/chatlog_config.json and modify it to your liking before starting your server.

## Credits

Chat and file icons by icons8.com