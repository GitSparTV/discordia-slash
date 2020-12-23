require("./Application")

local ret = {
	enums = require("./enums")
}

ret.constructor = function()
	ret.new = require("./constructor")
end

return ret