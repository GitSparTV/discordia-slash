local discordia = require("discordia")
local endpoints = require('./endpoints')
local enums = require('./enums')
local f = string.format
local AC = require('./ApplicationCommand')
local IA = require('./Interaction')
local client_m = discordia.Client
local guild_m = discordia.class.classes.Guild
local cache_m = discordia.class.classes.Cache
-- local enumsInteractionTypePing = enums.interactionType.ping
local sanitizeOptions

local typeConverter = {
	[enums.optionType.string] = function(val)
		if type(val) ~= "string" then return end

		return val
	end,
	[enums.optionType.integer] = function(val)
		if type(val) ~= "number" then return end

		return val
	end,
	[enums.optionType.boolean] = function(val)
		if type(val) ~= "boolean" then return end

		return val
	end,
	[enums.optionType.user] = function(val, args)
		if type(val) ~= "string" then return end

		return args[0]._guild:getMember(val)
	end,
	[enums.optionType.channel] = function(val, args)
		if type(val) ~= "string" then return end

		return args[0]._guild:getChannel(val)
	end,
	[enums.optionType.role] = function(val, args)
		if type(val) ~= "string" then return end

		return args[0]._guild:getRole(val)
	end,
}

function sanitizeOptions(args, options, cmd_options, params)
	for k = 1, #options do
		local v = options[k]
		local name = v.name

		if params[name] then
			args[1]:warning('Option "%s" in slash command %s "%s" from guild %s, channel %s, member %s was already specified!', name, args[2]._id, args[2]._name, args.guild_id, args.channel_id, args.member.user.id)

			return false
		end

		local cmdOption = cmd_options[name]

		if not cmdOption then
			args[1]:warning('Unknown option "%s" in slash command %s "%s" from guild %s, channel %s, member %s!', name, args[2]._id, args[2]._name, args.guild_id, args.channel_id, args.member.user.id)

			return false
		end

		local type = cmdOption.type

		if type <= 2 then
			local subparams = {}
			local suboptions = v.options

			if options.group then
				args[1]:warning('Slash command %s "%s" from guild %s, channel %s, member %s has multiple selected sub-options!', args[2]._id, args[2]._name, args.guild_id, args.channel_id, args.member.user.id)

				return false
			end

			options.group = v

			if suboptions then
				local stat = sanitizeOptions(args, v.options, cmdOption.mapoptions, subparams)
				if not stat then return false end
			end

			params[name] = subparams
		else
			local res = typeConverter[type](v.value, args)
			if res == nil then return false end
			params[name] = res
			local choices = cmdOption.choices

			if choices and type <= 4 then
				local cmd = args[2]
				local t = cmd._mapchoices

				if not t then
					t = {}
					cmd._mapchoices = t
				end

				local mapchoices = t[cmdOption]

				if not mapchoices then
					mapchoices = {}
					t[cmdOption] = mapchoices

					for k = 1, #choices do
						mapchoices[choices[k].value] = true
					end
				end

				if not mapchoices[params[name]] then
					args[1]:warning('Option "%s" from guild %s, channel %s, member %s received unspecified choice "%s"!', name, args.guild_id, args.channel_id, args.member.user.id, params[name])

					return false
				end
			end
		end
	end

	return true
end

local function checkRequired(args, cmd_options, params)
	for k = 1, #cmd_options do
		local v = cmd_options[k]

		if v.type <= 2 then
			local options = v.options
			local subparams = params[v.name]

			if options and subparams then
				local stat = checkRequired(args, options, subparams)
				if not stat then return false end
			end
		else
			if v.required and not params[v.name] then
				args[1]:warning('Option "%s" in slash command %s "%s" from guild %s, channel %s is required but member %s didn\'t specify it!', v.name, args[2]._id, args[2]._name, args.guild_id, args.channel_id, args.member.user.id)

				return false
			end
		end
	end

	return true
end

function Use(client)
	if not client then
		error("Client instance is required")
	end

	function client._events.INTERACTION_CREATE(args, client)
		-- if args.type == enumsInteractionTypePing then
		-- 	client._api:request('GET', f(endpoints.INTERACTION_RESPONSE_CREATE, args.id, args.token), {
		-- 		type = enums.interactionResponseType.pong
		-- 	})
		-- 	return
		-- end
		-- For webhooks
		local ia = IA(args, client)
		local data = args.data
		local cmd = client:getSlashCommand(data.id)
		if not cmd then return end
		if data.name ~= cmd._name then return client:warning('Slash command %s "%s" name doesn\'t match with interaction response, got "%s"! Guild %s, channel %s, member %s', cmd._id, cmd._name, data.name, args.guild_id, args.channel_id, args.member.user.id) end
		local options = data.options
		local cmd_options = cmd._mapoptions
		-- p(cmd_options)
		local params = {}
		args[0] = ia
		args[1] = client
		args[2] = cmd

		if options and not sanitizeOptions(args, options, cmd_options, params) or not checkRequired(args, cmd._options, params) then
			local cb = cmd._onfail
			print("Cmd Failed")
			if not cb then return end
			cb(ia, params, cmd)

			return
		end

		for k, v in pairs(params) do
			print(k, v)
		end

		-- p(options)
		local cb = cmd._callback
		if not cb then return client:warning('Unhandled slash command interaction: %s "%s" (%s)!', cmd._id, cmd._name, cmd._guild and "Guild " .. cmd._guild.id or "Global") end
		cb(ia, params, cmd)
	end

	-- function client._events.APPLICATION_COMMAND_CREATE(...)
	-- p("APPLICATION_COMMAND_CREATE", ...)
	-- end
	client:once("ready", function()
		local id = client:getApplicationInformation().id
		client._slashid = id
		client._globalCommands = {}
		client._guildCommands = {}
		client:getSlashCommands()
		client:emit("slashCommandsReady")
	end)
end

function client_m:slashCommand(data)
	local found
	local name = data.name

	for _, v in pairs(self._globalCommands) do
		if v._name == name then
			found = v
			break
		end
	end

	local cmd = AC(data, self)

	if found then
		if not found:_compare(cmd) then
			found:_merge(cmd)
		end

		return found
	else
		cmd:publish()
		self._globalCommands:_insert(cmd)
	end

	return cmd
end

function guild_m:slashCommand(data)
	local found
	local name = data.name

	if not self._slashCommands then
		self:getSlashCommands()
	end

	for _, v in pairs(self._slashCommands) do
		if v._name == name then
			found = v
			break
		end
	end

	local cmd = AC(data, self)

	if found then
		if not found:_compare(cmd) then
			print("difference, merged")
			found:_merge(cmd)
		else
			print("the same")

			if not found._callback then
				found._callback = cmd._callback
			end
		end

		return found
	else
		print("new command")

		if cmd:publish() then
			self._slashCommands:_insert(cmd)
		else
			return nil
		end
	end

	return cmd
end

function client_m:getSlashCommands()
	local list = self._api:request('GET', f(endpoints.COMMANDS, self._slashid))
	local cache = cache_m(list, AC, self)
	self._globalCommands = cache

	return cache
end

function guild_m:getSlashCommands()
	local list = self.client._api:request('GET', f(endpoints.COMMANDS_GUILD, self.client._slashid, self.id))
	local cache = cache_m(list, AC, self)
	self._slashCommands = cache
	self.client._guildCommands[self] = cache

	return cache
end

function client_m:getSlashCommand(id)
	local g = self._globalCommands:get(id)
	if g then return g end

	for k, v in pairs(self._guildCommands) do
		g = v:get(id)
		if g then return g end
	end
end

return Use