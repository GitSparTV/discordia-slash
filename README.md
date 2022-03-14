# discordia-slash
**[Discordia](https://github.com/SinisterRectus/Discordia) 2.0 extension for [slash commands](https://discord.com/developers/docs/interactions/slash-commands).**

---

__[<img src="https://raw.githubusercontent.com/GitSparTV/GitSparTV/681727efe146af9a4f3042c121072d0e60bd3e95/saythanks.svg" width="300">](https://gitspartv.github.io/GitSparTV/saythanks.html)__

---

## WIP docs

Dependency: https://github.com/Bilal2453/discordia-interactions

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

Exposed Client functions:
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

Client.\_api bindings

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