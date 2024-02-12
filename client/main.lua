QBCore = exports['qb-core']:GetCoreObject()
local driver, StartPed, truck
local guards = {}
local PlayerJob = {}
local copCount = 0
local exploded = false

AddEventHandler('police:SetCopCount', function(amount)
	copCount = amount
end)

-- Animations
function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

function PlantAnim()
	if not IsVehicleStopped(truck) and IsEntityInWater(truck) then return end
	local returnWeapon = false
	local hasWeapon, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
	if hasWeapon and weaponHash ~= `WEAPON_UNARMED` then
		SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
		returnWeapon = true
	end
	QBCore.Functions.Progressbar('Planting', Lang:t('progress.planting'), Config.Times.plant * 1000, false, true,
		{
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		{
			animDict = 'anim@heists@ornate_bank@thermal_charge_heels',
			anim = 'thermal_charge',
			flags = 16,
		},
		{
			model = 'prop_c4_final_green',
			bone = GetEntityBoneIndexByName(PlayerPedId(), 'SKEL_R_Hand'),
			coords = { x = 0.0, y = 0.5, z = 0.5 },
			rotation = { x = 0.0, y = 0.0, z = 0.0 },
		}, {}, function()
			if returnWeapon then
				SetCurrentPedWeapon(PlayerPedId(), weaponHash, true) -- Give back the weapon
			end
			QBCore.Functions.Notify(Lang:t('success.planted'), 'success')
			Wait(Config.Times.plant * 1000)
			local transCoords = GetEntityCoords(truck)
			SetVehicleDoorBroken(truck, 2, false)
			SetVehicleDoorBroken(truck, 3, false)
			AddExplosion(transCoords.x, transCoords.y, transCoords.z, 2, 2.0, true, false, 2.0)
			ApplyForceToEntity(truck, 0, 20.0, 500.0, 0.0, 0.0, 0.0, 0.0, 1, false, true, true, false, true)
			exploded = true
			EjectRearGuards()
		end, function() -- Cancel
			QBCore.Functions.Notify(Lang:t('error.failed_bomb'), 'error')
		end)
end

function LootAnim()
	QBCore.Functions.Progressbar('Looting', Lang:t('progress.looting'), Config.Times.loot * 1000, false, true,
		{
			disableMovement = true,
			disableCarMovement = true,
			disableMouse = false,
			disableCombat = true,
		},
		{
			animDict = 'anim@heists@ornate_bank@grab_cash_heels',
			anim = 'grab',
			flags = 0,
		},
		{
			model = 'prop_cs_heist_bag_02',
			bone = GetEntityBoneIndexByName(PlayerPedId(), 'SKEL_R_Hand'),
			coords = { x = 0.0, y = 0.0, z = -0.3 },
			rotation = { x = 0.0, y = 0.0, z = 0.0 },
		}, {}, function()
			SetPedComponentVariation(PlayerPedId(), 5, Config.LootBag, 0, 2)
			QBCore.Functions.Notify(Lang:t('success.looting'), 'success')
			TriggerServerEvent('qb-truckrobbery:server:FinishMission')
			Wait(Config.Times.cooldown * 1000)
			TriggerServerEvent('qb-truckrobbery:server:FinishMission')
		end, function() -- Cancel
			QBCore.Functions.Notify(Lang:t('error.failed_mission'), 'error')
		end)
end

-- Loot
function LootTruck()
	if not exploded then return end
	TaskTurnPedToFaceEntity(PlayerPedId(), truck, 1000)
	LootAnim()
	Wait(Config.Times.loot * 1000)
end

function TruckTarget(truck)
	for _, v in pairs(Config.Truck.bone) do
		exports['qb-target']:AddTargetBone(v, {
			options = {
				{
					action = PlantAnim,
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
		if dist <= 50 then
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

-- Starts
function StartScript()
	SpawnStartPed()
end

function StartMission()
	QBCore.Functions.Notify(Lang:t('success.start_misssion'), 'success')

	QBCore.Functions.TriggerCallback('qb-truckrobbery:server:StartMission', function(activeJob, retTruck, retguards)
		if activeJob then return QBCore.Functions.Notify(Lang:t('error.active_mission'), 'error') end
		truck = NetworkGetEntityFromNetworkId(retTruck)
		guards = retguards
		driver = NetworkGetEntityFromNetworkId(guards[1].netId)

		while not DoesEntityExist(driver) or not DoesEntityExist(truck) do
			print(DoesEntityExist(driver), DoesEntityExist(truck))
			Wait(0)
		end

		SetVehicleEngineOn(truck, true, true, false)
		exports['LegacyFuel']:SetFuel(truck, 100)
		SetVehicleDoorsLocked(truck, 2)

		if DoesEntityExist(truck) then
			EjectFrontGuards()
			TruckTarget(truck)
		end

		if Config.ActivePolice then
			TriggerServerEvent('police:server:policeAlert', Lang:t('info.palert'))
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
				SetPedMaxHealth(guard, Config.Guards.health)
				SetPedArmour(guard, Config.Guards.armor)
				SetPedAccuracy(guard, Config.Guards.accuracy)
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
				SetPedMaxHealth(guard, Config.Guards.health)
				SetPedArmour(guard, Config.Guards.armor)
				SetPedAccuracy(guard, Config.Guards.accuracy)
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
	QBCore.Functions.GetPlayerData(function(PlayerData)
		PlayerJob = PlayerData.job
	end)
end)

RegisterNetEvent('onResourceStop', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	Cleanup()
end)
