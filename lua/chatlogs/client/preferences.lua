CreateClientConVar("chatlog_hide_dead", 0, true, false)

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
    ["BLACK"] = Color(0, 0, 0),
    ["WHITE"] = Color(255, 255, 255),
    ["YELLOW"] = Color(255, 255, 0),
    ["RED"] = Color(255, 0, 0),
    ["MAGENTA"] = Color(255, 0, 255),
    -- Panel colors
    ["PANEL_ADMIN_GROUPVIEW"] = Color(0, 0, 0, 245),
    ["PANEL_ADMIN_SERVERVIEW"] = Color(0, 0, 0, 95),
    -- Log colors
    ["ROLE_INNOCENT"] = Color(0, 0, 0),
    ["ROLE_TRAITOR"] = Color(150, 0, 0),
    ["ROLE_DETECTIVE"] = Color(0, 0, 255),
    ["ROLE_SPECTATOR"] = Color(0, 0, 0, 185),
    ["HIGHLIGHT_TRAITOR"] = Color(255, 0, 0, 50),
    ["HIGHLIGHT_DETECTIVE"] = Color(0, 0, 255, 50),
    ["HIGHLIGHT_SPECTATOR"] = Color(0, 0, 0, 125),
    ["TEXTPANEL_BACKGROUND"] = Color(200, 200, 200)
}

function Chatlog.GetColor(type, color)
    return Chatlog.Colors[string.upper(type) .. "_" .. string.upper(color)]
end
