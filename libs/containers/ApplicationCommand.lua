local discordia = require("discordia")
local class = discordia.class
local classes = class.classes

local Snowflake = classes.Snowflake
local ApplicationCommand, get = class("ApplicationCommand", Snowflake)

function ApplicationCommand:__init(data, parent)
	Snowflake.__init(self, data, parent)

	self._type = data.type
	self._application_id = data.application_id
	self._name = data.name
	self._description = data.description
	self._options = data.options
	self._default_permission = data.default_permission
	self._version = data.version

	do
		local guildId = data.guild_id

		if guildId then
			self._guild = self._parent:getGuild(guildId)
		end
	end
end

function ApplicationCommand:getPermissions(guild_id)
	return self.client:getApplicationCommandPermissions(self.guild.id, self.id)
end

function ApplicationCommand:editPermissions(payload)
	return self.client:editApplicationCommandPermissions(self.guild.id, self.id, payload)
end

function ApplicationCommand:delete()
	if self.guild then
		return self.client:deleteGuildApplicationCommand(self.guild.id, self.id)
	else
		return self.client:deleteGlobalApplicationCommand(self.id)
	end
end

function get:guild()
	return self._guild
end

function get:type()
	return self._type
end

local types = {
	[discordia.enums.appCommandType.chatInput] = "Slash Command",
	[discordia.enums.appCommandType.user] = "User Command",
	[discordia.enums.appCommandType.message] = "Message Command",
}

function get:printableType()
	return types[self._type]
end

function get:application_id()
	return self._application_id
end

function get:mentionString()
	return self._type == discordia.enums.appCommandType.chatInput and "</" .. self._name .. ":" .. self._id .. ">" or nil
end

function get:name()
	return self._name
end

function get:description()
	return self._description
end

function get:options()
	return self._options
end

function get:default_permission()
	return self._default_permission
end

function get:version()
	return self._version
end

return ApplicationCommand
