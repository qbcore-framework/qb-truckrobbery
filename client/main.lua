QBCore = exports['qb-core']:GetCoreObject()
local driver, Spawn, TruckBlip, StartPed, truck
local guards = {}
local PlayerJob = {}
local exploded = false

-- Animations
function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function PlantAnim()
	if not IsVehicleStopped(truck) and IsEntityInWater(truck) then return end
	LoadAnim('anim@heists@ornate_bank@thermal_charge_heels')
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	prop = CreateObject(`prop_c4_final_green`, x, y, z + 0.2, true, true, true)
	AttachEntityToEntity(prop, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), 'SKEL_R_Hand'), 0, 0.5, 0.5, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
	FreezeEntityPosition(PlayerPedId(), true)
	TaskPlayAnim(PlayerPedId(), 'anim@heists@ornate_bank@thermal_charge_heels', 'thermal_charge', 3.0, -8, -1, 16, 0, false, false, false)
	QBCore.Functions.Progressbar('Planting', Lang:t('progress.planting'), Config.Times.plant * 1000, false, true, {}, {}, {}, {}, function()
		DeleteEntity(prop)
		FreezeEntityPosition(PlayerPedId(), false)
		ClearPedTasks(PlayerPedId())
		DetachEntity(prop, true, true)
		AttachEntityToEntity(prop, truck, GetEntityBoneIndexByName(truck, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	end, function()
		ClearPedTasks(PlayerPedId())
		DetachEntity(prop, true, true)
		DeleteObject(prop)
		FreezeEntityPosition(PlayerPedId(), false)
		QBCore.Functions.Notify(Lang:t('error.failed_bomb'), 'error')
	end)
	Wait(Config.Times.fuse * 1000 + 5000)
	local transCoords = GetEntityCoords(truck)
	SetVehicleDoorBroken(truck, 2, false)
	SetVehicleDoorBroken(truck, 3, false)
	AddExplosion(transCoords.x, transCoords.y, transCoords.z, 2, 2.0, true, false, 2.0)
	ApplyForceToEntity(truck, 0, 20.0, 500.0, 0.0, 0.0, 0.0, 0.0, 1, false, true, true, false, true)
	DeleteEntity(prop)
	exploded = true
	QBCore.Functions.Notify(Lang:t('success.planted'), 'success')
	RemoveBlip(TruckBlip)
end

function LootAnim()
	LoadAnim('anim@heists@ornate_bank@grab_cash')
	local ped = PlayerPedId()
	local bagObj = CreateObject(joaat('prop_cs_heist_bag_02'), GetEntityCoords(ped), true, true, true)
	AttachEntityToEntity(bagObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	TaskPlayAnim(PlayerPedId(), 'anim@heists@ornate_bank@grab_cash', 'bag_grab', 0, 0, 0, 0, 0, false, false, false)
	FreezeEntityPosition(PlayerPedId(), true)
	-- Wait(Config.Times.loot * 1000)
	QBCore.Functions.Progressbar('Looting', Lang:t('progress.looting'), Config.Times.loot * 1000, false, true, {}, {}, {}, {}, function()
		DeleteEntity(bagObj)
		FreezeEntityPosition(PlayerPedId(), false)
		SetPedComponentVariation(PlayerPedId(), 5, 45, 0, 2)
		FreezeEntityPosition(PlayerPedId(), false)
		QBCore.Functions.Notify(Lang:t('success.looting'), 'success')
		TriggerServerEvent('qb-truckrobbery:server:FinishJob')
		Wait(10000)
		TriggerServerEvent('qb-truckrobbery:server:ResetMission')
	end, function()
		ClearPedTasks(PlayerPedId())
		DetachEntity(bagObj, true, true)
		DeleteObject(bagObj)
		FreezeEntityPosition(PlayerPedId(), false)
		QBCore.Functions.Notify(Lang:t('error.failed_mission'), 'error')
	end)
end

-- Plant and Loot
function PlantBomb()
	if exploded then return end
	TaskTurnPedToFaceEntity(PlayerPedId(), truck, 1000)
	PlantAnim()
	if not exploded then
		Wait(Config.Times.fuse * 1000)
		ExplodeTruck()
	end
	exploded = true
	EjectRearGuards()
end

function LootTruck()
	if not exploded then return end
	TaskTurnPedToFaceEntity(PlayerPedId(), truck, 1000)
	LootAnim()
	Wait(Config.Times.loot * 1000)
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

CreateThread(function()
	while true do
		Wait(3000)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)
		local dist = #(plyCoords - vector3(Config.StartPed.coords.x, Config.StartPed.coords.y, Config.StartPed.coords.z))
		if dist <= 100 then
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
		Wait(0)
	end
	StartPed = CreatePed(26, Config.StartPed.model, Config.StartPed.coords.x, Config.StartPed.coords.y, Config.StartPed.coords.z, Config.StartPed.coords.w, false, false)
	SetEntityHeading(StartPed, Config.StartPed.coords.w)
	SetBlockingOfNonTemporaryEvents(StartPed, true)
	FreezeEntityPosition(StartPed, true)
	SetEntityInvincible(StartPed, true)
	TaskStartScenarioInPlace(StartPed, 'WORLD_HUMAN_CLIPBOARD_FACILITY', 0, false)

	exports['qb-target']:AddTargetEntity(StartPed, {
		options = {
			{
				icon = 'fas fa-truck-loading',
				label = Lang:t('info.startmission'),
				item = Config.StartItem,
				action = StartMission,
			},
		},
		distance = 2
	})
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
	QBCore.Functions.Notify(Lang:t('success.start_misssion'), 'success')

	QBCore.Functions.TriggerCallback('qb-truckrobbery:server:StartMission', function(activeJob, retTruck, retguards)
		if activeJob then return QBCore.Functions.Notify(Lang:t('error.active_mission'), 'error') end
		truck = NetworkGetEntityFromNetworkId(retTruck)
		guards = retguards
		driver = NetworkGetEntityFromNetworkId(guards[1].netId)
		Spawn = GetEntityCoords(truck)

		while not DoesEntityExist(driver) or not DoesEntityExist(truck) do
			print(DoesEntityExist(driver), DoesEntityExist(truck))
			Wait(0)
		end

		SetVehicleEngineOn(truck, true, true, false)
		exports['LegacyFuel']:SetFuel(truck, 100)
		SetVehicleDoorsLocked(truck, 2)

		if DoesEntityExist(truck) then
			print('Truck exists')
			EjectFrontGuards()
			TruckTarget(truck)
			Blip(true)
		end

		if Config.ActivePolice then
			Wait(Config.Times.notify * 1000)
			AlertPolice()
		end
	end)
end

-- Eject Guards
function EjectFrontGuards()
	local plyCoords = GetEntityCoords(PlayerPedId(), false)
	local dist = #(plyCoords - GetEntityCoords(truck))

	if dist <= 50 then
		for i = -1, 1 do
			local guard = GetPedInVehicleSeat(truck, i - 1)

			if DoesEntityExist(guard) and IsPedInAnyVehicle(guard, false) then
				TaskLeaveVehicle(guard, truck, 0) -- 0 is the flag to make them leave the vehicle without locking it
				SetEntityAsMissionEntity(guard, true, true) -- Mark the ped as a mission entity
				SetPedAsCop(guard, true)
				GiveWeaponToPed(guard, `WEAPON_smg`, 255, false, true)
				TaskCombatPed(guard, PlayerPedId(), 0, 16) -- Make the ped attack the player
			end
			EjectRearGuards()
		end
	end
end

function EjectRearGuards()
	if exploded then
		for i = 2, 3 do
			local guard = GetPedInVehicleSeat(truck, i - 1)

			if IsPedInAnyVehicle(guard, false) then
				TaskLeaveVehicle(guard, truck, 256) -- 0 is the flag to make them leave the vehicle without locking it
				SetEntityAsMissionEntity(guard, true, true) -- Mark the ped as a mission entity
				SetPedAsCop(guard, true)
				GiveWeaponToPed(guard, `WEAPON_smg`, 255, false, true)
				TaskCombatPed(guard, PlayerPedId(), 0, 16) -- Make the ped attack the player
			end
		end
	end
end

-- Cleanup
function Cleanup()
	exports['qb-target']:RemoveTargetEntity(truck)
	for _, v in pairs(Config.Truck.bone) do
		if v then
			exports['qb-target']:RemoveTargetBone(v)
		end
	end
	DeleteEntity(truck)
end

RegisterCommand('TruckMission', function()
	StartMission()
end, false)

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	StartScript()
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
	end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
	PlayerJob = JobInfo
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
