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

Chatlog.Colors = {
	["ROLE_INNOCENT"] = Color(0,255,0),
	["ROLE_TRAITOR"] = Color(255,0,0),
	["ROLE_DETECTIVE"] = Color(0,0,255),
	["ROLE_DEAD"] = Color(0,0,0,185),
	["HIGHLIGHT_TRAITOR"] = Color(255,0,0,100),
	["HIGHLIGHT_DETECTIVE"] = Color(0,0,255,100),
	["HIGHLIGHT_DEAD"] = Color(0,0,0,125)
}

function Chatlog.GetColor(type, color)
	return Chatlog.Colors[string.upper(type).."_"..string.upper(color)]
end
