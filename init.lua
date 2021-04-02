require("./Application")

local ret = {
	enums = require("./enums")
}

ret.constructor = function()
	ret.new, ret.permission = unpack(require("./constructor"))
end

return ret