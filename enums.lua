local enum = require('discordia').enums.enum

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
	channelMessageWithSource = 4,
	DeferredChannelMessageWithSource = 5
})

return {
	optionType = ApplicationCommandOptionType,
	interactionType = InteractionType,
	interactionResponseType = InteractionResponseType
}