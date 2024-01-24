local QBCore = exports['qb-core']:GetCoreObject()
local activeJob, truck, truckNetId, Reward
local guards = {}
local exploded = false

function SpawnTruck()
	if DoesEntityExist(truck) then return end
	local plate = 'ARMD' .. math.random(1000, 9999)
	local typeOfVeh = QBCore.Shared.Vehicles[Config.Truck.model].type
	local locOfVeh = Config.Truck.spawnlocations[math.random(1, #Config.Truck.spawnlocations)]
	truck = CreateVehicleServerSetter(GetHashKey(Config.Truck.model), typeOfVeh, locOfVeh.x, locOfVeh.y, locOfVeh.z, 0.0)
	Wait(100)
	truckNetId = NetworkGetNetworkIdFromEntity(truck)
	SetVehicleNumberPlateText(truck, plate)
	return truckNetId
end

function SpawnGuards()
	while not DoesEntityExist(truck) do
		Wait(10)
	end
	for i = 1, Config.Guards.number <= 4 and Config.Guards.number or 4 do
		local truckLoc = GetEntityCoords(truck)
		local spawnedPed = CreatePed(4, Config.Guards.model, truckLoc.x + 2, truckLoc.y, truckLoc.z, 0.0, false, true)
		while not DoesEntityExist(spawnedPed) do
			Wait(0)
		end
		while GetEntityHealth(spawnedPed) == 0 do
			Wait(0)
		end
		ClearPedTasksImmediately(spawnedPed)
		ClearPedSecondaryTask(spawnedPed)
		while GetPedInVehicleSeat(truck, i - 2) ~= spawnedPed do
			TaskWarpPedIntoVehicle(spawnedPed, truck, i - 2)
			Wait(10)
		end
		guards[i] = {
			id = spawnedPed,
			netId = NetworkGetNetworkIdFromEntity(spawnedPed),
			seat = i - 2,
		}
	end
	return guards
end

function StartMission()
	activeJob = true
	truck, guards = SpawnTruck(), SpawnGuards()
	return truck, guards
end

function FinishMission()
	activeJob = false
	DeleteAllEntities()
end

function IssueRewards(source)
	local Player = QBCore.Functions.GetPlayer(source)
	Reward = Config.Rewards
	assert(Reward, 'Please check the config file for the rewards table')
	Player.Functions.AddMoney('cash', Reward.cash)
	for k, v in pairs(Reward.items) do
		if Player.Functions.AddItem(k, v) then
			TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[k], 'add')
		end
	end
	Wait(Config.Times.IssuedRewardsTimer * 1000)
	FinishMission()
end

function DeleteGuards()
	if #guards == 0 then return end
	for i = 1, #guards do
		if DoesEntityExist(guards[i].id) then DeleteEntity(guards[i].id) end
	end
end

function DeleteTruck()
	if not truck then return end
	truck = NetworkGetEntityFromNetworkId(truckNetId)
	if DoesEntityExist(truck) then DeleteEntity(truck) end
	truck = nil
end

function ResetMission()
	DeleteAllEntities()
	activeJob = false
end

function DeleteAllEntities()
	DeleteGuards()
	DeleteTruck()
end

QBCore.Functions.CreateCallback('qb-truckrobbery:server:StartMission', function(_, cb)
	if activeJob then return cb(activeJob) end
	local truck, guards = StartMission()
	cb(false, truck, guards)
end)

QBCore.Functions.CreateCallback('qb-truckrobbery:server:GetGuards', function(_, cb)
	if not activeJob then return cb(activeJob) end
	cb(guards)
end)

QBCore.Functions.CreateCallback('qb-truckrobbery:server:FinishMission', function(_, cb)
	if not activeJob then return cb(activeJob) end
	FinishMission()
	cb(true)
end)

RegisterNetEvent('qb-truckrobbery:server:ResetMission', ResetMission)
RegisterNetEvent('qb-truckrobbery:server:StartMission', StartMission)
RegisterNetEvent('qb-truckrobbery:server:FinishJob', function()
	IssueRewards(source)
end)

RegisterNetEvent('onResourceStop', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	DeleteAllEntities()
end)
