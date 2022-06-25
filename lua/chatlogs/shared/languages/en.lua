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
    spectator = "DEAD",
    ClipboardCopy = "Copy to clipboard",
    ClipboardCopied = "Copied message to clipboard!",
    Round = "Round ",
    RoundFilter = "Filter by round:",
    RoundSelect = "Select round",
    RoundSelectCurrent = "Current round",
    PlayerFilter = "Filter by player:",
    PlayerFilterNone = "None",
    PlayerFilterRemove = "Remove Filter",
    DeadFilter = "Hide dead",
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
    GetSteamID = "Copy SteamID of %s"
}
