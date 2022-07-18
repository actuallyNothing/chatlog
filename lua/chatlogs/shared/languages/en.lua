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

    FiltersHideDead = "Hide dead players and spectators",
    FiltersOnlySubstringsTitle = "Show only messages containing these words:",
    FiltersOnlySubstringsPlaceholder = "Enter words to search for, separated by commas.",

    FiltersPlayers = "Show messages from:",
    FiltersPlayersNoPlayersFound = "No players found",

    EmptyLogFilters = "No messages found matching the current filters.",

    TextPanelMessageInfo = "Message Information",
    TextPanelTip = "Select a message to display here!",

    TextPanelTo = " to ",
    TextPanelTeam = "TEAM",
    TextPanelAll = "ALL",
    TextPanelDeadPrefix = "*DEAD* ",

    PlayerListButtonShow = "  Show players",
    PlayerListButtonHide = "  Hide players",
    PlayerList = "Players",
    PlayerListName = "Name",
    PlayerListNoPlayers = "No players found"

}
