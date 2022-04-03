local QBCore = exports['qb-core']:GetCoreObject()
local ActiveMission = 0

RegisterNetEvent('truckrobbbery:AcceptMission')
AddEventHandler('truckrobbbery:AcceptMission', function()
	local copsOnDuty = 0
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	local accountMoney = 0
	accountMoney = xPlayer.PlayerData.money["bank"]
	if ActiveMission == 0 then
		if accountMoney < Config.ActivationCost then
			TriggerClientEvent('QBCore:Notify', _source, Lang:t('mission.Activation_cost', {ActivationCost = Config.ActivationCost}))
		else
			for k, v in pairs(QBCore.Functions.GetPlayers()) do
				local Player = QBCore.Functions.GetPlayer(v)
				if Player ~= nil then
					if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
						copsOnDuty = copsOnDuty + 1
					end
				end
			end
			if copsOnDuty >= Config.ActivePolice then
				TriggerClientEvent("truckrobbbery:StartMission", _source)
				xPlayer.Functions.RemoveMoney('bank', Config.ActivationCost, "armored-truck")
				HitTimer()
			else
				TriggerClientEvent('QBCore:Notify', _source, Lang:t('error.ActivePolice', {ActivePolice = Config.ActivePolice}))
			end
		end
	else
		TriggerClientEvent('QBCore:Notify', _source, Lang:t('error.alreadyactive'))
	end
end)

RegisterNetEvent('truckrobbbery:server:callCops')
AddEventHandler('truckrobbbery:server:callCops', function(streetLabel, coords)
    local place = Lang:t('info.Call_place')
    local msg = Lang:t('info.Call_msg', {place = place, streetLabel = streetLabel})

    TriggerClientEvent("truckrobbbery:client:robberyCall", -1, streetLabel, coords)
end)

--[[
AddEventHandler('truckrobbbery:server:callCops', function(streetLabel, coords)
   local data = {displayCode = '10-90', description = 'Braquage de Transport de Fond!', isImportant = 0, recipientList = {'police'}, length = '10000', infoM = 'fa-info-circle', info = 'Transport de Fond'}
local dispatchData = {dispatchData = data, caller = 'Passant', coords = vector3(coords.x, coords.y, coords.z)}
TriggerEvent('wf-alerts:svNotify', dispatchData)
end)
]]

function HitTimer()
	ActiveMission = 1
	Wait(Config.ResetTimer)
	ActiveMission = 0
	TriggerClientEvent('truckrobbbery:CleanUp', -1)
end

RegisterNetEvent('truckrobbbery:GiveInfoPolice')
AddEventHandler('truckrobbbery:GiveInfoPolice', function(x ,y, z)
    TriggerClientEvent('truckrobbbery:InfoForPolice', -1, x, y, z)
end)

RegisterNetEvent('truckrobbbery:RobberySucess')
AddEventHandler('truckrobbbery:RobberySucess', function(moneyCalc)
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	local bags = math.random(Config.BagsA, Config.BagsB)
	local info = {
		worth = math.random(Config.cashA, Config.cashB)
	}
	xPlayer.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items['markedbills'], "add")

	local chance = math.random(1, 100)
	TriggerClientEvent('QBCore:Notify', _source, Lang:t('success.Took_bags', {bags = bags}))

	if chance >= 95 then
		xPlayer.Functions.AddItem('security_card_01', 1)
		TriggerClientEvent('inventory:client:ItemBox', _source, QBCore.Shared.Items['security_card_01'], "add")
	end
	Wait(2500)
end)
