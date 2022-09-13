Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'false'

Config.ActivePolice = 2

--<< position to activate the mission

Config.MissionMarker =  vector3(960.71197509766, -215.51979064941, 76.2552947998)       --<< marker to start the mission
Config.dealerCoords =  vector4(960.78, -216.25, 75.25, 268.9422)  						--<< place where the NPC stands

--<< coordinates of the truck's spawn (picked randomly)

Config.SpawnLocations = {
    vector3(-1327.479736328, -86.045326232910, 49.31),
    vector3(-2075.888183593, -233.73908996580, 21.10),
    vector3(-972.1781616210, -1530.9045410150, 4.890),
    vector3(798.18426513672, -1799.8173828125, 29.33),
    vector3(1247.0718994141, -344.65634155273, 69.08)
}

-- Models

Config.DriverWep = "WEAPON_COMBATPISTOL"    --<< weapon of the driver
Config.NavWep = "WEAPON_COMBATPISTOL"       --<< weapon of the passenger
Config.TruckModel = 'Stockade'              --<< model of the truck
Config.Dealer = "s_m_y_dealer_01"           --<< model of the NPC that gives the mission
Config.Guard = "s_m_m_security_01"          --<< model of the Guard

-- Timers

Config.ResetTimer = 10          --<< timer between missions, default 600 minutes
Config.TimeToBlow = 30          --<< bomb detonation time after planting, default 30 seconds

-- Rewards

Config.CashMin = 2000           --<< how much minimum you can get from a bag
Config.CashMax = 4500           --<< how much maximum you can get from a bag
Config.BagsMin = 1              --<< minimum bags you can get from a robbery
Config.BagsMax = 3              --<< maximum bags you can get from a robbery

Config.ActivationCost = 500     --<< how much is the activation of the mission (clean from the bank)
