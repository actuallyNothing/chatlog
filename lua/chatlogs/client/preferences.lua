-- Fonts
surface.CreateFont("ChatlogMessageLabel", {
    font = "DermaLarge",
    size = 15,
    weight = 600
})

surface.CreateFont("ChatlogMessage", {
    font = "ChatFont",
    size = 13
})

surface.CreateFont("ChatlogAuthor", {
    font = "ChatFont",
    size = 13
})

surface.CreateFont("ChatlogVersioning", {
    font = "ChatFont",
    size = 15
})

surface.CreateFont("ChatlogPanelTitle", {
    font = "ChatFont",
    size = 21
})

Chatlog.Colors = {
    ["BLACK"] = color_black,
    ["WHITE"] = color_white,
    ["YELLOW"] = Color(255, 255, 0),
    ["RED"] = Color(255, 0, 0),
    ["MAGENTA"] = Color(255, 0, 255),

    -- Panel colors
    ["PANEL_DARK"] = Color(0, 0, 0, 245),
    ["PANEL_LIGHT"] = Color(0, 0, 0, 95),

    -- Log colors
    ["ROLE_INNOCENT"] = color_black,
    ["ROLE_TRAITOR"] = Color(150, 0, 0),
    ["ROLE_DETECTIVE"] = Color(0, 0, 255),
    ["ROLE_SPECTATOR"] = Color(0, 0, 0, 185),

    ["NAME_INNOCENT"] = color_black,
    ["NAME_TRAITOR"] = Color(255, 0, 0),
    ["NAME_DETECTIVE"] = Color(0, 0, 255),
    ["NAME_SPECTATOR"] = color_black,

    ["HIGHLIGHT_TRAITOR"] = Color(255, 0, 0, 50),
    ["HIGHLIGHT_DETECTIVE"] = Color(0, 0, 255, 50),
    ["HIGHLIGHT_SPECTATOR"] = Color(0, 0, 0, 125),

    ["TEXTPANEL_BACKGROUND"] = Color(75, 75, 75),
    ["RADIO_MESSAGE"] = Color(0, 225, 255, 50)
}

function Chatlog.GetColor(type, color)
    return Chatlog.Colors[string.upper(type) .. "_" .. string.upper(color)]
end
