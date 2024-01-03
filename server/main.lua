local QBCore = exports['qb-core']:GetCoreObject()
local activeJob, startPed, startPedNetId, truck, truckNetId, exploded, Reward
local guards = {}


function StartPed()
	startPed = CreatePed(4, Config.StartPed.model, Config.StartPed.coords.x, Config.StartPed.coords.y, Config.StartPed.coords.z, Config.StartPed.coords.w, false, true)
	startPedNetId = NetworkGetNetworkIdFromEntity(startPed)
end

function SpawnTruck()
	if DoesEntityExist(truck) then return end
	local plate = 'ARMD' .. math.random(1000, 9999)
	local typeofveh = QBCore.Shared.Vehicles[Config.Truck.model].type
	local locOfVeh = Config.Truck.spawnlocations[math.random(1, #Config.Truck.spawnlocation)]
	truck = CreateVehicleServerSetter(GetHashKey(Config.Truck.model), typeofveh, locOfVeh.x, locOfVeh.y, locOfVeh.z, locOfVeh.a)
	Wait(100)
	truckNetId = NetworkGetNetworkIdFromEntity(truck)
	SetVehicleNumberPlateText(truck, plate)
	return truckNetId
end

function SpawnGuards()
	for i = 1, Config.Guards.number < 5 and Config.Guards.number or 4 do
		while not truck do
			Wait(10)
		end

		local spawnGuard = CreatePedInsideVehicle(truck, 4, Config.Guards.model, i - 2, true, true) -- Change seat val to i - 2
		while not DoesEntityExist(spawnGuard) do Wait(100) end
		Wait(100)
		guards[i] = {
			id = spawnGuard,
			netId = NetworkGetNetworkIdFromEntity(spawnGuard),
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
	DeleteAllEntities(true)
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

function DeleteStartPed()
	if DoesEntityExist(startPed) then DeleteEntity(startPed) end
end

function DeleteGuards()
	if #guards == 0 then return end
	for i = 1, #guards do
		if DoesEntityExist(guards[i].id) then DeleteEntity(guards[i].id) end
	end
end

function DeleteTruck()
	if not truck then return end
	if DoesEntityExist(truck) then DeleteEntity(truck) end
	truck = nil
end

function DeleteAllEntities(keepStartPed)
	if not keepStartPed then DeleteStartPed() end
	DeleteGuards()
	DeleteTruck()
end

QBCore.Functions.CreateCallback('qb-truckrobbery:server:StartMission', function(_, cb)
	if activeJob then return cb(activeJob) end
	local truck, guards = StartMission()
	cb(false, truck, guards)
end)

QBCore.Functions.CreateCallback('qb-truckrobbery:server:GetPed', function(_, cb)
	cb(startPedNetId)
end)

RegisterNetEvent('qb-truckrobbery:server:StartMission', StartMission)
RegisterNetEvent('qb-truckrobbery:server:FinishJob', function()
	IssueRewards(source)
end)

RegisterNetEvent('onResourceStop', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	DeleteAllEntities(false)
end)

RegisterNetEvent('onResourceStart', function(resoucename)
	if GetCurrentResourceName() ~= resoucename then return end
	StartPed()
end)
