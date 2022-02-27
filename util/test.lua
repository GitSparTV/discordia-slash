local dia = require("discordia")

local function test(ia, cmd, args)
	local tbl

	local result = {"You choose:"}

	local function insert(v)
		result[#result + 1] = v
	end

	if args.subcommandgroup1 then
		insert("SubCommandGroup 1")
		tbl = args.subcommandgroup1
	else
		insert("SubCommandGroup 2")
		tbl = args.subcommandgroup2
	end

	if tbl.subcommand1 then
		insert("SubCommand 1")
		tbl = tbl.subcommand1
	else
		insert("SubCommand 2")
		tbl = tbl.subcommand2
	end

	do
		local string = tbl.string

		if string then
			insert("String: " .. string)
		end
	end

	do
		local integer = tbl.integer

		if integer then
			insert("Integer: " .. integer)
		end
	end

	do
		local boolean = tbl.boolean

		if boolean then
			insert("Boolean: " .. tostring(boolean))
		end
	end

	do
		local number = tbl.number

		if number then
			insert("Number: " .. number)
		end
	end

	do
		local user = tbl.user

		if user then
			insert("User: <@" .. user.id .. ">")
		end
	end

	do
		local channel = tbl.channel

		if channel then
			insert("Channel: <#" .. channel.id .. ">")
		end
	end

	do
		local role = tbl.role

		if role then
			insert("Role: <@&" .. role.id .. ">")
		end
	end

	do
		local mentionable = tbl.mentionable

		if mentionable then
			insert("Mentionable: " .. (mentionable.__name == "Role" and "<@&" or "<@") .. mentionable.id .. ">")
		end
	end

	do
		local attachment = tbl.attachment

		if attachment then
			insert("Attachment: " .. (attachment.content_type or attachment.filename))
		end
	end

	return ia:reply(table.concat(result, "\n"), true)
end

return function(CLIENT, GUILD)
	if not CLIENT or not GUILD then
		error("Client and Guild must be provided")
	end

	CLIENT:on("slashCommand", function(ia, cmd, args)
		if cmd.name == "test" then
			test(ia, cmd, args)
		end
	end)

	CLIENT:on("ready", function()
		CLIENT:createGuildApplicationCommand(GUILD, {
			name = "test",
			description = "Testing slash commands",
			type = dia.enums.appCommandType.chatInput,
			options = {
				{
					type = dia.enums.appCommandOptionType.subCommandGroup,
					name = "subcommandgroup1",
					description = "subcommandgroup1 description",
					options = {
						{
							type = dia.enums.appCommandOptionType.subCommand,
							name = "subcommand1",
							description = "subcommand1 description",
							options = {
								{
									type = dia.enums.appCommandOptionType.string,
									name = "string",
									description = "string description",
								},
								{
									type = dia.enums.appCommandOptionType.integer,
									name = "integer",
									description = "integer description",
								},
								{
									type = dia.enums.appCommandOptionType.boolean,
									name = "boolean",
									description = "boolean description",
								},
								{
									type = dia.enums.appCommandOptionType.number,
									name = "number",
									description = "number description",
								},
								{
									type = dia.enums.appCommandOptionType.user,
									name = "user",
									description = "user description",
								},
								{
									type = dia.enums.appCommandOptionType.channel,
									name = "channel",
									description = "channel description",
								},
								{
									type = dia.enums.appCommandOptionType.role,
									name = "role",
									description = "role description",
								},
								{
									type = dia.enums.appCommandOptionType.mentionable,
									name = "mentionable",
									description = "mentionable description",
								},
								{
									type = dia.enums.appCommandOptionType.attachment,
									name = "attachment",
									description = "attachment description",
								}
							}
						},
						{
							type = dia.enums.appCommandOptionType.subCommand,
							name = "subcommand2",
							description = "See permissions",
							options = {
								{
									type = dia.enums.appCommandOptionType.string,
									name = "string",
									description = "string description",
								},
								{
									type = dia.enums.appCommandOptionType.integer,
									name = "integer",
									description = "integer description",
								},
								{
									type = dia.enums.appCommandOptionType.boolean,
									name = "boolean",
									description = "boolean description",
								},
								{
									type = dia.enums.appCommandOptionType.number,
									name = "number",
									description = "number description",
								},
								{
									type = dia.enums.appCommandOptionType.user,
									name = "user",
									description = "user description",
								},
								{
									type = dia.enums.appCommandOptionType.channel,
									name = "channel",
									description = "channel description",
								},
								{
									type = dia.enums.appCommandOptionType.role,
									name = "role",
									description = "role description",
								},
								{
									type = dia.enums.appCommandOptionType.mentionable,
									name = "mentionable",
									description = "mentionable description",
								},
								{
									type = dia.enums.appCommandOptionType.attachment,
									name = "attachment",
									description = "attachment description",
								}
							}
						}
					}
				},
				{
					type = dia.enums.appCommandOptionType.subCommandGroup,
					name = "subcommandgroup2",
					description = "subcommandgroup2 description",
					options = {
						{
							type = dia.enums.appCommandOptionType.subCommand,
							name = "subcommand1",
							description = "subcommand1 description",
							options = {
								{
									type = dia.enums.appCommandOptionType.string,
									name = "string",
									description = "string description",
								},
								{
									type = dia.enums.appCommandOptionType.integer,
									name = "integer",
									description = "integer description",
								},
								{
									type = dia.enums.appCommandOptionType.boolean,
									name = "boolean",
									description = "boolean description",
								},
								{
									type = dia.enums.appCommandOptionType.number,
									name = "number",
									description = "number description",
								},
								{
									type = dia.enums.appCommandOptionType.user,
									name = "user",
									description = "user description",
								},
								{
									type = dia.enums.appCommandOptionType.channel,
									name = "channel",
									description = "channel description",
								},
								{
									type = dia.enums.appCommandOptionType.role,
									name = "role",
									description = "role description",
								},
								{
									type = dia.enums.appCommandOptionType.mentionable,
									name = "mentionable",
									description = "mentionable description",
								},
								{
									type = dia.enums.appCommandOptionType.attachment,
									name = "attachment",
									description = "attachment description",
								}
							}
						},
						{
							type = dia.enums.appCommandOptionType.subCommand,
							name = "subcommand2",
							description = "See permissions",
							options = {
								{
									type = dia.enums.appCommandOptionType.string,
									name = "string",
									description = "string description",
								},
								{
									type = dia.enums.appCommandOptionType.integer,
									name = "integer",
									description = "integer description",
								},
								{
									type = dia.enums.appCommandOptionType.boolean,
									name = "boolean",
									description = "boolean description",
								},
								{
									type = dia.enums.appCommandOptionType.number,
									name = "number",
									description = "number description",
								},
								{
									type = dia.enums.appCommandOptionType.user,
									name = "user",
									description = "user description",
								},
								{
									type = dia.enums.appCommandOptionType.channel,
									name = "channel",
									description = "channel description",
								},
								{
									type = dia.enums.appCommandOptionType.role,
									name = "role",
									description = "role description",
								},
								{
									type = dia.enums.appCommandOptionType.mentionable,
									name = "mentionable",
									description = "mentionable description",
								},
								{
									type = dia.enums.appCommandOptionType.attachment,
									name = "attachment",
									description = "attachment description",
								}
							}
						}
					}
				}
			}
		})
	end)
end