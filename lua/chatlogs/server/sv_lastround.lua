-- This saves the last registered round to a .json file to set as
-- "Last round from previous map" when the server restarts or
-- the map changes

hook.Add("TTTEndRound", "ChatlogLastRound", function()
	file.Write("chatlog/chatlog_lastroundmap.json", util.TableToJSON(Chatlog.Rounds[GetGlobalInt("ChatlogRoundNumber")]))
end)