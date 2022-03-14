# discordia-slash
**[Discordia](https://github.com/SinisterRectus/Discordia) 2.0 extension for [slash commands](https://discord.com/developers/docs/interactions/slash-commands).**

---

__[<img src="https://raw.githubusercontent.com/GitSparTV/GitSparTV/681727efe146af9a4f3042c121072d0e60bd3e95/saythanks.svg" width="300">](https://gitspartv.github.io/GitSparTV/saythanks.html)__

---

## WIP docs

Dependency: https://github.com/Bilal2453/discordia-interactions

Ask me in Discord: Spar#6665 or [here](https://discord.gg/sinisterware)


**This lib is working only with guild commands**


```lua
local dia = require("discordia")
local dcmd = require("discordia-commands")
-- required to initialize:
local CLIENT = dia.Client():useApplicationCommands()

-- for slash commands
-- ia - interaction from discordia-interactions
-- cmd - basically ia.data
-- args - parsed options
CLIENT:on("slashCommand", function(ia, cmd, args)

end)

-- for message commands
-- msg - Message object
CLIENT:on("messageCommand", function(ia, cmd, msg)

end)

-- for user commands
-- msg - Member object
CLIENT:on("userCommand", function(ia, cmd, member)

end)

-- for autocompletion
-- focused_option - option where focused = true

-- cmd.focused returns value directly
CLIENT:on("slashCommandAutocomplete", function(ia, cmd, focused_option, args)

end)
```

### Utils
Useful constructors and tools. Get by `discordia_slash.util`.

#### tools

##### `string = tools.getSubCommand(cmd)`
Returns called subcommand as string path.
For example slash command `action` has 2 subcommand groups `do` and `undo`. Each one has `ban` and `mute` subcommands.
When user calls `action -> do -> ban` this function returns `do.ban`. This is useful for multilevel commands to lookup the callback faster, instead of doing bunch of if's

##### `tools.userError(ia, err)`
Replies to the user with error message. Ephemeral.

Example:
**Interaction Error**
Error message

##### `tools.devError(ia, err, trace)`
Replies to the user with error message and traceback. Ephemeral.

Example:
**Interaction Error**
Error message
```lua
debug traceback:
	blah
		blah
```

##### `tools.argError(ia, arg, comment)`
Replies to the user with error message about the invalid argument. Ephemeral.

Example:
**Invalid argument `arg1`**

The arg is wrong

##### `tools.serializeApplicationCommand(cmd)`
Returns: `command_name` [CommandType] (command_id)

CommandType is either `Slash Command`, `User Command` or `Message Command`

##### `tools.tryReply(ia, content, ephemeral)`
Try to call `ia:reply`. If failed print error message

##### `tools.choice(name, value)`
Constructor for option choice.
Creates `{name = name, value = value}`

##### `tools.userPermission(user_id, allow_type)`
Constructor for user permission.

##### `tools.rolePermission(role_id, allow_type)`
Constructor for role permission.

##### `tools.permission(object, allow_type)`
Constructor for object permission. Object is either Role or Member class.

#### `CommandConstructor = CommandConstructor:setName(name)`
Sets name

Returns self

#### `CommandConstructor = CommandConstructor:setDescription(description)`
Sets description

Returns self

#### `CommandConstructor = CommandConstructor:addOption(option)`
Adds option.

Returns self

#### `CommandConstructor = CommandConstructor:setOptions(options)`
Replaces options with `options`

Returns self

#### `CommandConstructor = CommandConstructor:setType(type)`
Sets application command type

Returns self

#### `CommandConstructor = CommandConstructor:setDefaultPermission(default_permission)`
Sets default permission for the use. (Can @everyone use it?)

Returns self

##### `CommandConstructor = tools.applicationCommand()`
Empty application command constructor

##### `CommandConstructor = tools.slashCommand(name, description)`
Slash command constructor

##### `CommandConstructor = tools.userCommand(name)`
User command constructor

##### `CommandConstructor = tools.messageCommand(name)`
Message command constructor

#### `OptionConstructor = OptionConstructor:setName(name)`
Sets name

Returns self

#### `OptionConstructor = OptionConstructor:setDescription(description)`
Sets description

Returns self

#### `OptionConstructor = OptionConstructor:setType(type)`
Sets option type

Returns self

#### `OptionConstructor = OptionConstructor:addOption(option)`
Adds option.

Returns self

#### `OptionConstructor = OptionConstructor:setOptions(options)`
Replaces options with `options`

Returns self

#### `OptionConstructor = OptionConstructor:setRequired(required)`
Set required flag on the option

Returns self

#### `OptionConstructor = OptionConstructor:addChoice(choice)`
Adds choice to the option

Returns self

#### `OptionConstructor = OptionConstructor:setChoices(choices)`
Replaces choices with `choices`

Returns self

#### `OptionConstructor = OptionConstructor:addChannelType(channel_type)`
Adds channel type to `channel_types` filter

Returns self

#### `OptionConstructor = OptionConstructor:setChannelTypes(channel_types)`
Replace channel_types with `channel_types`

Returns self

#### `OptionConstructor = OptionConstructor:setMinValue(min_value)`
Sets minimum value for the option

Returns self

#### `OptionConstructor = OptionConstructor:setMaxValue(max_value)`
Sets maximum value for the option

Returns self

#### `OptionConstructor = OptionConstructor:setAutocomplete(autocomplete)`
Sets autocomplete flag on the option

Returns self

##### `tools.option()`
Empty option constructor

##### `tools.subCommand(name, description)`
Subcommand option constructor

##### `tools.subCommandGroup(name, description)`
Subcommand group option constructor

##### `tools.string(name, description)`
String option constructor

##### `tools.integer(name, description)`
Integer option constructor

##### `tools.boolean(name, description)`
Boolean option constructor

##### `tools.user(name, description)`
User option constructor

##### `tools.channel(name, description)`
Channel option constructor

##### `tools.role(name, description)`
Role option constructor

##### `tools.mentionable(name, description)`
Mentionable option constructor

##### `tools.number(name, description)`
Number option constructor

##### `tools.attachment(name, description)`
Attachment option constructor

#### appcmd
ALlows you to add and edit commands without code.

To add appcmd to your guild call before `CLIENT:on("ready")`:
```lua
dcmd.util.appcmd(CLIENT, "ID of your guild")
```

This will add appcmd command, only the owner of the bot can use it by default.


*Utility to edit application commands from discord*

Allowed for everyone: **disallowed**

│

├─ `create` (Subcommand) – *Create new command*

│     ├─ `name` (String) – *Command name* [required]

│     ├─ `description` (String) – *Command desciption (will be ignored for non slash commands types)* [required]

│     ├─ `type` (Integer) – *Command type (Slash command by default)* [choices:3]

│     └─ `default_permission` (Boolean) – *Command default permission (true by default)*

├─ `delete` (Subcommand) – *Delete command*

│     └─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

├─ `get` (Subcommand) – *Get all commands or information about specific command*

│     └─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

├─ `code` (Subcommand) – *Get command code*

│     └─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

├─ `edit` (Subcommand) – *Edit first-level fields*

│     ├─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

│     ├─ `name` (String) – *Command name*

│     ├─ `description` (String) – *Command description (slash commands only)*

│     └─ `default_permission` (Boolean) – *Command default permission (true by default)*

├─ `permissions` (Subcommand Group) – *Edit command permissions*

│     ├─ `get` (Subcommand) – *See permissions of all commands or specific one*

│     │     └─ `id` (String) – *ApplicationCommand ID* [autocomplete]

│     └─ `set` (Subcommand) – *Set permission for a command*

│           ├─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

│           ├─ `what` (Mentionable) – *What should have different permission* [required]

│           └─ `value` (Integer) – *Value to set* [required, choices:3]

└─ `option` (Subcommand Group) – *Option related category*

      ├─ `create` (Subcommand) – *Create option*

      │     ├─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

      │     ├─ `type` (Integer) – *Option type* [required, choices:11]

      │     ├─ `name` (String) – *Option name* [required]

      │     ├─ `description` (String) – *Option description* [required]

      │     ├─ `where` (String) – *Place to insert (example: option.create) (root level by default)*

      │     ├─ `required` (Boolean) – *Is option required? (false by default)*

      │     ├─ `min_value` (Number) – *Minimum value for the option (Only for integer and number types)*

      │     ├─ `max_value` (Number) – *Maximum value for the option (Only for integer and number types)*

      │     ├─ `autocomplete` (Boolean) – *Autocompletion feature (only for string, integer and number types, false by default)*

      │     ├─ `channel_types` (Integer) – *Channel types allowed to pick (Only for channel type)* [choices:8]

      │     └─ `replace` (Boolean) – *Replace existing option*

      ├─ `edit` (Subcommand) – *Edit option*

      │     ├─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

      │     ├─ `what` (String) – *Option name* [required]

      │     ├─ `where` (String) – *Place to insert (example: option.create) (root level by default)*

      │     ├─ `type` (Integer) – *Option type* [choices:11]

      │     ├─ `name` (String) – *Option name*

      │     ├─ `description` (String) – *Option description*

      │     ├─ `required` (Boolean) – *Is option required? (false by default)*

      │     ├─ `min_value` (Number) – *Minimum value for the option (Only for integer and number types)*

      │     ├─ `max_value` (Number) – *Maximum value for the option (Only for integer and number types)*

      │     ├─ `autocomplete` (Boolean) – *Autocompletion feature (only for string, integer and number types, false by default)*

      │     └─ `channel_types` (String) – *Channel types allowed to pick separated by space (Only for channel type)*

      ├─ `delete` (Subcommand) – *Delete option*

      │     ├─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

      │     ├─ `what` (String) – *Option name* [required]

      │     └─ `where` (String) – *Place where the option is (example: option.create) (root level by default)*

      ├─ `move` (Subcommand) – *Move option*

      │     ├─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

      │     ├─ `what` (String) – *Option name* [required]

      │     ├─ `place` (Integer) – *Order* [required, min_value:1]

      │     └─ `where` (String) – *Place where the option is (example: option.create) (root level by default)*

      └─ `choice` (Subcommand) – *Add choice to option*

            ├─ `id` (String) – *ApplicationCommand ID* [required, autocomplete]

            ├─ `what` (String) – *Option name* [required]

            ├─ `choice_name` (String) – *Choice visible name* [required]

            ├─ `choice_value` (String) – *Choice value* [required]

            └─ `where` (String) – *Place where the option is (example: option.create) (root level by default)*

#### test


### Exposed Client functions
```lua
Client:getGuildApplicationCommands(guild_id)
Client:createGuildApplicationCommand(guild_id, id, payload)
Client:getGuildApplicationCommand(guild_id, id)
Client:editGuildApplicationCommand(guild_id, id, payload)
Client:deleteGuildApplicationCommand(guild_id, id)
Client:getGuildApplicationCommandPermissions(guild_id)
Client:getApplicationCommandPermissions(guild_id, id)
Client:editApplicationCommandPermissions(guild_id, id, payload)
Client:useApplicationCommands()
```

### Client.\_api bindings

```lua
API:getGlobalApplicationCommands(application_id)
API:createGlobalApplicationCommand(application_id, payload)
API:getGlobalApplicationCommand(application_id, command_id)
API:editGlobalApplicationCommand(application_id, command_id, payload)
API:deleteGlobalApplicationCommand(application_id, command_id)
API:bulkOverwriteGlobalApplicationCommands(application_id, payload)
API:getGuildApplicationCommands(application_id, guild_id)
API:createGuildApplicationCommand(application_id, guild_id, payload)
API:getGuildApplicationCommand(application_id, guild_id, command_id)
API:editGuildApplicationCommand(application_id, guild_id, command_id, payload)
API:deleteGuildApplicationCommand(application_id, guild_id, command_id)
API:bulkOverwriteGuildApplicationCommands(application_id, guild_id, payload)
API:getGuildApplicationCommandPermissions(application_id, guild_id)
API:getApplicationCommandPermissions(application_id, guild_id, command_id)
API:editApplicationCommandPermissions(application_id, guild_id, command_id, payload)
API:batchEditApplicationCommandPermissions(application_id, guild_id, payload)
```