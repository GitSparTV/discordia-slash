local discordia = require("discordia")
local endpoints = require('./endpoints')
local f = string.format
local AC = require('./ApplicationCommand')
local IA = require('./Interaction')
local client_m = discordia.Client
local guild_m = discordia.class.classes.Guild
local cache_m = discordia.class.classes.Cache
local enums = require('./enums')

local typeConverter = {
	[enums.optionType.string] = function(val) return val end,
	[enums.optionType.integer] = function(val) return val end,
	[enums.optionType.boolean] = function(val) return val end,
	[enums.optionType.user] = function(val, args) return args:getMember(val) end,
	[enums.optionType.channel] = function(val, args) return args:getChannel(val) end,
	[enums.optionType.role] = function(val, args) return args:getRole(val) end,
}

local subCommand = enums.optionType.subCommand
local subCommandGroup = enums.optionType.subCommandGroup

local function makeParams(data, guild, output)
	output = output or {}

	for k, v in ipairs(data) do
		if v.type == subCommand or v.type == subCommandGroup then
			local t = {}
			output[v.name] = t
			makeParams(v.options, guild, t)
		else
			output[v.name] = typeConverter[v.type](v.value, guild)
		end
	end

	return output
end

function client_m:useSlashCommands()
	self._slashCommandsInjected = true

	function self._events.INTERACTION_CREATE(args, client)
		local data = args.data
		local cmd = client:getSlashCommand(data.id)
		if not cmd then return client:warning('Uncached slash command (%s) on INTERACTION_CREATE', data.id) end
		if data.name ~= cmd._name then return client:warning('Slash command %s "%s" name doesn\'t match with interaction response, got "%s"! Guild %s, channel %s, member %s', cmd._id, cmd._name, data.name, args.guild_id, args.channel_id, args.member.user.id) end
		local ia = IA(args, client)
		local params = makeParams(data.options, ia.guild)
		local cb = cmd._callback
		if not cb then return client:warning('Unhandled slash command interaction: %s "%s" (%s)!', cmd._id, cmd._name, cmd._guild and "Guild " .. cmd._guild.id or "Global") end
		cb(ia, params, cmd)
	end

	self:once("ready", function()
		local id = self:getApplicationInformation().id
		self._slashid = id
		self._globalCommands = {}
		self._guildCommands = {}
		self:getSlashCommands()
		self:emit("slashCommandsReady")
	end)

	return self
end

function client_m:slashCommand(data)
	local found

	if not self._globalCommands then
		self:getSlashCommands()
	end

	do
		local name = data.name

		for _, v in pairs(self._globalCommands) do
			if v._name == name then
				found = v
				break
			end
		end
	end

	local cmd = AC(data, self)

	if found then
		if not found:_compare(cmd) then
			found:_merge(cmd)
		elseif not found._callback then
			found._callback = cmd._callback
		end

		return found
	else
		if cmd:publish() then
			self._globalCommands:_insert(cmd)
		else
			return nil
		end
	end

	return cmd
end

function guild_m:slashCommand(data)
	local found

	if not self._slashCommands then
		self:getSlashCommands()
	end

	do
		local name = data.name

		for _, v in pairs(self._slashCommands) do
			if v._name == name then
				found = v
				break
			end
		end
	end

	local cmd = AC(data, self)

	if found then
		if not found:_compare(cmd) then
			found:_merge(cmd)
		elseif not found._callback then
			found._callback = cmd._callback
		end

		return found
	else
		if cmd:publish() then
			self._slashCommands:_insert(cmd)
		else
			return nil
		end
	end

	return cmd
end

function client_m:getSlashCommands()
	local list, err = self._api:request('GET', f(endpoints.COMMANDS, self._slashid))
	if not list then return nil, err end
	local cache = cache_m(list, AC, self)
	self._globalCommands = cache

	return cache
end

function guild_m:getSlashCommands()
	local list, err = self.client._api:request('GET', f(endpoints.COMMANDS_GUILD, self.client._slashid, self.id))
	if not list then return nil, err end
	local cache = cache_m(list, AC, self)
	self._slashCommands = cache
	self.client._guildCommands[self] = cache

	return cache
end

function client_m:getSlashCommand(id)
	local g = self._globalCommands:get(id)
	if g then return g end

	for _, v in pairs(self._guildCommands) do
		g = v:get(id)
		if g then return g end
	end

	return nil
end