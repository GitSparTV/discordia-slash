local enum = require('discordia').enums.enum

return {
	optionType = enum({
		subCommand = 1,
		subCommandGroup = 2,
		string = 3,
		integer = 4,
		boolean = 5,
		user = 6,
		channel = 7,
		role = 8
	}),
	interactionType = enum({
		ping = 1,
		applicationCommand = 2
	}),
	interactionResponseType = enum({
		pong = 1,
		channelMessageWithSource = 4,
		deferredChannelMessageWithSource = 5
	}),
	applicationCommandPermissionType = enum({
		role = 1,
		user = 2,
	})
}