Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.ActivePolice = 5 -- needed police to activate the mission

--Position to Activate the Mission
Config.MissionMarker =  vector3(960.71197509766, -215.51979064941, 76.2552947998) -- Marker to start the Mission
Config.dealerCoords =  vector3(960.78, -216.25, 76.25) -- place where the NPC stands

-- coordinates of the truck's spawn (picked randomly)
Config.VehicleSpawns = {
    [1] = vector4(-1215.97, -355.4, 36.9, 208.6),
    [2] = vector4(-2036.59, -259.78, 23.39, 136.92),
    [3] = vector4(-1292.28, -807.36, 17.19, 308.12),
    [4] = vector4(1072.27, -1950.67, 30.62, 144.03),
    [5] = vector4(1001.3, -55.03, 74.57, 117.98),
    [6] = vector4(-4.7, -669.71, 32.34, 176.32),
}
Config.MaxSpawns = 6 -- Value of the last number in the Config.VehicleSpawns table
Config.RouteColor = 6 -- Color of the Route (http://www.kronzky.info/fivemwiki/index.php/SetBlipColour)

--Models
Config.DriverWep = "WEAPON_COMBATPISTOL" -- Weapon of the driver
Config.NavWep = "WEAPON_COMBATPISTOL" -- Weapon of the passenger
Config.TruckModel = 'Stockade' -- Model of the truck
Config.Dealer = "s_m_y_dealer_01" -- Model of the NPC that gives the Mission
Config.Guard = "s_m_m_security_01" -- Model of the Guard

--Timers
Config.ResetTimer = 600 * 1000 -- Time to complete the mission, default 600 seconds
Config.TimeToBlow = 30 * 1000 -- bomb detonation time after planting, default 30 seconds

--Reward / Cost for the mission
Config.cashA = 2000 --how much minimum you can get from a bag
Config.cashB = 4500 -- how much maximum you can get from a bag
Config.BagsA = 1 --Minimum bags you can get from a robbery
Config.BagsB = 3 -- maximum bags you can get from a robbery

Config.ActivationCost = 500 -- how much is the activation of the mission (clean from the bank)
