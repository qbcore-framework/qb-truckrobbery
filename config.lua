Config = {}

Config.ActivePolice = 2  --<< needed police to activate the mission

--Position to Activate the Mission
Config.MissionMarker =  vector3(960.71197509766, -215.51979064941, 76.2552947998)   --<< Marker to start the Mission
Config.dealerCoords =  vector3(960.78, -216.25, 76.25)  							--<< place where the NPC stands

--<< coordinates of the truck's spawn (picked randomly)
Config.VehicleSpawn1 = vector3(-1327.479736328, -86.045326232910, 49.31)
Config.VehicleSpawn2 = vector3(-2075.888183593, -233.73908996580, 21.10)
Config.VehicleSpawn3 = vector3(-972.1781616210, -1530.9045410150, 4.890)
Config.VehicleSpawn4 = vector3(798.18426513672, -1799.8173828125, 29.33)
Config.VehicleSpawn5 = vector3(1247.0718994141, -344.65634155273, 69.08)

--Models
Config.DriverWep = "WEAPON_COMBATPISTOL"    --<< Weapon of the driver
Config.NavWep = "WEAPON_COMBATPISTOL"       --<< Weapon of the passenger
Config.TruckModel = 'Stockade'              --<< Model of the truck
Config.Dealer = "s_m_y_dealer_01"           --<< Model of the NPC that gives the Mission
Config.Guard = "s_m_m_security_01"          --<< Model of the Guard

--Timers
Config.ResetTimer = 600 * 1000      --<< Timer between missions, default 600 seconds
Config.TimeToBlow = 30 * 1000        --<< bomb detonation time after planting, default 30 seconds

--Reward / Cost for the mission
Config.cashA = 2000 	--<<how much minimum you can get from a bag
Config.cashB = 4500     --<< how much maximum you can get from a bag
Config.BagsA = 1        --<<Minimum bags you can get from a robbery
Config.BagsB = 3        --<< maximum bags you can get from a robbery

Config.ActivationCost = 500	 --<< how much is the activation of the mission (clean from the bank)
