local QBCore = exports['qb-core']:GetCoreObject()
local available = true

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
	Wait(10000)
end

RegisterServerEvent('qb-truckrobbery:server:setMissionState', function(bool)
	available = bool
	if available then return end
	Wait(Config.Times.cooldown * 1000)
	available = true
end)

QBCore.Functions.CreateCallback('qb-truckrobbery:cb:getMissionState', function(_, cb)
	cb(available)
end)
