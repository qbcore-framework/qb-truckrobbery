Config = Config or {}

Config.StartItem = 'thermite' --Item needed to start the job

Config.LootBag = 45           --Slot # of the bag

Config.ActivePolice = 0       -- needed policemen to activate the mission

Config.StartPed = {
	model = `MP_M_SecuroGuard_01`,
	coords = vector4(3.01, -713.24, 31.48, 339.02),
}

Config.Truck = {
	bone = { 'door_pside_r', 'door_dside_r' },
	model = 'stockade',
	spawnlocations = {
		vector3(-1327.48, -86.05, 49.31),
		vector3(-2075.89, -233.74, 21.10),
		vector3(-972.18, -1530.90, 4.89),
		vector3(799.74, -1774.35, 29.33)
	}
}

Config.Guards = {
	number = 4,
	model = 'mp_s_m_armoured_01',
	weapon = 'weapon_smg',
	health = 100,
	armor = 100,
	accuracy = 60
}

Config.Times = { -- Times in seconds.
	plant = 5,
	fuse = 5,
	loot = 10,
	cooldown = 1800,
	issuedRewardsTimer = 30
}

Config.Rewards = {
	cash  = math.random(1000, 2000),
	items = { --Quantity of items
		['markedbills'] = math.random(1, 5)
	}
}
