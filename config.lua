Config = Config or {}

Config.StartItem = 'thermite' --Item needed to start the job

Config.ActivePolice = 0       -- needed policemen to activate the mission

Config.StartPed = {
	model = `MP_M_SecuroGuard_01`,
	coords = vector4(3.01, -713.24, 31.48, 339.02),
}

Config.Truck = {
	bone = { 'door_pside_r', 'door_dside_r' },
	model = 'stockade',
	spawnlocations = {
		-- vector4(0.15, -706.79, 32.34, 0.0),
		vector3(-1327.48, -86.05, 49.31),
		-- vector4(-2075.888183593, -233.73908996580, 21.10, 0.0),
		-- vector4(-972.1781616210, -1530.9045410150, 4.890, 0.0),
		-- vector4(799.74, -1774.35, 29.33, 0.0)
	}
}

Config.Route = { -- Locations the truck should go to and stop at.
	vector3(151.17, -1027.81, 29.28),
	vector3(317.31, -266.13, 53.85),
	vector3(-344.33, -30.7, 47.42),
	vector3(-1219.89, -317.63, 37.56)
}

Config.Guards = {
	number = 4,
	model = 'mp_s_m_armoured_01',
	weapon = 'weapon_smg',
}

Config.TruckStatus = 'guarded' -- guarded, unguarded, planted, exploded, looted

Config.Times = {               -- Times in seconds.
	plant = 5,                 --Will loop animation if too high
	fuse = 5,
	loot = 10,
	cooldown = 1800,
	issuedRewardsTimer = 30,
	notify = 30,
	driveWait = 10
}

Config.Rewards = {
	cash  = math.random(1000, 2000),
	items = { --Quantity of items
		['phone'] = math.random(1, 3),
	}
}
