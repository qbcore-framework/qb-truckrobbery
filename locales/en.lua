local Translations = {
	error = {
		['failed_bomb'] = 'You failed to plant the bomb!',
		['failed_doors'] = 'You failed to unlock the doors!',
		['failed_mission'] = 'You have failed, Please Try Again!',
		['active_mission'] = 'There is already an active mission or you are on cooldown!',
	},
	success = {
		['start_misssion'] = 'You have started a Mission!',
		['minigame'] = 'You have passed the minigame!',
		['planted'] = 'You have planted the bomb!',
		['looting'] = 'You have looted the truck!',
		['doors'] = 'You have unlocked the doors!',
		['robbery'] = 'You have robbed the truck!'
	},
	progress = {
		['planting'] = 'Planting Bomb...',
		['looting'] = 'Looting Truck...',
	},
	info = {
		['startmission'] = 'Start Mission',
		['plantbomb'] = 'Plant Bomb',
		['unlockdoors'] = 'Unlock Doors',
		['loottruck'] = 'Loot Truck',
		['robbery'] = 'Armored Truck Robbery',
		['palert'] = 'Armored Truck Robbery in progress!',
		['cooldown'] = 'The truck robbery is on cooldown'
	}
}

Lang = Lang or Locale:new({
	phrases = Translations,
	warnOnMissing = true
})
