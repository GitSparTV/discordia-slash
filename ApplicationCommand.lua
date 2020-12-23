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
	self._callback = data.callback
	self._guild = parent._id and parent

	if not self._options then
		self._options = data.options or {}
	end

	self._mapoptions = recursiveOptionsMap(self._options)
end

local ignoredkeys = {
	_mapoptions = true,
	_mapchoices = true,
	mapoptions = true,
	mapchoices = true
}

-- local function cleanOptions(options)
-- 	local new = {}

-- 	for k, v in pairs(options) do
-- 		if k == "options" then
-- 			new[k] = cleanOptions(v)
-- 		elseif not ignoredkeys[k] then
-- 			if type(v) == "table" then
-- 				new[k] = cleanOptions(v)
-- 			else
-- 				new[k] = v
-- 			end
-- 		end
-- 	end

-- 	return new
-- end

function AC:publish()
	if self._id then return self:edit() end
	local g = self._guild

	if not g then
		local res, err = self.client._api:request('POST', f(endpoints.COMMANDS, self.client._slashid), {
			name = self._name,
			description = self._description,
			options = self._options
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
			options = self._options
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
			options = self._options
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
			options = self._options
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
	self._mapoptions = recursiveOptionsMap(options)
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

local function recursiveCompare(a, b, checked)
	checked = checked or {}
	if checked[a] or checked[b] then return true end

	for k, v in pairs(a) do
		if ignoredkeys[k] then
			goto skip
		end

		if type(v) == "table" and type(b[k]) == "table" then
			if not recursiveCompare(v, b[k], checked) then return false end
		elseif v ~= b[k] then
			print("k: ", k, "a[k]:", v, "b[k]: ", b[k])

			return false
		end

		::skip::
	end

	for k, v in pairs(b) do
		if k == ignoredkeys[k] then
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

local uv = require("uv")

function AC:_compare(cmd)
	if self._name ~= cmd._name or self._description ~= cmd._description then return false end
	local uvhrtime = uv.hrtime
	local s = uvhrtime()
	local c = recursiveCompare(self._options, cmd._options)
	local e = uvhrtime()
	print(string.format("Comparison took: %f ms", (e - s) / 1000000))
	if not c then return false end

	return true
end

function AC:_merge(cmd)
	self._name = cmd._name
	self._description = cmd._description
	self._options = cmd._options
	self._mapoptions = cmd._mapoptions or recursiveOptionsMap(cmd._options)
	self._callback = cmd._callback
	self:edit()
end

function ACgetters.name(self)
	return self._name
end

function ACgetters.description(self)
	return self._description
end

function ACgetters.options(self)
	return self._options
end

function ACgetters.guild(self)
	return self._guild
end

function ACgetters.callback(self)
	return self._callback
end

return AC