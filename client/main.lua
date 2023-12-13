QBCore = exports['qb-core']:GetCoreObject()
local StartPed, Truck, activeJob
local Guards = {}
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
	QBCore.Functions.Progressbar(anim, Lang:t('progress.planting'), Config.Times.plant * 1000, function()
		ClearPedTasks(ped)
		DetachEntity(prop, false, false)
		AttachEntityToEntity(prop, Truck, GetEntityBoneIndexByName(Truck, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
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
	print('PlantBomb')
end

function LootTruck()
	print('LootTruck')
end

-- Blip
function Blip()
	local blip = AddBlipForCoord(GetEntityCoords(Truck))
	SetBlipSprite(blip, 67)
	SetBlipColour(blip, 50)
	SetBlipScale(blip, 1.0)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(Lang:t('info.robbery'))
	EndTextCommandSetBlipName(blip)
end

CreateThread(function()
	while true do
		Wait(1000)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)
		local dist = #(plyCoords - vector3(Config.StartPed.coords.x, Config.StartPed.coords.y, Config.StartPed.coords.z))
		if dist <= 15 then
			SpawnStartPed()
		else
			if StartPed then
				DeletePed(StartPed)
				StartPed = nil
			end
		end
	end
end)

function SpawnStartPed()
	if StartPed then return end
	RequestModel(Config.StartPed.model)
	while not HasModelLoaded(Config.StartPed.model) do
		Wait(10)
	end
	StartPed = CreatePed(26, Config.StartPed.model, Config.StartPed.coords.x, Config.StartPed.coords.y, Config.StartPed.coords.z, Config.StartPed.coords.w, false, false)
	SetEntityHeading(StartPed, Config.StartPed.coords.w)
	SetBlockingOfNonTemporaryEvents(StartPed, true)
	FreezeEntityPosition(StartPed, true)
	SetEntityInvincible(StartPed, true)

	exports['qb-target']:AddTargetEntity(StartPed, {
		options = {
			{
				icon = 'fas fa-truck-loading',
				label = Lang:t('info.startjob'),
				item = Config.StartItem,
				action = StartMission,
			},
		},
		distance = 2
	})
end

function SpawnTruck()
	RequestModel(Config.Truck.model)
	while not HasModelLoaded(Config.Truck.model) do
		Wait(10)
	end

	local spawn = Config.Truck.spawnlocations[math.random(1, #Config.Truck.spawnlocations)]
	Truck = CreateVehicle(Config.Truck.model, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
	SetVehicleOnGroundProperly(Truck)
	SetVehicleNumberPlateText(Truck, 'ARMD' .. math.random(100, 999))
	SetVehicleEngineOn(Truck, true, true, false)
	SetVehicleFuelLevel(Truck, 100)
	activeJob = true
end

function SpawnGuards()
	for i = 1, Config.Guards.number < 5 and Config.Guards.number or 4 do
		local spawnGuard = CreatePedInsideVehicle(Truck, 1, Config.Guards.model, i - 2, true, true) -- Change seat val to i - 2
		while not DoesEntityExist(spawnGuard) do Wait(10) end
		Wait(100)
		Guards[i] = {
			ped = spawnGuard,
			seat = i - 2
		}
	end
	return Guards
end

-- Eject Guards
function EjectFrontGuards()
	-- Eject Front Guards if within 50m
	SetRelationshipGroups()
end

function EjectRearGuards()
	-- Eject Rear Guards after explosion
	SetRelationshipGroups()
end

-- Guards Drive Around
function GuardsDriveAround()
	for _, v in pairs(Config.Route) do
		local TruckCoords = GetEntityCoords(Truck)
		local distance = #(TruckCoords - vector3(v.x, v.y, v.z))
		if distance <= 5 then
			FreezeEntityPosition(Truck, true)
			Wait(Config.Times.driveWait * 1000)
			TaskVehicleDriveToCoordLongrange(Guard, Truck, v.x, v.y, v.z, 60, 537397183, 5)
		end
	end
end

function SetRelationshipGroups()
	SetPedRelationshipGroupDefaultHash(Guard, joaat('COP'))
	SetPedRelationshipGroupHash(Guard, joaat('COP'))
	SetPedAsCop(Guard, true)
	SetCanAttackFriendly(Guard, false, true)
	TaskCombatPed(Guard, PlayerPedId(), 0, 16)
end

-- Target
function TruckTarget()
	if not exploded then
		for _, v in pairs(Config.Truck.bone) do
			exports['qb-target']:AddTargetBone(v, {
				options = {
					{
						action = function()
							PlantBomb()
						end,
						label = Lang:t('info.plantbomb'),
						canInteract = function()
							if exploded then return false end
							return true
						end
					},
				},
				distance = 2
			})
		end
	else
		exports['qb-target']:AddTargetEntity(Truck, {
			options = {
				{
					action = function()
						LootTruck()
					end,
					label = Lang:t('info.loottruck'),
					canInteract = function()
						if not exploded then return false end
						return true
					end,
				}
			},
			distance = 2
		})
	end
end

-- Explode
function ExplodeTruck()
	local offset = GetOffsetFromEntityInWorldCoords(Truck, 0.0, -4.0, 0.0)

	for i = 2, 3 do
		SetVehicleDoorOpen(Truck, i, true, false)
		Wait(50)
		SetVehicleDoorBroken(Truck, i, true)
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
	if activeJob then
		return QBCore.Functions.Notify(Lang:t('error.active_job'), 'error', 7500)
	end
	SpawnTruck()
	SpawnGuards()

	if DoesEntityExist(Truck) then
		TruckTarget()
		Blip()
	end

	if Config.ActivePolice > 0 then
		AlertPolice()
	end
end

-- Cleanup
function Cleanup()
	DeleteEntity(StartPed)
	DeleteEntity(Truck)
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
