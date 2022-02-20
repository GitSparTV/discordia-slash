local ApplicationCommand = require("containers/ApplicationCommand")
local events = {}

function events.APPLICATION_COMMAND_CREATE(d, client)
	local cmd = ApplicationCommand(d, client)

	client:emit("applicationCommandCreate", cmd)
end

function events.APPLICATION_COMMAND_UPDATE(d, client)
	local cmd = ApplicationCommand(d, client)

	p("APPLICATION_COMMAND_UPDATE", cmd)

	client:emit("applicationCommandUpdate", cmd)
end

function events.APPLICATION_COMMAND_DELETE(d, client)
	local cmd = ApplicationCommand(d, client)

	client:emit("applicationCommandDelete", cmd)
end

function events.APPLICATION_COMMAND_PERMISSIONS_UPDATE(d, client)
	client:emit("applicationCommandPermissionsUpdate", cmd)
end

return events