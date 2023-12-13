QBCore = exports['qb-core']:GetCoreObject()

Config = Config or {}

Config.StartPed = {
	model = `U_M_M_ProlSec_01`,
	coords = vector4(-2.2, -721.18, 32.3, 115.8),
}

Config.StartItem = 'thermite' --Item needed to start the job

Config.Truck = {
	model = `stockade`,
	spawnlocations = {
		vector4(-9.73, -728.66, 32.27, 162.08),
		vector4(-2033.56, -262.96, 23.39, 104.99),
		vector4(-1307.66, -1312.49, 4.88, 281.93),
		vector4(-577.32, -2327.02, 13.83, 142.27)
	}
}

Config.Guards = {
	number = 6,
	model = `CS_Casey`,
	weapon = 'weapon_smg',
}

Config.PoliceAlert = function(source)
	QBCore.Functions.Notify(source, 'Armored Truck Robbery', error, 5000)
	-- Add blip
end

Config.Minigames = {
	['Unlock Doors'] = function()
		return true
	end,
	['Plant Bomb'] = function()
		return true
	end,
}

Config.Route = { -- Locations the truck should go to and stop at.
	vector3(151.17, -1027.81, 29.28),
	vector3(317.31, -266.13, 53.85),
	vector3(-344.33, -30.7, 47.42),
	vector3(-1219.89, -317.63, 37.56)
}


Config.Times = { -- Times in seconds.
	plant = 5,   --Will loop animation if too high
	fuse = 20,
	loot = 60,
}

Config.Luck = { --Percentage of getting a lucky or extralucky reward
	standard = 100,
	lucky = 25,
	extralucky = 5,
}

Config.Rewards = {
	standard = {
		cash = math.random(1000, 2000),
		items = { --Quantity of items
			['phone'] = math.random(1, 3),
		}
	},
	lucky = {
		cash = math.random(2000, 4000),
		items = {
			['phone'] = math.random(1, 3),
		}
	},
	extralucky = {
		cash = math.random(2000, 4000),
		items = {
			['phone'] = math.random(1, 3),
		}
	},
}
