local discordia = require('discordia')
local enums = discordia.enums
local enum = enums.enum

local ApplicationCommandOptionType = enum({
	subCommand = 1,
	subCommandGroup = 2,
	string = 3,
	integer = 4,
	boolean = 5,
	user = 6,
	channel = 7,
	role = 8
})

local InteractionType = enum({
	ping = 1,
	applicationCommand = 2
})

local InteractionResponseType = enum({
	pong = 1,
	acknowledge = 2,
	channelMessage = 3,
	channelMessageWithSource = 4,
	acknowledgeWithSource = 5
})

return {
	optionType = ApplicationCommandOptionType,
	interactionType = InteractionType,
	interactionResponseType = InteractionResponseType
}