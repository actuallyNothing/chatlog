--[[User privileges

	First argument: name of usergroup (e. g. "user" or "admin")
	Second argument defines what level of access a user has to the Chatlogs system:
	0: Can't use Chatlogs (usually applied if no usergroup is found, but you can also set it yourself)
	1: Can only see messages from alive people in previous rounds
	2: Can see messages from alive and dead people in previous rounds
	3: Can see all messages from any round while spectating
	4: Can see all messages from any round, anytime

	Third argument defines whether the user can see team chat messages (traitor or detective)
	returns false if no usergroup is found
--]]

Chatlog:AddUser("owner", 4, true)
Chatlog:AddUser("superadmin", 4, true)
Chatlog:AddUser("admin", 3, true)
Chatlog:AddUser("operator", 2, true)
Chatlog:AddUser("user", 1, false)

-- F-key to open/close chatlog window
Chatlog.Key = KEY_F7