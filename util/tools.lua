local dia = require("discordia")

local tools = {}

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

function tools.userError(ia, err)
	io.write("InteractionError (", ia.data.id, ")", "by ", ia.member.id, ". Error: ", tostring(err), "\n")

	ia:reply("**Interaction Error**\n" .. tostring(err), true)
end

function tools.devError(ia, err, trace)
	trace = tostring(trace) or debug.traceback(nil, 2)

	io.write("InteractionError (", ia.data.id, ")", "by ", ia.member.id, ". Error: ", tostring(err), "\n", trace)

	ia:reply("**Interaction Error**\n" .. tostring(err) .. "\n```lua\n" .. trace .. "\n```", true)
end

function tools.argError(ia, arg, comment)
	ia:reply("**Invalid argument `" .. arg .. "`**\n\n" .. comment, true)
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

return tools