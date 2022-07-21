-- English
-- This is the default language file, copy and paste it 
-- if you're making a new one
-- These files follow ISO 639-1 language code standards,
-- when making a new one, edit the ["en"] tag to the one
-- corresponding to the language you're translating to,
-- as well as the DisplayName variable.
-- "Flag" variable is used to set a flag when looking at
-- the list of available languages.
-- https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
ChatlogLanguage["en"] = {
    DisplayName = "English",
    Flag = "gb",
    Time = "Time",
    Player = "Player",
    Message = "Message",
    EmptyLog = "Empty!",
    Unauthorized = "Insufficient permissions!",
    -- Role keys are lowercase to match v['role'] in cl_init
    innocent = "INNOCENT",
    traitor = "TRAITOR",
    detective = "DETECTIVE",
    spectator = "SPECTATOR",
    ClipboardCopy = "Copy to clipboard",
    ClipboardCopied = "Copied message to clipboard!",
    Round = "Round ",
    RoundFilter = "Filter by round:",
    RoundSelect = "Select round",
    RoundSelectCurrent = "Current round",
    CantReadPresent = "You are not allowed to read the current round's chatlog.",
    NoFilterChosen = "Please select a round/filter before refreshing.",
    Refresh = "Refresh",
    ChatTab = "Chatlog",
    SettingsTab = "Settings",
    SelectedMessage = "Selected message:",
    SelectedMessageNone = "No message selected!",
    LanguageTab = "Language",
    Licensing = "Chatlogs v" .. Chatlog.Version .. " by actuallyNothing, licensed under the GPL-3.0 License.",
    SwitchedLanguage = "Changed Chatlog language!",
    LastRoundMap = "Last round from the previous map",
    CopiedSteamID = "Copied SteamID of %s (%s)",
    GetSteamID = "Copy SteamID of %s",

    SelectARound = "Select a round",
    NoRoundSelected = "No round selected",
    -- https://wiki.facepunch.com/gmod/os.date
    RoundInfoTime = "%A | %B %d, %Y | %X",
    RoundInfoError = "Error found",

    FiltersButtonShow = "  More filters",
    FiltersButtonHide = "  Less filters",
    FiltersTitle = "Filters",
    FiltersOnlyTeam = "Show only team messages",

    FiltersRoles = "Show only messages from:",
    FiltersRolesInnocent = "Innocents",
    FiltersRolesTraitor = "Traitors",
    FiltersRolesDetective = "Detectives",

    FiltersHideRadio = "Hide radio messages",
    FiltersOnlySubstringsTitle = "Show only messages containing:",
    FiltersOnlySubstringsPlaceholder = "c4, traitor, detective",
    FiltersOnlySubstringsTip = "Use commas to filter various words. Example: 'hello, world'",

    FiltersPlayers = "Show messages from:",
    FiltersPlayersNoPlayersFound = "No players found",

    EmptyLogFilters = "No messages found matching the current filters.",

    TextPanelMessageInfo = "Message Information",
    TextPanelTip = "Select a message to display here!",

    TextPanelTo = " to ",
    TextPanelTeam = "TEAM",
    TextPanelAll = "ALL",
    TextPanelOnRadio = " ON RADIO",
    TextPanelDeadPrefix = "*DEAD* ",

    PlayerListButtonShow = "  Show players",
    PlayerListButtonHide = "  Hide players",
    PlayerList = "Players",
    PlayerListName = "Name",
    PlayerListNoPlayers = "No players found",

    Cancel = "Cancel",
    SaveChanges = "Save changes",
    Confirm = "Confirm",

    AdminTab = "Administrate",
    AdminUsergroups = "Usergroups",

    AdminNewGroup = "New group",
    AdminNewGroupTitle = "Adding a group",
    AdminNewGroupTip = "Enter the name for the new group:",
    AdminNewGroupAdd = "Add group",
    AdminNewGroupError = "Error adding group: ",
    AdminGroupExists = "That group already exists!",
    AdminCopyGroup = "Copy this group's name to clipboard",
    AdminCopiedGroup = "Copied groupname to clipboard!",
    AdminDeleteGroup = "Delete this group",

    AdminMySQLSettings = "MySQL Settings",
    AdminHoverToShow = "Hover to show",
    AdminMySQLReview = "Before setting MySQL as your database, please review the following settings:",

    MySQLHost = "IP / Host:",
    MySQLPort = "Port:",
    MySQLUsername = "Username:",
    MySQLPassword = "Password:",
    MySQLDatabase = "Database:",

    AdminCommitTitle = "Commit configuration changes",
    AdminCommitWarning = "Commiting changes will re-send the configuration file to all players. Commit?",
    AdminCommiting = "Commiting changes...",

    AdminPrivilegeTitle = "Privilege configuration",
    AdminPrivilegeSelectGroup = "Select a group to edit",
    AdminPrivilegeEditing = "Editing: (%s)",

    AdminPrivilegeReadPresent = "Can read messages in the current round:",
    AdminPrivilegeReadPresentAlways = "Always",
    AdminPrivilegeReadPresentNever = "Never",
    AdminPrivilegeReadPresentSpecOnly = "Only when dead or spectating",

    AdminPrivilegeReadTeam = "Can read team chat messages (traitor and detective)",
    AdminPrivilegeReadDead = "Can read messages from dead players / spectators",
    AdminPrivilegeSearchByDate = "Can search old logs by date",

    AdminServerTitle = "Server configuration",

    AdminServerKeybind = "Enable opening Chatlog window with F7",
    AdminServerKeybindTooltip = "When disabled, users must use the 'chatlog' console command to open the menu",

    AdminServerUseMySQL = "Use MySQL for storing logs",
    AdminServerUseMySQLTooltip = "When disabled, the server will use the built-in SQLite database",

    AdminServerDayLimit = "Database entries day limit",

    Month1 = "January",
    Month2 = "February",
    Month3 = "March",
    Month4 = "April",
    Month5 = "May",
    Month6 = "June",
    Month7 = "July",
    Month8 = "August",
    Month9 = "September",
    Month10 = "October",
    Month11 = "November",
    Month12 = "December",

    OldLogsTab = "Old Logs",

    OldLogsCodeTitle = "Search by code",
    OldLogsCodeTip = "Rounds have a unique 6-character code that can be used to search for a specific round.",
    OldLogsCodeLabel = "Code:",
    OldLogsCodeButton = "Search",

    OldLogsDateTitle = "Search by date",
    OldLogsDateTip = "Rounds can be searched by the date and time they started.",
    OldLogsDateBetween = "Rounds between %s and %s",
    OldLogsDateLoad = "Load round",

    CopyRoundCode = "Copy this round's code",
    CopiedRoundCode = "Copied this round's code to clipboard! (%s)",

    ServerResponseNoRoundFound = "No round found matching the given code.",
    ServerResponseInvalidCode = "Invalid code.",
    ServerResponseOK = "Loading round...",

    Role = "Role",

}
