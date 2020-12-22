local optionMeta = {}
optionMeta.__index = optionMeta

function optionMeta:option(name, description, type)
	if not name then
		error("Name is required")
	elseif not description then
		error("Description is required")
	elseif #name < 3 or #name > 32 then
		error("Must be between 3 and 32 in length")
	elseif #description < 1 or #description > 100 then
		error("Must be between 1 and 100 in length")
	elseif type < 1 or type > 8 then
		error("Unknown type")
	end

	local ctnr = self[1]
	local selfType = ctnr.type

	if not self[2] then
		if selfType <= 2 then
			if type <= 2 then
				error("Nesting of sub-commands is unsupported at this time")
			end
		else
			error("Sub-options cannot be configured for this type of option")
		end
	end

	local t = setmetatable({
		parent = self,
		{
			name = name,
			description = description,
			type = type,
		}
	}, optionMeta)

	if type <= 2 then
		t[1].options = {}
	end

	ctnr.options[#ctnr.options + 1] = t

	return t
end

function optionMeta:required(no)
	local ctnr = self[1]
	local type = ctnr.type

	if type <= 2 then
		error("Required cannot be configured for this type of option")
	end

	for _, v in ipairs(self.parent.options) do
		if not v.required then
			error("Required options must be placed before non-required options")
		end

		if v == self then break end
	end

	ctnr.required = not no
end

function optionMeta:default(no)
	local ctnr = self[1]
	local type = ctnr.type

	if type <= 2 then
		error("Default cannot be configured for this type of option")
	end

	if not self[1].required then
		error("Default cannot be configured with required = false")
	end

	for _, v in ipairs(self.parent.options) do
		if v[1].default then
			error("There can be 1 default option within command, sub-command, and sub-command group options")
		end
	end

	ctnr.default = not no
end

function optionMeta:choices(...)
	local ctnr = self[1]
	local opttype = ctnr.type
	local acceptedType

	if opttype == 3 then
		acceptedType = "string"
	elseif opttype == 4 then
		acceptedType = "number"
	else
		error("Choices cannot be configured for this type of option")
	end

	local t = {}
	ctnr.choices = t

	for i = 1, select("#", ...) do
		local v = select(i, ...)

		if type(v) == acceptedType then
			t[i] = {
				name = tostring(v),
				value = v
			}
		else
			t[i] = v
		end
	end
end

function optionMeta:finish()
	local t = {}

	for k, v in pairs(self[1]) do
		t[k] = v
	end

	if t.options then
		local options = {}

		for k, v in ipairs(t.options) do
			options[k] = v:finish()
		end

		t.options = options
	end

	return t
end

local commandMeta = {}
commandMeta.__index = commandMeta
commandMeta.option = optionMeta.option
commandMeta.finish = optionMeta.finish

function commandMeta:callback(cb)
	self[1].callback = cb
end

function commandMeta:onFail(cb)
	self[1].onfail = cb
end

local function new(name, description)
	if not name then
		error("Name is required")
	elseif not description then
		error("Description is required")
	elseif #name < 3 or #name > 32 then
		error("Must be between 3 and 32 in length")
	elseif #description < 1 or #description > 100 then
		error("Must be between 1 and 100 in length")
	end

	return setmetatable({
		{
			name = name,
			description = description,
			options = {}
		},
		true
	}, commandMeta)
end

return new