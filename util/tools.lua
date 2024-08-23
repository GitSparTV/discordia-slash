local dia = require("discordia")

local tools = {}

do
	local cache = {}

	local subCommandOptionType = dia.enums.appCommandOptionType.subCommand
	local subCommandGroupOptionType = dia.enums.appCommandOptionType.subCommandGroup

	function tools.getSubCommand(cmd)
		local options = cmd.options

		if not options then
			return nil, ""
		end

		local level = 0
		local parsed_options = cmd.parsed_options

		::next::

		for k, v in ipairs(options) do
			local type = v.type

			if type == subCommandGroupOptionType then
				options = v.options
				parsed_options = parsed_options[v.name]

				level = level + 1
				cache[level] = v.name

				goto next
			elseif type == subCommandOptionType then
				options = v.options
				parsed_options = parsed_options[v.name]

				level = level + 1
				cache[level] = v.name

				return parsed_options, table.concat(cache, ".", 1, level)
			end
		end

		return parsed_options, ""
	end
end

function tools.userError(ia, err)
	io.write("InteractionError (", ia.data.id, ") by ", ia.member.id, ". Error: ", tostring(err), "\n")

	ia:reply("**Interaction Error**\n" .. tostring(err), true)
end

function tools.devError(ia, err, trace)
	trace = tostring(trace) or debug.traceback(nil, 2)

	io.write("InteractionError (", ia.data.id, ") by ", ia.member.id, ". Error: ", tostring(err), "\n", trace)

	ia:reply("**Interaction Error**\n" .. tostring(err) .. "\n```lua\n" .. trace .. "\n```", true)
end

function tools.argError(ia, arg, comment)
	ia:reply("**Invalid argument `" .. arg .. "`**" .. (comment and ("\n\n" .. comment) or ""), true)
end

function tools.serializeApplicationCommand(cmd)
	return "`" .. cmd.name .. "` [" .. cmd.printableType .. "] (" .. cmd.id .. ")"
end

function tools.tryReply(ia, content, ephemeral)
	local success, error = ia:reply(content, ephemeral)

	if not success then
		tools.userError(ia, error)
	end
end

function tools.choice(name, value)
	return {name = name, value = value}
end

function tools.userPermission(user_id, allow_type)
	if not user_id then
		error("user_id must not be nil")
	end

	return {
		id = user_id,
		type = dia.enums.appCommandPermissionType.user,
		permission = allow_type
	}
end

function tools.rolePermission(role_id, allow_type)
	if not role_id then
		error("role_id must not be nil")
	end

	return {
		id = role_id,
		type = dia.enums.appCommandPermissionType.role,
		permission = allow_type
	}
end

function tools.permission(object, allow_type)
	if not object then
		error("object must not be nil")
	end

	return {
		id = object.id,
		type = object.__name == "Role" and dia.enums.appCommandPermissionType.role or dia.enums.appCommandPermissionType.user,
		permission = allow_type
	}
end

local commandMeta = {}
commandMeta.__index = commandMeta

function commandMeta:setName(name)
	if not name then
		error("name must not be nil")
	end

	self.name = name

	return self
end

function commandMeta:setDescription(description)
	if not description then
		error("description must not be nil")
	end

	self.description = description

	return self
end

function commandMeta:addOption(option)
	if not option then
		error("option must not be nil")
	end

	if not self.options then
		self.options = {option}
	else
		self.options[#self.options + 1] = option
	end

	return self
end

function commandMeta:setOptions(options)
	if options then
		error("options must not be nil")
	end

	self.options = options

	return self
end

function commandMeta:setType(type)
	if not type then
		error("type must not be nil")
	end

	self.type = type

	return self
end

function commandMeta:setDefaultPermission(default_permission)
	if default_permission == nil then
		error("default_permission must not be nil")
	end

	self.default_permission = default_permission

	return self
end

function tools.applicationCommand()
	return setmetatable({}, commandMeta)
end

function tools.slashCommand(name, description)
	return tools.applicationCommand():setName(name):setDescription(description):setType(dia.enums.appCommandType.chatInput)
end

function tools.userCommand(name)
	return tools.applicationCommand():setName(name):setType(dia.enums.appCommandType.user)
end

function tools.messageCommand(name)
	return tools.applicationCommand():setName(name):setType(dia.enums.appCommandType.message)
end

local optionMeta = {
	setName = commandMeta.setName,
	setDescription = commandMeta.setDescription,
	setType = commandMeta.setType,
	addOption = commandMeta.addOption,
	setOptions = commandMeta.setOptions
}
optionMeta.__index = optionMeta

function optionMeta:setRequired(required)
	if required == nil then
		error("required must not be nil")
	end

	self.required = required

	return self
end

function optionMeta:addChoice(choice)
	if not choice then
		error("choice must not be nil")
	end

	if not self.choices then
		self.choices = {choice}
	else
		self.choices[#self.choices + 1] = choice
	end

	return self
end

function optionMeta:setChoices(choices)
	if choices then
		error("choices must not be nil")
	end

	self.choices = choices

	return self
end

function optionMeta:addChannelType(channel_type)
	if not channel_type then
		error("channel_type must not be nil")
	end

	if not self.choices then
		self.channel_types = {channel_type}
	else
		self.channel_types[#self.channel_types + 1] = channel_type
	end

	return self
end

function optionMeta:setChannelTypes(channel_types)
	if channel_types then
		error("channel_types must not be nil")
	end

	self.channel_types = channel_types

	return self
end

function optionMeta:setMinValue(min_value)
	if min_value == nil then
		error("min_value must not be nil")
	end

	self.min_value = min_value

	return self
end

function optionMeta:setMaxValue(max_value)
	if max_value == nil then
		error("max_value must not be nil")
	end

	self.max_value = max_value

	return self
end

function optionMeta:setAutocomplete(autocomplete)
	if autocomplete == nil then
		error("autocomplete must not be nil")
	end

	self.autocomplete = autocomplete

	return self
end

function tools.option()
	return setmetatable({}, optionMeta)
end

function tools.subCommand(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.subCommand)
end

function tools.subCommandGroup(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.subCommandGroup)
end

function tools.string(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.string)
end

function tools.integer(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.integer)
end

function tools.boolean(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.boolean)
end

function tools.user(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.user)
end

function tools.channel(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.channel)
end

function tools.role(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.role)
end

function tools.mentionable(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.mentionable)
end

function tools.number(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.number)
end

function tools.attachment(name, description)
	return tools.option():setName(name):setDescription(description):setType(dia.enums.appCommandOptionType.attachment)
end

return tools
