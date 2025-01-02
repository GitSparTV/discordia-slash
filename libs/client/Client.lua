local Client = {}
local discordia = require("discordia")
require("discordia-interactions")

local Cache = discordia.class.classes.Cache
local ApplicationCommand = require("containers/ApplicationCommand")

function Client:getGlobalApplicationCommands()
	local data, err = self._api:getGlobalApplicationCommands(self._user._id)

	if data then
		return Cache(data, ApplicationCommand, self)
	else
		return nil, err
	end
end

function Client:createGlobalApplicationCommand(id, payload)
	local data, err = self._api:createGlobalApplicationCommand(self._user._id, id)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:getGlobalApplicationCommand(id)
	local data, err = self._api:getGlobalApplicationCommand(self._user._id, id)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:editGlobalApplicationCommand(id, payload)
	local data, err = self._api:editGlobalApplicationCommand(self._user._id, id, payload)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:deleteGlobalApplicationCommand(id)
	local data, err = self._api:deleteGlobalApplicationCommand(self._user._id, id)

	if data then
		return data
	else
		return nil, err
	end
end

function Client:getGuildApplicationCommands(guild_id)
	local data, err = self._api:getGuildApplicationCommands(self._user._id, guild_id)

	if data then
		return Cache(data, ApplicationCommand, self)
	else
		return nil, err
	end
end

function Client:createGuildApplicationCommand(guild_id, id, payload)
	local data, err = self._api:createGuildApplicationCommand(self._user._id, guild_id, id)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:getGuildApplicationCommand(guild_id, id)
	local data, err = self._api:getGuildApplicationCommand(self._user._id, guild_id, id)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:editGuildApplicationCommand(guild_id, id, payload)
	local data, err = self._api:editGuildApplicationCommand(self._user._id, guild_id, id, payload)

	if data then
		return ApplicationCommand(data, self)
	else
		return nil, err
	end
end

function Client:deleteGuildApplicationCommand(guild_id, id)
	local data, err = self._api:deleteGuildApplicationCommand(self._user._id, guild_id, id)

	if data then
		return data
	else
		return nil, err
	end
end

function Client:getGuildApplicationCommandPermissions(guild_id)
	local data, err = self._api:getGuildApplicationCommandPermissions(self._user._id, guild_id)

	if data then
		return data
	else
		return nil, err
	end
end

function Client:getApplicationCommandPermissions(guild_id, id)
	local data, err = self._api:getApplicationCommandPermissions(self._user._id, guild_id, id)

	if data then
		return data
	else
		return nil, err
	end
end

function Client:editApplicationCommandPermissions(guild_id, id, payload)
	local data, err = self._api:editApplicationCommandPermissions(self._user._id, guild_id, id, payload)

	if data then
		return data
	else
		return nil, err
	end
end

local function AugmentResolved(ia)
	local resolved = ia.data.resolved

	if not resolved then return end

	local guild = ia.guild
	local channel = ia.channel
	local client = ia.client

	do
		local users = resolved.users

		if users then
			for k, v in pairs(users) do
				users[k] = client._users:_insert(v)
			end
		end
	end

	do
		local members = resolved.members

		if members then
			for k, v in pairs(members) do
				members[k] = guild:getMember(k)
			end
		end
	end

	do
		local roles = resolved.roles

		if roles then
			for k, v in pairs(roles) do
				roles[k] = guild._roles:_insert(v)
			end
		end
	end

	do
		local channels = resolved.channels

		if channels then
			for k, v in pairs(channels) do
				channels[k] = guild:getChannel(k)
			end
		end
	end

	do
		local messages = resolved.messages

		if messages then
			for k, v in pairs(messages) do
				if channel then
					messages[k] = channel:getMessage(k)
				end
			end
		end
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
	if not options then return end

	local parsed_options = {}

	for k, v in ipairs(options) do
		local type = v.type
		local name = v.name
		local value = v.value

		if type == subCommandOptionType or type == subCommandGroupOptionType then
			parsed_options[name] = ParseOptions(v.options, resolved)
		elseif type == userOptionType then
			parsed_options[name] = (resolved.members and resolved.members[value]) or resolved.users[value]
		elseif type == channelOptionType then
			parsed_options[name] = resolved.channels[value]
		elseif type == roleOptionType then
			parsed_options[name] = resolved.roles[value]
		elseif type == mentionableOptionType then
			parsed_options[name] = (resolved.members and resolved.members[value]) or (resolved.users and resolved.users[value]) or (resolved.roles and resolved.roles[value])
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
	local focused_object

	for k, v in ipairs(options) do
		local type = v.type
		local name = v.name

		if type == subCommandOptionType or type == subCommandGroupOptionType then
			focused[name], focused_object = FindFocused(v.options)

			if focused_object then break end
		elseif v.focused then
			-- Autocomplete can be applied only for primitive types, so we just use v.value
			focused[name] = v.value
			focused_object = v
			break
		end
	end

	return focused, focused_object
end

do
	local chatInputType = discordia.enums.appCommandType.chatInput
	local userType = discordia.enums.appCommandType.user
	local messageType = discordia.enums.appCommandType.message
	local applicationCommandType = discordia.enums.interactionType.applicationCommand
	local autocompleteType = discordia.enums.interactionType.applicationCommandAutocomplete

	function Client:useApplicationCommands()
		self:on("interactionCreate", function(ia)
			if ia.type == applicationCommandType then
				local data = ia.data

				AugmentResolved(ia)

				if data.type == chatInputType then
					data.parsed_options = ParseOptions(data.options, data.resolved)

					ia.client:emit("slashCommand", ia, data, data.parsed_options)
				elseif data.type == messageType then
					data.message = data.resolved.messages[data.target_id]

					ia.client:emit("messageCommand", ia, data, data.message)
				elseif data.type == userType then
					data.member = data.resolved.members[data.target_id]

					ia.client:emit("userCommand", ia, data, data.member)
				end
			elseif ia.type == autocompleteType then
				local data = ia.data

				AugmentResolved(ia)

				data.parsed_options = ParseOptions(data.options, data.resolved)
				data.focused, data.focused_option = FindFocused(data.options)

				ia.client:emit("slashCommandAutocomplete", ia, data, data.focused_option, data.parsed_options)
			end
		end)

		-- support chaining
		return self
	end
end

return Client
