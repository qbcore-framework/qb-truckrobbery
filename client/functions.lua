QBCore = exports['qb-core']:GetCoreObject()
startPed = nil
truck = nil
guards = nil
truckStatus = nil
Functions = {}

Functions.isAtRearOfTruck = function()
	return #(GetEntityCoords(PlayerPedId()) - GetOffsetFromEntityInWorldCoords(truck, 0.0, -4.0, 0.0)) < 1.0
end

Functions.updateTruckStatus = function(state)
	TriggerServerEvent('qb-truckrobbery:server:UpdateTruckStatus', state)
end

Functions.loadAnim = function(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Wait(10)
	end
end

Functions.faceTruck = function()
	TaskTurnPedToFaceEntity(PlayerPedId(), truck, 500)
	Wait(500)
end

Functions.setRelationshipGroups = function(guard)
	SetPedRelationshipGroupDefaultHash(guard, joaat('COP'))
	SetPedRelationshipGroupHash(guard, joaat('COP'))
	SetPedAsCop(guard, true)
	SetCanAttackFriendly(guard, false, true)
	TaskCombatPed(guard, PlayerPedId(), 0, 16)
end

Functions.ejectAllGuards = function()
	for _, v in pairs(guards) do
		local guard = NetworkGetEntityFromNetworkId(v.netId)
		if not DoesEntityExist(guard) then return end
		if IsPedInVehicle(guard, truck, false) then
			CreateThread(function()
				SetCurrentPedWeapon(guard, joaat(Config.Guards.weapon), true)
				TaskLeaveVehicle(guard, truck, 0)
				while IsPedInVehicle(guard, truck, false) do Wait(100) end
				Functions.setRelationshipGroups(guard)
			end)
		end
	end
end

Functions.explodeTruck = function()
	local offset = GetOffsetFromEntityInWorldCoords(truck, 0.0, -4.0, 0.0)

	for i = 2, 3 do
		SetVehicleDoorOpen(truck, i, true, false)
		Wait(50)
		SetVehicleDoorBroken(truck, i, true)
	end
	DeleteEntity(prop)
	AddExplosion(offset.x, offset.y, offset.z, 'EXPLOSION_TANKER', 2.0, true, false, 2.0)
	AddExplosion(offset.x, offset.y, offset.z + 2.0, 'EXPLOSION_TANKER', 2.0, true, false, 2.0)
end

Functions.progressAnim = function(anim, label, duration, cb)
	if GetCurrentPedWeapon(PlayerPedId()) ~= joaat('WEAPON_UNARMED') then
		print('wasnt unarmed')
		SetCurrentPedWeapon(PlayerPedId(), joaat('WEAPON_UNARMED'), true)
		Wait(3000)                                                     -- This needs to be better!!!
	end
	QBCore.Functions.Progressbar('name', label, duration, false, false, { -- Name | Label | Time | useWhileDead | canCancel
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, anim, {}, {}, function() -- Play When Done
		cb()
	end)
end

Functions.doPlantAnim = function()
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
	Functions.progressAnim(anim, 'Planting Bomb...', Config.Times.plant * 1000, function()
		ClearPedTasks(ped)
		DetachEntity(prop)
		AttachEntityToEntity(prop, truck, GetEntityBoneIndexByName(truck, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
		FreezeEntityPosition(ped, false)
	end)
end

Functions.doLootAnim = function()
	local ped = PlayerPedId()
	local pedCoords = GetEntityCoords((ped))
	local anim = {
		animDict = 'anim@heists@ornate_bank@grab_cash_heels',
		anim = 'grab',
	}

	local bagObj = CreateObject(joaat('prop_cs_heist_bag_02'), pedCoords.x, pedCoords.y, pedCoords.z, true, true, true)
	AttachEntityToEntity(bagObj, ped, GetPedBoneIndex(ped, 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	Functions.progressAnim(anim, 'Looting...', Config.Times.loot * 1000, function()
		ClearPedTasks(ped)
		DeleteEntity(bagObj)
		SetPedComponentVariation(ped, 5, 45, 0, 2)
		TriggerServerEvent('qb-truckrobbery:server:FinishJob')
	end)
end

Functions.addTargetToTruck = function(truck)
	print(truckStatus)
	for _, v in pairs(truckStatus) do
		if v.bone then
			exports['qb-target']:AddTargetBone(v.bone, {
				options = { v.targetOptions },
				distance = 2.5
			})
		else
			exports['qb-target']:AddTargetEntity(truck, {
				options = { v.targetOptions },
				distance = 2.5
			})
		end
	end
end


Functions.startJob = function()
	QBCore.Functions.TriggerCallback('qb-truckrobbery:server:StartJob', function(activeJob, retTruck, retguards)
		if activeJob then return QBCore.Functions.Notify('There is already an active job', 'error') end
		truck = NetworkGetEntityFromNetworkId(retTruck)
		guards = retguards
		driver = NetworkGetEntityFromNetworkId(guards[1].netId)
		QBCore.Functions.Notify('You have started a job', 'success')
		while not DoesEntityExist(driver) or not DoesEntityExist(truck) do
			print(DoesEntityExist(driver), DoesEntityExist(truck))
			Wait(0)
		end
		-- TaskVehicleDriveWander(driver, truck, 80.0, 786603)
		SetVehicleEngineOn(truck, true, true, false)
		-- SetVehicleDoorsLocked(truck, 2)
		Functions.addTargetToTruck(truck)
	end)
end

Functions.setupPed = function()
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
					-- item = Config.StartItem,
					action = Functions.startJob,
				},
			},
			distance = 2.5
		})
	end)
end

Functions.setUpScript = function()
	Functions.setupPed()
end

Functions.cleanUp = function(keepStartPed)
	if not keepStartPed then
		exports['qb-target']:RemoveTargetEntity(startPed)
	end
	exports['qb-target']:RemoveTargetEntity(truck)
	for k, v in pairs(truckStatus) do
		if v.bone then
			exports['qb-target']:RemoveTargetBone(v.bone, v.label)
		end
	end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	Functions.setUpScript()
end)

RegisterNetEvent('onResourceStart', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	Functions.setUpScript()
end)

RegisterNetEvent('onResourceStop', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	Functions.cleanUp()
end)

RegisterCommand('getstate', function(source, args, rawCommand)
	print(Entity(truck).state.status)
end, false)

RegisterCommand('setstate', function(source, args, rawCommand)
	Functions.updateTruckStatus(args[1] or 'cleared')
end, false)
