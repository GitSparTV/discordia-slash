local dia = require("discordia")

local tools = require("./tools.lua")

local function PrintPermissionValue(value)
	return value and "**allowed**" or "**disallowed**"
end

local function DumpPermissions(perms)
	local result = {}

	for k, v in ipairs(perms.permissions) do
		result[k] = (v.type == dia.enums.appCommandPermissionType.role and "<@&" or "<@") .. v.id
			.. ">: " .. PrintPermissionValue(v.permission)
	end

	return table.concat(result, "\n")
end

local function DumpPermissionsList(list, client, guild_id)
	local result = {}
	local cmds = client:getGuildApplicationCommands(guild_id)

	for k, v in ipairs(list) do
		local cmd = cmds:get(v.id)
		result[#result + 1] = tools.serializeApplicationCommand(cmd)
		result[#result + 1] = "Everyone: " .. PrintPermissionValue(cmd.default_permission)
		result[#result + 1] = DumpPermissions(v)
		result[#result + 1] = ""
	end

	return table.concat(result, "\n")
end

local function FindLevel(ia, root_options, path)
	for level in string.gmatch(path, "[^.]+") do
		local option

		for k, v in ipairs(root_options) do
			if v.name == level then
				if v.type ~= dia.enums.appCommandOptionType.subCommand
					and v.type ~= dia.enums.appCommandOptionType.subCommandGroup then
					return tools.argError(ia, "where", level .. "is not a subcommand/group")
				end

				if not v.options then
					v.options = {}
				end

				option = v.options
				break
			end
		end

		if not option then
			return tools.argError(ia, "where", "Subcommand/Group " .. level .. " doesn't exist")
		end

		root_options = option
	end

	return root_options
end

local endpoints = {}

endpoints["permissions.get"] = function(ia, cmd, args)
	local id = args.id

	if not id then
		local perms, err = ia.client:getGuildApplicationCommandPermissions(ia.guild.id)

		if not perms then
			return tools.userError(ia, err)
		end

		local result = DumpPermissionsList(perms, ia.client, ia.guild.id)

		local success, error = ia:reply(result, true)

		if not success then
			print(result)

			ia:reply("See console", true)
		end
	else
		local cmd, err = ia.client:getGuildApplicationCommand(ia.guild.id, id)

		if not cmd then
			return tools.argError(ia, "id", err)
		end

		local result = tools.serializeApplicationCommand(cmd)
			.. "\nEveryone: " .. PrintPermissionValue(cmd.default_permission)
		local perms = cmd:getPermissions()

		if perms then
			result = result .. "\n" .. DumpPermissions(perms)
		end

		ia:reply(result, true)
	end
end

local rolePermissionType = dia.enums.appCommandPermissionType.role
local userPermissionType = dia.enums.appCommandPermissionType.user

endpoints["permissions.set"] = function(ia, cmd, args)
	local id, what, value = args.id, args.what, args.value
	local cmd, err = ia.client:getGuildApplicationCommand(ia.guild.id, id)

	if not cmd then
		return tools.argError(ia, "id", err)
	end

	local perms = cmd:getPermissions() or {
		permissions = {}
	}

	if value == 2 then
		for k, v in ipairs(perms.permissions) do
			if v.id == what.id then
				table.remove(perms.permissions, k)

				break
			end
		end
	else
		perms.permissions[#perms.permissions + 1] = tools.permission(what, value == 0)
	end

	local data, err = cmd:editPermissions(perms)

	if not data then
		return tools.userError(ia, err)
	end

	ia:reply("Changed " .. (what.__name == "Role" and "<@&" or "<@") .. what.id .. "> permission to "
		.. (value == 2 and "**default**" or PrintPermissionValue(value == 0))
		.. " for " .. tools.serializeApplicationCommand(cmd), true)
end

function endpoints.create(ia, cmd, args)
	if args.type and args.type ~= dia.enums.appCommandType.chatInput then
		args.description = nil
	end

	local _cmd = tools.applicationCommand():setName(args.name)

		if args.description then
			_cmd:setDescription(args.description)
		end

		if args.type then
			_cmd:setType(args.type)
		end

		if args.default_permission ~= nil then
			_cmd:setDefaultPermission(args.default_permission)
		end

	local cmd, err = ia.client:createGuildApplicationCommand(ia.guild.id, _cmd)

	if not cmd then
		return tools.userError(ia, err)
	end

	ia:reply("Successfully created " .. tools.serializeApplicationCommand(cmd), true)
end

function endpoints.delete(ia, cmd, args)
	local cmd, err = ia.client:getGuildApplicationCommand(ia.guild.id, args.id)

	if not cmd then
		return tools.argError(ia, "id", err)
	end

	local data, err = cmd:delete()

	if not data then
		return tools.userError(ia, err)
	end

	ia:reply("Successfully deleted " .. tools.serializeApplicationCommand(cmd), true)
end

function endpoints.code(ia, cmd, args)
	local data, err = ia.client._api:getGuildApplicationCommand(ia.client:getApplicationInformation().id,
		ia.guild.id, args.id)

	if not data then
		return tools.argError(ia, "id", err)
	end

	local json = require("json").encode(data)

	if #json > 2000 then
		p(data)

		json = "See console"
	end

	tools.tryReply(ia, json, true)
end

local printableOptionType = {
	[dia.enums.appCommandOptionType.subCommand] = "Subcommand",
	[dia.enums.appCommandOptionType.subCommandGroup] = "Subcommand Group",
	[dia.enums.appCommandOptionType.string] = "String",
	[dia.enums.appCommandOptionType.integer] = "Integer",
	[dia.enums.appCommandOptionType.boolean] = "Boolean",
	[dia.enums.appCommandOptionType.user] = "User",
	[dia.enums.appCommandOptionType.channel] = "Channel",
	[dia.enums.appCommandOptionType.role] = "Role",
	[dia.enums.appCommandOptionType.mentionable] = "Mentionable",
	[dia.enums.appCommandOptionType.number] = "Number",
	[dia.enums.appCommandOptionType.attachment] = "Attachment",
}

local function PrintOptions(options, inserter, indent)
	indent = indent or ""

	local last = #options

	for k, v in ipairs(options) do
		local attributes = {}

		if v.required then
			attributes[#attributes + 1] = "required"
		end

		if v.choices then
			attributes[#attributes + 1] = "choices:" .. #v.choices
		end

		if v.channel_types then
			attributes[#attributes + 1] = "channel_types:" .. table.concat(v.channel_types, "+")
		end

		if v.min_value then
			attributes[#attributes + 1] = "min_value:" .. v.min_value
		end

		if v.max_value then
			attributes[#attributes + 1] = "max_value:" .. v.max_value
		end

		if v.autocomplete then
			attributes[#attributes + 1] = "autocomplete"
		end

		inserter(indent .. (k == last and "└─" or "├─") .. " `" .. v.name .. "` ("
			.. printableOptionType[v.type] .. ") – *" .. v.description .. "*"
			.. (#attributes == 0 and "" or (" [" .. table.concat(attributes, ", ") .. "]")))

		if v.options then
			PrintOptions(v.options, inserter, k == last and indent .. "      " or indent .. "│     ")
		end
	end
end

function endpoints.get(ia, cmd, args)
	local result = {}

	local function insert(v)
		result[#result + 1] = v
	end

	if args.id then
		local cmd, err = ia.client:getGuildApplicationCommand(ia.guild.id, args.id)

		if not cmd then
			return tools.argError(ia, "id", err)
		end

		insert(tools.serializeApplicationCommand(cmd))

		if cmd.description ~= "" then
			insert("*" .. cmd.description .. "*")
		end

		insert("Allowed for everyone: " .. PrintPermissionValue(cmd.default_permission))

		if cmd.options then
			insert("│")

			PrintOptions(cmd.options, insert)
		end

		result = table.concat(result, "\n")

		if #result > 2000 then
			print(result)

			result = "See console"
		end

		tools.tryReply(ia, result, true)

		return
	end

	insert("Application commands in this guild:")

	local slash, user, message = {}, {}, {}

	for k, v in pairs(ia.client:getGuildApplicationCommands(ia.guild.id)) do
		if v.type == dia.enums.appCommandType.chatInput then
			slash[#slash + 1] = v
		elseif v.type == dia.enums.appCommandType.user then
			user[#user + 1] = v
		elseif v.type == dia.enums.appCommandType.message then
			message[#message + 1] = v
		end
	end

	local function sorter(left, right)
		return left.name < right.name
	end

	table.sort(slash, sorter)
	table.sort(user, sorter)
	table.sort(message, sorter)

	if #slash ~= 0 then
		insert("Slash commands:")

		for k, v in ipairs(slash) do
			insert("`" .. v.name .. "` (" .. v.id .. ") – *" .. v.description .. "*")
		end

		insert("")
	end

	if #user ~= 0 then
		insert("User commands:")

		for k, v in ipairs(user) do
			insert("`" .. v.name .. "` (" .. v.id .. ")")
		end

		insert("")
	end

	if #message ~= 0 then
		insert("Message commands:")

		for k, v in ipairs(message) do
			insert("`" .. v.name .. "` (" .. v.id .. ")")
		end
	end

	result = table.concat(result, "\n")

	if #result > 2000 then
		print(result)

		result = "See console"
	end

	tools.tryReply(ia, result, true)
end

function endpoints.edit(ia, cmd, args)
	local cmd, err = ia.client:getGuildApplicationCommand(ia.guild.id, args.id)

	if not cmd then
		return tools.argError(ia, "id", err)
	end

	local data, err = ia.client:editGuildApplicationCommand(ia.guild.id, cmd.id, {
		name = args.name,
		description = args.description,
		default_permission = args.default_permission,
	})

	if not data then
		return tools.argError(ia, "value", err)
	end

	ia:reply("Changed fields in " .. tools.serializeApplicationCommand(cmd), true)
end

local option_actions = {
	create = function(ia, where, args)
		local place = #where + 1

		if args.required then
			for k, v in ipairs(where) do
				if not v.required then
					place = k

					break
				end
			end
		end

		if args.channel_types then
			local types = args.channel_types

			if types == 0 then
				args.channel_types = {0, 5, 6}
			elseif types == 1 then
				args.channel_types = {2}
			elseif types == 2 then
				args.channel_types = {0, 5, 6, 2}
			elseif types == 3 then
				args.channel_types = {4}
			elseif types == 4 then
				args.channel_types = {13}
			elseif types == 5 then
				args.channel_types = {2, 13}
			elseif types == 6 then
				args.channel_types = {10, 11, 12}
			elseif types == 7 then
				args.channel_types = {10, 11, 12, 0, 5, 6}
			end
		end

		local option = tools.option()
			:setType(args.type)
			:setName(args.name)
			:setDescription(args.description)


		if args.required ~= nil then
			option:setRequired(args.required)
		end

		if args.min_value then
			option:setMinValue(args.min_value)
		end

		if args.max_value then
			option:setMaxValue(args.max_value)
		end

		if args.autocomplete ~= nil then
			option:setAutocomplete(args.autocomplete)
		end

		if args.channel_types then
			option:setChannelTypes(args.channel_types)
		end


		if args.replace then
			for k, v in ipairs(where) do
				if v.name == args.name then
					where[k] = option
				end
			end
		else
			table.insert(where, place, option)
		end

		return true
	end,
	edit = function(ia, where, args)
		local found = false

		for k, v in ipairs(where) do
			if v.name == args.what then
				where = v

				found = true
			end
		end

		if not found then
			return tools.argError(ia, "what` or `where", "Option `" .. (args.where and (args.where .. ".") or "") .. args.what .. "` not found")
		end

		if args.type then
			where.type = args.type
		end

		if args.name then
			where.name = args.name
		end

		if args.description then
			where.description = args.description
		end

		if args.required ~= nil then
			where.required = args.required
		end

		if args.min_value then
			where.min_value = args.min_value
		end

		if args.max_value then
			where.max_value = args.max_value
		end

		if args.autocomplete ~= nil then
			where.autocomplete = args.autocomplete
		end

		if args.channel_types then
			local channel_types = {}

			for type in string.gmatch(args.channel_types, "%d+") do
				channel_types[#channel_types + 1] = tonumber(type)
			end

			where.channel_types = channel_types
		end

		return true
	end,
	delete = function(ia, where, args)
		if args.what == "/all" then
			for k in ipairs(where) do
				where[k] = nil
			end
		else
			local found = false

			for k, v in ipairs(where) do
				if v.name == args.what then
					table.remove(where, k)
					found = true

					break
				end
			end

			if not found then
				return tools.argError(ia, "what` or `where", "Option `" .. (args.where and (args.where .. ".") or "") .. args.what .. "` not found")
			end
		end

		return true
	end,
	move = function(ia, where, args)
		for k, v in ipairs(where) do
			if v.name == args.what then
				table.insert(where, args.place, table.remove(where, k))

				break
			end
		end

		return true
	end,
	choice = function(ia, where, args)
		local option

		for k, v in ipairs(where) do
			if v.name == args.what then
				option = v

				break
			end
		end

		if not option then
			return tools.argError(ia, "what` or `where", "Option `" .. (args.where and (args.where .. ".") or "") .. args.what .. "` not found")
		end

		local value = args.choice_value

		if option.type == dia.enums.appCommandOptionType.integer then
			local number = tonumber(value)

			if not number then
				return tools.argError(ia, "choice_value", "Choice value `" .. value .. "` can't be casted to number")
			end

			value = math.floor(number)
		elseif option.type == dia.enums.appCommandOptionType.number then
			local number = tonumber(value)

			if not number then
				return tools.argError(ia, "choice_value", "Choice value `" .. value .. "` can't be casted to number")
			end

			value = number
		end

		local choice = {
			name = args.choice_name,
			value = value
		}

		local choices = option.choices or {}

		choices[#choices + 1] = choice

		option.choices = choices

		return true
	end
}

function endpoints.option(ia, cmd, args, action, action_report)
	local cmd, err = ia.client:getGuildApplicationCommand(ia.guild.id, args.id)

	if not cmd then
		return tools.argError(ia, "id", err)
	end

	local options = cmd.options or {}

	local where = options

	if args.where then
		where = FindLevel(ia, options, args.where)
	end

	if not option_actions[action](ia, where, args) then
		return
	end

	local data, err = ia.client:editGuildApplicationCommand(ia.guild.id, cmd.id, {options = options})

	if not data then
		return tools.userError(ia, err)
	end

	ia:reply(action_report .. (args.where and (args.where .. ".") or "") .. (args.name or args.what) .. "` option in " .. tools.serializeApplicationCommand(cmd), true)
end

endpoints["option.create"] = function(ia, cmd, args)
	return endpoints.option(ia, cmd, args, "create", "Added `")
end

endpoints["option.edit"] = function(ia, cmd, args)
	return endpoints.option(ia, cmd, args, "edit", "Edited `")
end

endpoints["option.delete"] = function(ia, cmd, args)
	return endpoints.option(ia, cmd, args, "delete", "Removed `")
end

endpoints["option.move"] = function(ia, cmd, args)
	return endpoints.option(ia, cmd, args, "move", "Moved `")
end

endpoints["option.choice"] = function(ia, cmd, args)
	return endpoints.option(ia, cmd, args, "choice", "Added choice for `")
end

local function entry(CLIENT, GUILD)
	if not CLIENT or not GUILD then
		error("Client and Guild must be provided")
	end

	CLIENT:on("slashCommand", function(ia, cmd, args)
		if cmd.name == "appcmd" then
			local subcmd_args, path = tools.getSubCommand(cmd)

			local endpoint = endpoints[path]

			if endpoint then
				return endpoint(ia, cmd, subcmd_args)
			end

			return tools.userError(ia, "Unhandled request for /appcmd")
		end
	end)

	CLIENT:on("slashCommandAutocomplete", function(ia, cmd, focused)
		if cmd.name == "appcmd" then
			if cmd.focused_option.name == "id" then
				local cmds = CLIENT:getGuildApplicationCommands(ia.guild.id)
				local ac = {}
				local value = cmd.focused_option.value

				for k, v in pairs(cmds) do
					if value == "" or string.find(v.name, value, 1, true) or string.find(v.id, value, 1, true) then
						if #ac == 25 then
							break
						end

						ac[#ac + 1] = tools.choice(tools.serializeApplicationCommand(v), k)
					end
				end

				ia:autocomplete(ac)
			end
		end
	end)

	CLIENT:on("ready", function()
		local appcmd, err = CLIENT:createGuildApplicationCommand(GUILD,
			tools.slashCommand("appcmd", "Utility to edit application commands from discord")
			:addOption(
				tools.subCommand("create", "Create new command")
				:addOption(tools.string("name", "Command name"):setRequired(true))
				:addOption(tools.string("description", "Command desciption (will be ignored for non slash commands types)"):setRequired(true))
				:addOption(
					tools.integer("type", "Command type (Slash command by default)")
					:addChoice(tools.choice("chatInput (Slash Command)", dia.enums.appCommandType.chatInput))
					:addChoice(tools.choice("user (User Command)", dia.enums.appCommandType.user))
					:addChoice(tools.choice("message (Message Command)", dia.enums.appCommandType.message))
					)
				:addOption(tools.boolean("default_permission", "Command default permission (true by default)"))
				)
			:addOption(
				tools.subCommand("delete", "Delete command")
				:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
				)
			:addOption(
				tools.subCommand("get", "Get all commands or information about specific command")
				:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
				)
			:addOption(
				tools.subCommand("code", "Get command code")
				:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
				)
			:addOption(
				tools.subCommand("edit", "Edit first-level fields")
				:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
				:addOption(tools.string("name", "Command name"))
				:addOption(tools.string("description", "Command description (slash commands only)"))
				:addOption(tools.boolean("default_permission", "Command default permission (true by default)"))
				)
			:addOption(
				tools.subCommandGroup("permissions", "Edit command permissions")
				:addOption(
					tools.subCommand("get", "See permissions of all commands or specific one")
					:addOption(tools.string("id", "ApplicationCommand ID"):setAutocomplete(true))
					)
				:addOption(
					tools.subCommand("set", "Set permission for a command")
					:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
					:addOption(tools.mentionable("what", "What should have different permission"):setRequired(true))
					:addOption(
						tools.integer("value", "Value to set"):setRequired(true)
						:addChoice(tools.choice("Allow", 0))
						:addChoice(tools.choice("Disallow", 1))
						:addChoice(tools.choice("Default", 2))
						)
					)
				)
			:addOption(
				tools.subCommandGroup("option", "Option related category")
				:addOption(
					tools.subCommand("create", "Create option")
					:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
					:addOption(
						tools.integer("type", "Option type")
						:setRequired(true)
						:addChoice(tools.choice("Subcommand", dia.enums.appCommandOptionType.subCommand))
						:addChoice(tools.choice("Subcommand group", dia.enums.appCommandOptionType.subCommandGroup))
						:addChoice(tools.choice("String", dia.enums.appCommandOptionType.string))
						:addChoice(tools.choice("Integer", dia.enums.appCommandOptionType.integer))
						:addChoice(tools.choice("Boolean", dia.enums.appCommandOptionType.boolean))
						:addChoice(tools.choice("User", dia.enums.appCommandOptionType.user))
						:addChoice(tools.choice("Channel", dia.enums.appCommandOptionType.channel))
						:addChoice(tools.choice("Role", dia.enums.appCommandOptionType.role))
						:addChoice(tools.choice("Mentionable", dia.enums.appCommandOptionType.mentionable))
						:addChoice(tools.choice("Number", dia.enums.appCommandOptionType.number))
						:addChoice(tools.choice("Attachment", dia.enums.appCommandOptionType.attachment))
						)
					:addOption(tools.string("name", "Option name"):setRequired(true))
					:addOption(tools.string("description", "Option description"):setRequired(true))
					:addOption(tools.string("where", "Place to insert (example: option.create) (root level by default)"))
					:addOption(tools.boolean("required", "Is option required? (false by default)"))
					:addOption(tools.number("min_value", "Minimum value for the option (Only for integer and number types)"))
					:addOption(tools.number("max_value", "Maximum value for the option (Only for integer and number types)"))
					:addOption(tools.boolean("autocomplete", "Autocompletion feature (only for string, integer and number types, false by default)"))
					:addOption(
						tools.integer("channel_types", "Channel types allowed to pick (Only for channel type)")
						:addChoice(tools.choice("Text channels", 0))
						:addChoice(tools.choice("Voice channels", 1))
						:addChoice(tools.choice("Text and voice channels", 2))
						:addChoice(tools.choice("Categories", 3))
						:addChoice(tools.choice("Stage voice channels", 4))
						:addChoice(tools.choice("Voice and stage channels", 5))
						:addChoice(tools.choice("Threads", 6))
						:addChoice(tools.choice("Text channels and threads", 7))
						)
					:addOption(tools.boolean("replace", "Replace existing option"))
					)
				:addOption(
					tools.subCommand("edit", "Edit option")
					:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
					:addOption(tools.string("what", "Option name"):setRequired(true))
					:addOption(tools.string("where", "Place to insert (example: option.create) (root level by default)"))
					:addOption(
						tools.integer("type", "Option type")
						:addChoice(tools.choice("Subcommand", dia.enums.appCommandOptionType.subCommand))
						:addChoice(tools.choice("Subcommand group", dia.enums.appCommandOptionType.subCommandGroup))
						:addChoice(tools.choice("String", dia.enums.appCommandOptionType.string))
						:addChoice(tools.choice("Integer", dia.enums.appCommandOptionType.integer))
						:addChoice(tools.choice("Boolean", dia.enums.appCommandOptionType.boolean))
						:addChoice(tools.choice("User", dia.enums.appCommandOptionType.user))
						:addChoice(tools.choice("Channel", dia.enums.appCommandOptionType.channel))
						:addChoice(tools.choice("Role", dia.enums.appCommandOptionType.role))
						:addChoice(tools.choice("Mentionable", dia.enums.appCommandOptionType.mentionable))
						:addChoice(tools.choice("Number", dia.enums.appCommandOptionType.number))
						:addChoice(tools.choice("Attachment", dia.enums.appCommandOptionType.attachment))
						)
					:addOption(tools.string("name", "Option name"))
					:addOption(tools.string("description", "Option description"))
					:addOption(tools.boolean("required", "Is option required? (false by default)"))
					:addOption(tools.number("min_value", "Minimum value for the option (Only for integer and number types)"))
					:addOption(tools.number("max_value", "Maximum value for the option (Only for integer and number types)"))
					:addOption(tools.boolean("autocomplete", "Autocompletion feature (only for string, integer and number types, false by default)"))
					:addOption(tools.string("channel_types", "Channel types allowed to pick separated by space (Only for channel type)"))
					)
				:addOption(
					tools.subCommand("delete", "Delete option")
					:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
					:addOption(tools.string("what", "Option name"):setRequired(true))
					:addOption(tools.string("where", "Place where the option is (example: option.create) (root level by default)"))
					)
				:addOption(
					tools.subCommand("move", "Move option")
					:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
					:addOption(tools.string("what", "Option name"):setRequired(true))
					:addOption(tools.integer("place", "Order"):setRequired(true):setMinValue(1))
					:addOption(tools.string("where", "Place where the option is (example: option.create) (root level by default)"))
					)
				:addOption(
					tools.subCommand("choice", "Add choice to option")
					:addOption(tools.string("id", "ApplicationCommand ID"):setRequired(true):setAutocomplete(true))
					:addOption(tools.string("what", "Option name"):setRequired(true))
					:addOption(tools.string("choice_name", "Choice visible name"):setRequired(true))
					:addOption(tools.string("choice_value", "Choice value"):setRequired(true))
					:addOption(tools.string("where", "Place where the option is (example: option.create) (root level by default)"))
					)
				):setDefaultPermission(false)
			)

		appcmd:editPermissions({
			permissions = {
				tools.permission(CLIENT.owner, true)
			}
		})
	end)
end

return entry
