local API = {} -- API:request is defined in init.lua
local f = string.format

-- endpoints are never patched into Discordia
-- therefor not defining them in their own file, although the actual requests are
local endpoints = {
  APPLICATION_COMMAND                       = "/applications/%s/commands/%s",
  APPLICATION_COMMANDS                      = "/applications/%s/commands",
  APPLICATION_GUILD_COMMAND                 = "/applications/%s/guilds/%s/commands/%s",
  APPLICATION_GUILD_COMMANDS                = "/applications/%s/guilds/%s/commands",
  APPLICATION_GUILD_COMMANDS_PERMISSIONS    = "/applications/%s/guilds/%s/commands/permissions",
  APPLICATION_GUILD_COMMAND_PERMISSIONS     = "/applications/%s/guilds/%s/commands/%s/permissions"
}

function API:getGlobalApplicationCommands(application_id)
  local endpoint = f(endpoints.APPLICATION_COMMANDS, application_id)

  return self:request("GET", endpoint)
end

function API:createGlobalApplicationCommand(application_id, payload)
  local endpoint = f(endpoints.APPLICATION_COMMANDS, application_id)

  return self:request("POST", endpoint, payload)
end

function API:getGlobalApplicationCommand(application_id, command_id)
  local endpoint = f(endpoints.APPLICATION_COMMAND, application_id, command_id)

  return self:request("GET", endpoint)
end

function API:editGlobalApplicationCommand(application_id, command_id, payload)
  local endpoint = f(endpoints.APPLICATION_COMMAND, application_id, command_id)

  return self:request("PATCH", endpoint, payload)
end

function API:deleteGlobalApplicationCommand(application_id, command_id)
  local endpoint = f(endpoints.APPLICATION_COMMAND, application_id, command_id)

  return self:request("DELETE", endpoint)
end

function API:bulkOverwriteGlobalApplicationCommands(application_id, payload)
  local endpoint = f(endpoints.APPLICATION_COMMANDS, application_id)

  return self:request("PUT", endpoint, payload)
end

function API:getGuildApplicationCommands(application_id, guild_id)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMANDS, application_id, guild_id)

  return self:request("GET", endpoint)
end

function API:createGuildApplicationCommand(application_id, guild_id, payload)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMANDS, application_id, guild_id)

  return self:request("POST", endpoint, payload)
end

function API:getGuildApplicationCommand(application_id, guild_id, command_id)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMAND, application_id, guild_id, command_id)

  return self:request("GET", endpoint)
end

function API:editGuildApplicationCommand(application_id, guild_id, command_id, payload)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMAND, application_id, guild_id, command_id)

  return self:request("PATCH", endpoint, payload)
end

function API:deleteGuildApplicationCommand(application_id, guild_id, command_id)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMAND, application_id, guild_id, command_id)

  return self:request("DELETE", endpoint)
end

function API:bulkOverwriteGuildApplicationCommands(application_id, guild_id, payload)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMANDS, application_id, guild_id)

  return self:request("PUT", endpoint, payload)
end

function API:getGuildApplicationCommandPermissions(application_id, guild_id)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMANDS_PERMISSIONS, application_id, guild_id)

  return self:request("GET", endpoint)
end

function API:getApplicationCommandPermissions(application_id, guild_id, command_id)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMAND_PERMISSIONS, application_id, guild_id, command_id)

  return self:request("GET", endpoint)
end

function API:editApplicationCommandPermissions(application_id, guild_id, command_id, payload)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMAND_PERMISSIONS, application_id, guild_id, command_id)

  return self:request("PUT", endpoint, payload)
end

function API:batchEditApplicationCommandPermissions(application_id, guild_id, payload)
  local endpoint = f(endpoints.APPLICATION_GUILD_COMMANDS_PERMISSIONS, application_id, guild_id)

  return self:request("PUT", endpoint, payload)
end

return API