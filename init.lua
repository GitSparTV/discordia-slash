-- Discordia injection from https://github.com/Bilal2453/discordia-interactions
local discordia = require("discordia")

do
	local API = require("client/API")
	local discordia_api = discordia.class.classes.API
	API.request = discordia_api.request

	for k, v in pairs(API) do
		rawset(discordia_api, k, v)
	end
end

do
	local Client = require("client/Client")
	local discordia_client = discordia.class.classes.Client

	for k, v in pairs(Client) do
		rawset(discordia_client, k, v)
	end
end

do
	local EventHandler = require("client/EventHandler")
	local client = discordia.Client{
		logFile = '',
	}

	local events = client._events

	for k, v in pairs(EventHandler) do
		if rawget(events, k) then
			local old_event = events[k]

			events[k] = function(...)
				v(...)

				return old_event(...)
			end
		else
			events[k] = v
		end
	end
end

return {}