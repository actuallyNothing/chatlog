-- Add languages to the /chatlog/shared/languages/ folder, with the filename "language.lua"
-- This is a helper function to get language lines

function Chatlog.Translate(phrase, nomissing)
    local f = GetChatlogLanguage
    if not ChatlogLanguage[f] then
    -- Fallback language if the specified language is not found
        f = "en"
    end
    return ChatlogLanguage[f][phrase] or LANG.TryTranslation(phrase) or not nomissing and "Missing: " .. tostring(phrase)
end