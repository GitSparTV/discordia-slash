local discordia = require("discordia")
local endpoints = require('./endpoints')
local f = string.format
local Snowflake_m = discordia.class.classes.Snowflake
local AC, ACgetters = discordia.class('ApplicationCommand', Snowflake_m)

local function recursiveOptionsMap(t)
	local map = {}

	for _, v in ipairs(t) do
		local name = string.lower(v.name)
		v.name = name
		map[name] = v

		if v.options then
			v.mapoptions = recursiveOptionsMap(v.options)
		end
	end

	return map
end

function AC:__init(data, parent)
	self._id = data.id
	self._parent = parent
	self._name = data.name
	self._description = data.description
	self._default_permission = data.default_permission
	self._version = data.version
	self._callback = data.callback
	self._guild = parent._id and parent

	if not self._options then
		self._options = data.options or {}
	end
end

function AC:publish()
	if self._id then return self:edit() end
	local g = self._guild

	if not g then
		local res, err = self.client._api:request('POST', f(endpoints.COMMANDS, self.client._slashid), {
			name = self._name,
			description = self._description,
			options = self._options,
			default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			self._id = res.id

			return self
		end
	else
		local res, err = self.client._api:request('POST', f(endpoints.COMMANDS_GUILD, self.client._slashid, g._id), {
			name = self._name,
			description = self._description,
			options = self._options,
			default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			self._id = res.id

			return true
		end
	end
end

function AC:edit()
	local g = self._guild

	if not g then
		local res, err = self.client._api:request('PATCH', f(endpoints.COMMANDS_MODIFY, self.client._slashid, self._id), {
			name = self._name,
			description = self._description,
			options = self._options,
			default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			return true
		end
	else
		local res, err = self.client._api:request('PATCH', f(endpoints.COMMANDS_MODIFY_GUILD, self.client._slashid, g._id, self._id), {
			name = self._name,
			description = self._description,
			options = self._options,
			default_permission = self._default_permission
		})

		if not res then
			return nil, err
		else
			return true
		end
	end
end

function AC:setName(name)
	self._name = name
end

function AC:setDescription(description)
	self._description = description
end

function AC:setOptions(options)
	self._options = options
end

function AC:setCallback(callback)
	self._callback = callback
end

function AC:delete()
	local g = self._guild

	if not g then
		self.client._api:request('DELETE', f(endpoints.COMMANDS_MODIFY, self.client._slashid, self._id))
		self.client._globalCommands:_delete(self._id)
	else
		self.client._api:request('DELETE', f(endpoints.COMMANDS_MODIFY_GUILD, self.client._slashid, g._id, self._id))
		g._slashCommands:_delete(self._id)
	end
end

function AC:getPermissions(g)
	g = self._guild or g

	if not g then
		error("Guild is required")
	end

	local stat, err = self.client._api:request('GET', f(endpoints.COMMAND_PERMISSIONS_MODIFY, self.client._slashid, g._id, self._id))

	if stat then
		return stat.permissions
	else
		return stat, err
	end
end

function AC:addPermission(perm, g)
	g = self._guild or g

	if not g then
		error("Guild is required")
	end

	if not self._permissions then
		self._permissions = self:getPermissions(g) or {}
	end

	for k, v in ipairs(self._permissions) do
		if v.id == perm.id and v.type == perm.type then
			if v.permission == perm.permission then return end
			self._permissions[k] = perm
			goto found
		end
	end

	do
		self._permissions[#self._permissions + 1] = perm
	end

	::found::
	p(self._permissions)

	return self.client._api:request('PUT', f(endpoints.COMMAND_PERMISSIONS_MODIFY, self.client._slashid, g._id, self._id), {
		permissions = self._permissions
	})
end

local function recursiveCompare(a, b, checked)
	checked = checked or {}
	if checked[a] or checked[b] then return true end
	local inner_checked = {}

	for k, v in pairs(a) do
		if type(v) == "table" and type(b[k]) == "table" then
			if not recursiveCompare(v, b[k], checked) then return false end
		elseif v ~= b[k] then
			print("k: ", k, "a[k]:", v, "b[k]: ", b[k])

			return false
		else
			inner_checked[k] = true
		end
	end

	for k, v in pairs(b) do
		if inner_checked[k] then
			goto skip
		end

		if type(v) == "table" and type(a[k]) == "table" then
			if not recursiveCompare(v, a[k], checked) then return false end
		elseif v ~= a[k] then
			print("k: ", k, "a[k]:", a[k], "b[k]: ", v)

			return false
		end

		::skip::
	end

	checked[a], checked[b] = true, true

	return true
end

function AC:_compare(cmd)
	if self._name ~= cmd._name or self._description ~= cmd._description or self._default_permission ~= cmd._default_permission then return false end
	if not self._options and cmd._options then return false end
	if not recursiveCompare(self._options, cmd._options) then return false end

	return true
end

function AC:_merge(cmd)
	self._name = cmd._name
	self._description = cmd._description
	self._options = cmd._options
	self._callback = cmd._callback
	self._default_permission = cmd._default_permission
	self:edit()
end

function ACgetters:name()
	return self._name
end

function ACgetters:description()
	return self._description
end

function ACgetters:options()
	return self._options
end

function ACgetters:guild()
	return self._guild
end

function ACgetters:callback()
	return self._callback
end

function ACgetters:version()
	return self._version
end

return AC