QBCore = exports['qb-core']:GetCoreObject()
local driver, Spawn, TruckBlip
startPed = nil
local truck
local guards = {}
local exploded = false

-- Animations
function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function PlantAnim()
	local ped = PlayerPedId()
	local anim = {
		animDict = 'anim@heists@ornate_bank@thermal_charge_heels',
		anim = 'thermal_charge',
	}
	prop = CreateObject(joaat('prop_c4_final_green'), GetEntityCoords(ped) + vector3(0, 0, 0.2), true, true, true)
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 60309), 0.06, 0.0, 0.06, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
	SetCurrentPedWeapon(ped, joaat('WEAPON_UNARMED'), true)
	FreezeEntityPosition(ped, true)
	-- TaskPlayAnim(ped, 'anim@heists@ornate_bank@thermal_charge_heels', 'thermal_charge', 3.0, -8, -1, 63, 0, 0, 0, 0 )
	QBCore.Functions.Progressbar(anim, Lang:t('progress.planting'), Config.Times.plant * 1000, false, function()
		ClearPedTasks(ped)
		DetachEntity(prop, false, false)
		AttachEntityToEntity(prop, truck, GetEntityBoneIndexByName(truck, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
		FreezeEntityPosition(ped, false)
	end)
end

function LootAnim()
	local ped = PlayerPedId()
	local pedCoords = GetEntityCoords((ped))
	local anim = {
		animDict = 'anim@heists@ornate_bank@grab_cash_heels',
		anim = 'grab',
	}

	local bagObj = CreateObject(joaat('prop_cs_heist_bag_02'), pedCoords.x, pedCoords.y, pedCoords.z, true, true, true)
	AttachEntityToEntity(bagObj, ped, GetPedBoneIndex(ped, 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	QBCore.Functions.Progressbar(anim, Lang:t('progress.looting'), Config.Times.loot * 1000, function()
		ClearPedTasks(ped)
		DeleteEntity(bagObj)
		SetPedComponentVariation(ped, 5, 45, 0, 2)
		TriggerServerEvent('qb-truckrobbery:server:FinishJob')
	end)
end

-- Plant and Loot
function PlantBomb()
	TaskTurnPedToFaceEntity(PlayerPedId(), truck, 1000)
	Wait(1000)
	PlantAnim()
	if Config.Times.fuse then
		Wait(Config.Times.fuse * 1000)
		ExplodeTruck()
		Wait(1000)
	end
end

function LootTruck()
	print('LootTruck')
end

-- Blip
function Blip(bool)
	local transG = 250
	TruckBlip = AddBlipForCoord(Spawn.x, Spawn.y, Spawn.z)
	if bool then
		TruckBlip = AddBlipForEntity(truck)
	end
	SetBlipSprite(TruckBlip, 487)
	SetBlipColour(TruckBlip, 4)
	SetBlipDisplay(TruckBlip, 4)
	SetBlipAlpha(TruckBlip, transG)
	SetBlipScale(TruckBlip, 1.2)
	SetBlipFlashes(TruckBlip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('10-90: Armored Truck Robbery')
	EndTextCommandSetBlipName(TruckBlip)
	CreateThread(function()
		while transG ~= 0 do
			Wait(180 * 4)
			transG = transG - 1
			SetBlipAlpha(TruckBlip, transG)
			if transG == 0 then
				SetBlipSprite(TruckBlip, 2)
				RemoveBlip(TruckBlip)
				return
			end
		end
	end)
end

function TruckTarget(truck)
	for _, v in pairs(Config.Truck.bone) do
		exports['qb-target']:AddTargetBone(v, {
			options = {
				{
					action = PlantBomb,
					label = Lang:t('info.plantbomb'),
					canInteract = function()
						return not exploded
					end
				},
			},
			distance = 2
		})
	end
	exports['qb-target']:AddTargetEntity(truck, {
		options = {
			{
				action = LootTruck,
				label = Lang:t('info.loottruck'),
				canInteract = function()
					return exploded
				end,
			}
		},
		distance = 2
	})
end

function SpawnStartPed()
	QBCore.Functions.TriggerCallback('qb-truckrobbery:server:GetPed', function(retPed)
		startPed = NetworkGetEntityFromNetworkId(retPed)
		SetBlockingOfNonTemporaryEvents(startPed, true)
		FreezeEntityPosition(startPed, true)
		SetEntityInvincible(startPed, true)
		exports['qb-target']:AddTargetEntity(startPed, {
			options = {
				{
					icon = 'fas fa-truck-loading',
					label = 'Start Job',
					item = Config.StartItem,
					action = StartMission,
				},
			},
			distance = 2.5
		})
	end)
end

function SpawnTruck()
	QBCore.Functions.SpawnVehicle(Config.Truck.model, function(netID)
		truck = netID
		local plate = 'ARMD' .. math.random(1000, 9999)
		SetVehicleNumberPlateText(truck, plate)
		SetVehicleEngineOn(truck, true, true, false)
		exports['LegacyFuel']:SetFuel(truck, 100)
		SetVehicleDoorsLocked(truck, 2)
		TruckTarget(truck)
	end, Spawn, true, false)
end

function SpawnGuards()

end

-- Eject Guards
function EjectFrontGuards()
	-- Eject Front Guards within 50m of truck
end

function EjectRearGuards()
	-- Eject Rear Guards after explosion
end

-- Explode
function ExplodeTruck()
	local offset = GetOffsetFromEntityInWorldCoords(truck, 0.0, -4.0, 0.0)

	for i = 2, 3 do
		SetVehicleDoorOpen(truck, i, true, false)
		Wait(50)
		SetVehicleDoorBroken(truck, i, true)
	end
	DeleteEntity(prop)
	AddExplosion(offset.x, offset.y, offset.z, 31, 2.0, true, false, 2.0)
	AddExplosion(offset.x, offset.y, offset.z + 2.0, 31, 2.0, true, false, 2.0)
end

-- Police
function AlertPolice()
	Wait(Config.Times.notify * 1000)
	TriggerServerEvent('police:server:policeAlert', Lang:t('info.palert'))
end

-- Starts
function StartScript()
	SpawnStartPed()
end

function StartMission()
	Spawn = Config.Truck.spawnlocations[math.random(1, #Config.Truck.spawnlocations)]

	-- Kody's Way
	-- local ped = PlayerPedId()
	-- Blip()
	-- local close = false
	-- while not close do
	-- 	close = #(GetEntityCoords(ped) - vector3(Spawn.x, Spawn.y, Spawn.z)) <= 50
	-- 	Wait(100)
	-- 	print(#(GetEntityCoords(ped) - vector3(Spawn.x, Spawn.y, Spawn.z)))
	-- end
	-- SpawnTruck()
	-- SpawnGuards()

	-- if DoesEntityExist(truck) then
	-- 	RemoveBlip(TruckBlip)
	-- 	Blip(true)
	-- end

	-- if Config.ActivePolice then
	-- 	AlertPolice()
	-- end

	-- My Way
	QBCore.Functions.TriggerCallback('qb-truckrobbery:server:StartMission', function(activeJob, retTruck, retguards)
		if activeJob then return QBCore.Functions.Notify(Lang:t('error.active_mission'), 'error') end

		truck = NetworkGetEntityFromNetworkId(retTruck)
		guards = retguards
		driver = NetworkGetEntityFromNetworkId(guards[1].netId)
		Spawn = QBCore.Functions.GetCoords(truck)

		QBCore.Functions.Notify(Lang:t('success.start_mission'), 'success')
		while not DoesEntityExist(driver) or not DoesEntityExist(truck) do
			print(DoesEntityExist(driver), DoesEntityExist(truck))
			Wait(0)
		end

		SetVehicleEngineOn(truck, true, true, false)
		exports['LegacyFuel']:SetFuel(truck, 100)
		SetVehicleDoorsLocked(truck, 2)
		TruckTarget(truck)
		Blip()

		if DoesEntityExist(truck) then
			RemoveBlip(TruckBlip)
			Blip(true)
		end

		if Config.ActivePolice then
			AlertPolice()
		end
	end)
end

-- Cleanup
function Cleanup()
	if not startPed then
		exports['qb-target']:RemoveTargetEntity(startPed)
	end
	exports['qb-target']:RemoveTargetEntity(truck)
	for _, v in pairs(Config.Truck.bone) do
		if v then
			exports['qb-target']:RemoveTargetBone(v)
		end
	end
end

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	StartScript()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	Cleanup()
end)

RegisterNetEvent('onResourceStart', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	StartScript()
end)

RegisterNetEvent('onResourceStop', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	Cleanup()
end)
