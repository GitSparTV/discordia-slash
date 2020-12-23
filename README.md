# discordia-slash
**[Discordia](https://github.com/SinisterRectus/Discordia) 2.0 extension for [slash commands](https://discord.com/developers/docs/interactions/slash-commands).**

## Features
- Entirely strictly sanitized interaction response. Any incorrect type, unknown option, unknown choice, missing required option, duplicated, etc. Everything wrong is ignored.
- Easy setup.
- Additional command constructor.
- Sub-command and sub-command group supported.

## Note
This is extension and is not meant to be used on guild without `bot` scope, instead if provides additional power for bot.

Updating global commands might reject all members requests because they might have old version of the command. This is a downside of a strict sanitization.

## Install
```sh
lit install GitSparTV/discordia-slash
```
or use GitHub

## API
This library works as extension thus requires injection into `Client` instance.

```lua
local dis = require("discordia")
local slash = require("discordia-slash")

local client = dis.Client():useSlashCommands()
```

To setup commands you can't use `client:on("ready", func)` instead use `client:on("slashCommandsReady", func)`.

### `Client:slashCommand(commandData)`
Registers global slash command. Finds existing command, if `commandData` is different from it, merges changes, otherwise returns existing object without making a HTTP request. 

Requires `commandData` table in [this format](https://discord.com/developers/docs/interactions/slash-commands#create-guild-application-command-json-params).

To interact with the command you must define `callback` field. Additional `onfail` field can be defined to catch sanitization fails. `callback` and `onfail` parameters are explained [here](#commandtemplatecallbackcb).

Returns `ApplicationCommand` object. `nil` on failure.

Check slash command constructor for easier command building.

```lua
client:on("slashCommandsReady", function()
	client:slashCommand({
		name = "test",
		description = "desc",
		options = {
			{
				name = "arg",
				description = "argdesc",
				type = slash.enums.optionType.string,
				required = true
			}
		},
		callback = function(ia, params, cmd)

		end
	})
end)
```

### `Guild:slashCommand(commandData)`
Registers guild slash command. Finds existing command, if `commandData` is different from it, merges changes, otherwise returns existing object without making a HTTP request. 

Requires `commandData` table in [this format](https://discord.com/developers/docs/interactions/slash-commands#create-guild-application-command-json-params).

To interact with the command you must define `callback` field. Additional `onfail` field can be defined to catch sanitization fails. `callback` and `onfail` parameters are explained [here](#commandtemplatecallbackcb).


Returns `ApplicationCommand` object. `nil` on failure.

Check slash command constructor for easier command building.

```lua
client:on("slashCommandsReady", function()
	local g = CLIENT:getGuild("guildid")
	g:slashCommand({
		name = "test",
		description = "desc",
		options = {
			{
				name = "arg",
				description = "argdesc",
				type = slash.enums.optionType.string,
				required = true
			}
		},
		callback = function(ia, params, cmd)

		end
	})
end)
```

### `Client:getSlashCommands()`
Returns `Cache` of global `ApplicationCommand`'s. `nil, err` on failure.

### `Guild:getSlashCommands()`
Returns `Cache` of guild `ApplicationCommand`'s. `nil, err` on failure.

### `Client:getSlashCommand(id)`
Finds a slash command across all global and guilds using `id`, returns `ApplicationCommand` if found, otherwise `nil`.

### ApplicationCommand

### `ApplicationCommand:publish()`
Registers the command, this is used internally by `Client:slashCommand` and `Guild:slashCommand`. This function assigns `id` to the command. If command already have `id`, `ApplicationCommand:edit()` is called instead.

### `ApplicationCommand:edit()`
Edits the command.

### `ApplicationCommand:setName(name)`
Sets the name of the command. Note, this doesn't send HTTP request, you must call `ApplicationCommand:edit()` by yourself.

### `ApplicationCommand:setDescription(description)`
Sets the description of the command. Note, this doesn't send HTTP request, you must call `ApplicationCommand:edit()` by yourself.

### `ApplicationCommand:setOptions(options)`
Sets the options of the command. Note, this doesn't send HTTP request, you must call `ApplicationCommand:edit()` by yourself.

### `ApplicationCommand:setCallback(callback)`
Sets the callback of the command. Note, this doesn't send HTTP request, you must call `ApplicationCommand:edit()` by yourself.

### `ApplicationCommand:setOnFail(callback)`
Sets the onFail callback of the command. Note, this doesn't send HTTP request, you must call `ApplicationCommand:edit()` by yourself.

### `ApplicationCommand:delete()`
Deletes the command, after this call the command must not be used.

### `ApplicationCommand:_compare(cmd)`
Used internally to compare existing command data with new one.

### `ApplicationCommand:_merge(cmd)`
Used internally to merge data of `cmd` to `self`.

### `ApplicationCommand.name`
Returns `name`.

### `ApplicationCommand.description`
Returns `description`.

### `ApplicationCommand.options`
Returns `options`.

### `ApplicationCommand.guild`
Returns `guild`.

### `ApplicationCommand.callback`
Returns `callback`.

### `ApplicationCommand.onFail`
Returns `onFail`.

### Interaction

### `Interaction:createResponse(type, data)`
Sends the response. Used as a main command for `Interaction:ack` and `Interaction:reply`.

### `Interaction:ack(silent)`
Acknowledges the response, allowing to use follow-ups.

`silent` will not show member command call message (`MemberName used /cmdname with Botname`).

### `Interaction:reply(data, silent, private)`
Acknowledges and replies.

`data` is either a table [InteractionApplicationCommandCallbackData](https://discord.com/developers/docs/interactions/slash-commands#interaction-interactionapplicationcommandcallbackdata) or a string with the content. 

`silent` will not show member command call message (`MemberName used /cmdname with Botname`).

`private` will send a reply as ephemeral message (It's visible only for the command caller). Note this feature is not documented and unstable, report bugs to Discord if you find something.

### `Interaction:update(data)`
Updates first reply.

`data` is either a table [InteractionApplicationCommandCallbackData](https://discord.com/developers/docs/interactions/slash-commands#interaction-interactionapplicationcommandcallbackdata) or a string with the content. 

### `Interaction:delete()`
Deletes main reply.

### `Interaction:followUp(data, private)`
Sends a follow-up. You must call `Interaction:createResponse`, `Interaction:ack` or `Interaction:reply` before using this

`data` is either a table [InteractionApplicationCommandCallbackData](https://discord.com/developers/docs/interactions/slash-commands#interaction-interactionapplicationcommandcallbackdata) or a string with the content. 

`private` will send a reply as ephemeral message (It's visible only for the command caller). Note this feature is not documented and unstable, report bugs to Discord if you find something.

Returns `id` of the follow-up (not a `Message` object).

### `Interaction:updateFollowUp(id, data)`
Updates the follow-up.

`id` is the follow-up id.

`data` is either a table [InteractionApplicationCommandCallbackData](https://discord.com/developers/docs/interactions/slash-commands#interaction-interactionapplicationcommandcallbackdata) or a string with the content.

### `Interaction:deleteFollowUp(id)`
Deletes the follow-up.

`id` is the follow-up id.

### `Interaction.guild`
Returns `Guild` object where the command was used.

Note: this field is valid only if your bot is in this guild.

### `Interaction.channel`
Returns `GuildTextChannel` object where the command was used.

Note: this field is valid only if your bot is in this guild.

### `Interaction.member`
Returns `Member` object where the command was used.

Note: this field is valid only if your bot is in this guild.

### Constructor

Constructor is not present by default, you must load it first.
```lua
slash.constructor()
```
This adds new field into `slash`: `new`

### `slash.new(name, description)`

Returns new command template.

`name` is the command name. Must be between 3 and 32 in length.

`description` is the command description. Must be between 1 and 100 in length.

### CommandTemplate

### `CommandTemplate:option(name, description, type, required)`
Adds new option.

Return `CommandTemplateOption`.

`name` is the option name. Must be between 3 and 32 in length.

`description` is the option description. Must be between 1 and 100 in length.

`type` is the option type. See [slash.enums.optionType](#optiontype)

`required` sets the option be required. Can't be set on subcommands and subcommands groups.

### `CommandTemplate:finish()`
Prepares table for `Client:slashCommand` and `Guild:slashCommand`.

Returns a table acceptable for registering the command.

### `CommandTemplate:suboption(name, description)`
Shortcut for `CommandTemplate:option(name, description, slash.enums.optionType.subCommand, required)`.

### `CommandTemplate:group(name, description)`
Shortcut for `CommandTemplate:option(name, description, slash.enums.optionType.subCommandGroup, required)`.

### `CommandTemplate:callback(cb)`
Sets command callback.

Callback parameters:
- `Interaction`, information about the command call.
- `Params`, table of parameters, use option names to get them.
- `ApplicationCommand`, the invoked command, can be used to determine if the command is global or guild-exclusive. 

### `CommandTemplate:onFail(cb)`
Sets command on-fail callback.

Callback has the same parameters as `callback`.

###  CommandTemplateOption

###  `CommandTemplateOption:option(name, description, type, required)`
Same as `CommandTemplate:option(name, description, type, required)`.

###  `CommandTemplateOption:suboption(name, description)`
Same as `CommandTemplate:suboption(name, description)`

###  `CommandTemplateOption:group(name, description)`
Same as `CommandTemplate:group(name, description)`

###  `CommandTemplateOption:required(no)`
Sets if the option is required.

Can't be set on subcommands and subcommands groups.

###  `CommandTemplateOption:default(no)`
Sets if the option is default. Requires to set `required` to `true`.

Can't be set on subcommands and subcommands groups.

[Doesn't work yet](https://github.com/discord/discord-api-docs/issues/2393)

###  `CommandTemplateOption:choices(...)`
Adds choices for the option. Can be set only on string and integer option types.
Is option type is string, accepts string, if integer: integers.

If value is given makes a choice with the same name and value. Example: argument `100` will add `{name = "100", value = 100}` 

If table is given just inserts it.

###  `CommandTemplateOption:finish()`
Same as `CommandTemplate:finish()`, however used internally by parent.

## Enums
Accessible from `slash.enums`.

### optionType
| Field | Value |
|--|--|
| subCommand | 1 |
| subCommandGroup | 2 |
| string | 3 |
| integer | 4 |
| boolean | 5 |
| user | 6 |
| channel | 7 |
| role | 8 |

### interactionType
| Field | Value |
|--|--|
| ping (not used by the library) | 1 |
| applicationCommand | 2 |

### interactionResponseType
| Field | Value |
|--|--|
| pong | 1 |
| acknowledge | 2 |
| channelMessage | 3 |
| channelMessageWithSource | 4 |
| acknowledgeWithSource | 5 |

## Examples

Ban function:
```lua
local dis = require("discordia")
local slash = require("discordia-slash")
slash.constructor()
local CLIENT = dis.Client()
CLIENT:useSlashCommands()

CLIENT:on("slashCommandsReady", function()
	local g = CLIENT:getGuild("guildid")
	local _cmd = slash.new("ban", "Test ban function")
	local optionType = slash.enums.optionType

	do
		local user = _cmd:suboption("user", "Ban using mention")
		user:option("member", "Member to ban", optionType.user, true)
		user:option("reason", "Reason of a ban", optionType.string, true)

		user:option("bulkDelete", "Delete messages?", optionType.integer):choices({
			name = "Don't delete any",
			value = -1
		}, {
			name = "Last 24 hours",
			value = 100
		}, {
			name = "Last 7 days (default)",
			value = 3
		})
	end

	do
		local id = _cmd:suboption("uid", "Ban using id")
		id:option("userid", "UserID to ban", optionType.string, true)
		id:option("reason", "Reason of a ban", optionType.string, true)

		id:option("bulkdelete", "Delete messages?", optionType.integer):choices({
			name = "Don't delete any",
			value = 1
		}, {
			name = "Last 24 hours",
			value = 2
		}, {
			name = "Last 7 days (default)",
			value = 3
		})
	end

	_cmd:callback(function(ia, params, cmd)
		if params.user then
			params = params.user
			ia:reply("Banned " .. params.member.name .. " with reason: " .. params.reason)
		elseif params.uid then
			params = params.uid
			ia:reply("Banned " .. params.userid .. " with reason: " .. params.reason)
		end
	end)

	g:slashCommand(_cmd:finish())
end)

CLIENT:run("Bot " .. io.open("login_dev.txt"):read())
```