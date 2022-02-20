local Client = {}

local discordia = require("discordia")
require("discordia-interactions")

local API = require("./API")
local Cache = discordia.class.classes.Cache
local ApplicationCommand = require("containers/ApplicationCommand")

function Client:getGuildApplicationCommands(guild_id)
	local data, err = self._api:getGuildApplicationCommands(self:getApplicationInformation().id, guild_id)

	if data then
		return Cache(data, ApplicationCommand, self)
	else
		return nil, err
	end
end

function Client:createGuildApplicationCommand(guild_id, id, payload)
	local data, err = self._api:createGuildApplicationCommand(self:getApplicationInformation().id, guild_id, id)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:getGuildApplicationCommand(guild_id, id)
	local data, err = self._api:getGuildApplicationCommand(self:getApplicationInformation().id, guild_id, id)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:editGuildApplicationCommand(guild_id, id, payload)
	local data, err = self._api:editGuildApplicationCommand(self:getApplicationInformation().id, guild_id, id, payload)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:deleteGuildApplicationCommand(guild_id, id)
	local data, err = self._api:deleteGuildApplicationCommand(self:getApplicationInformation().id, guild_id, id)

	if data then
		return data
	else
		return nil, err
	end
end

function Client:getGuildApplicationCommandPermissions(guild_id)
	local data, err = self._api:getGuildApplicationCommandPermissions(self:getApplicationInformation().id, guild_id)

	if data then
		return data
	else
		return nil, err
	end
end

function Client:getApplicationCommandPermissions(guild_id, id)
	local data, err = self._api:getApplicationCommandPermissions(self:getApplicationInformation().id, guild_id, id)

	if data then
		return data
	else
		return nil, err
	end
end

function Client:editApplicationCommandPermissions(guild_id, id, payload)
	local data, err = self._api:editApplicationCommandPermissions(self:getApplicationInformation().id, guild_id, id, payload)

	if data then
		return data
	else
		return nil, err
	end
end

local function AugmentResolved(resolved, ia)
	if not resolved then return end

	local guild = ia.guild
	local client = ia.parent
	local members = resolved.members
	local channels = resolved.channels
	local users = resolved.users
	local roles = resolved.roles

	for k, v in pairs(members) do
		members[k] = guild:getMember(k)
	end

	for k, v in pairs(channels) do
		channels[k] = guild:getChannel(k)
	end

	for k, v in pairs(users) do
		users[k] = client._users:_insert(v)
	end

	for k, v in pairs(roles) do
		roles[k] = guild._roles:_insert(v)
	end
end

local subCommandOptionType = discordia.enums.appCommandOptionType.subCommand
local subCommandGroupOptionType = discordia.enums.appCommandOptionType.subCommandGroup
local userOptionType = discordia.enums.appCommandOptionType.user
local channelOptionType = discordia.enums.appCommandOptionType.channel
local roleOptionType = discordia.enums.appCommandOptionType.role
local mentionableOptionType = discordia.enums.appCommandOptionType.mentionable
local attachmentOptionType = discordia.enums.appCommandOptionType.attachment

local function ParseOptions(options, resolved)
	local parsed_options = {}

	for k, v in ipairs(options) do
		local type = v.type
		local name = v.name
		local value = v.value

		if type == subCommandOptionType or type == subCommandGroupOptionType then
			parsed_options[name] = ParseOptions(v.options)
		elseif type == userOptionType then
			parsed_options[name] = resolved.members[value]
		elseif type == channelOptionType then
			parsed_options[name] = resolved.channels[value]
		elseif type == roleOptionType then
			parsed_options[name] = resolved.roles[value]
		elseif type == mentionableOptionType then
			parsed_options[name] = resolved.members[value] or resolved.roles[value]
		elseif type == attachmentOptionType then
			parsed_options[name] = resolved.attachments[value]
		else
			parsed_options[name] = v.value
		end
	end

	return parsed_options
end

local function FindFocused(options)
	local focused = {}

	for k, v in ipairs(options) do
		local type = v.type
		local name = v.name

		if type == subCommandOptionType or type == subCommandGroupOptionType then
			focused[name] = FindFocused(v.options)
		elseif v.focused then
			-- Autocomplete is made only for primitive types, so we just use v.value
			focused[name] = v.value
		end
	end

	return focused
end

do
	local applicationCommandType = discordia.enums.interactionType.applicationCommand
	local autocompleteType = discordia.enums.interactionType.applicationCommandAutocomplete
	local chatInputType = discordia.enums.appCommandType.chatInput
	local userType = discordia.enums.appCommandType.user
	local messageType = discordia.enums.appCommandType.message

	local function AugmentInteractionData(ia)
		local data = ia.data

		AugmentResolved(data.resolved, ia)

		if data.type == chatInputType then
			data.parsed_options = ParseOptions(data.options, data.resolved)

			if ia.type == autocompleteType then
				data.focused = FindFocused(data.options)
			end
		end

		return data
	end

	function Client:useSlashCommands()

		self:on("interactionCreate", function(ia)
			if ia.type == applicationCommandType then
				ia._parent:emit("applicationCommand", ia, AugmentInteractionData(ia))
			elseif ia.type == autocompleteType then 
				ia._parent:emit("applicationAutocomplete", ia, AugmentInteractionData(ia))
			end
		end)
	end
end

return Client