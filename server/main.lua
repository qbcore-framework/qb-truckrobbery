local QBCore = exports['qb-core']:GetCoreObject()
local ActivePolice = 2  		--<< needed policemen to activate the mission
local cashA = 250 				--<<how much minimum you can get from a robbery
local cashB = 450				--<< how much maximum you can get from a robbery
local ActivationCost = 500		--<< how much is the activation of the mission (clean from the bank)
local ResetTimer = 2700 * 1000  --<< timer every how many missions you can do, default is 600 seconds
local ActiveMission = 0

RegisterServerEvent('AttackTransport:akceptujto', function()
	local copsOnDuty = 0
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	local accountMoney = xPlayer.PlayerData.money["bank"]
	if ActiveMission == 0 then
		if accountMoney < ActivationCost then
		TriggerClientEvent('QBCore:Notify', _source, "You need $"..ActivationCost.." in the bank to accept the mission")
		else
			for _, v in pairs(QBCore.Functions.GetPlayers()) do
				local Player = QBCore.Functions.GetPlayer(v)
				if Player ~= nil then
					if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
						copsOnDuty = copsOnDuty + 1
					end
				end
			end
			if copsOnDuty >= ActivePolice then
				TriggerClientEvent("AttackTransport:Pozwolwykonac", _source)
				xPlayer.Functions.RemoveMoney('bank', ActivationCost, "armored-truck")

				OdpalTimer()
			else
				TriggerClientEvent('QBCore:Notify', _source, 'Need at least '..ActivePolice.. ' SASP to activate the mission.')
			end
		end
	else
		TriggerClientEvent('QBCore:Notify', _source, 'Someone is already carrying out this mission')
	end
end)

RegisterServerEvent('qb-armoredtruckheist:server:callCops', function(streetLabel, coords)
    TriggerClientEvent("qb-armoredtruckheist:client:robberyCall", -1, streetLabel, coords)
end)

function OdpalTimer()
	ActiveMission = 1
	Wait(ResetTimer)
	ActiveMission = 0
	TriggerClientEvent('AttackTransport:CleanUp', -1)
end

RegisterServerEvent('AttackTransport:zawiadompsy', function(x ,y, z)
    TriggerClientEvent('AttackTransport:InfoForLspd', -1, x, y, z)
end)

RegisterServerEvent('AttackTransport:graczZrobilnapad', function()
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	local bags = math.random(1,3)
	local info = {
		worth = math.random(cashA, cashB)
	}
	xPlayer.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items['markedbills'], "add")

	local chance = math.random(1, 100)
	TriggerClientEvent('QBCore:Notify', _source, 'You took '..bags..' bags of cash from the van')

	if chance >= 95 then
		xPlayer.Functions.AddItem('security_card_01', 1)
		TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items['security_card_01'], "add")
	end
	Wait(2500)
end)
