local QBCore = exports['qb-core']:GetCoreObject()
local ActiveMission = 0

RegisterNetEvent('truckrobbery:AcceptMission')
AddEventHandler('truckrobbery:AcceptMission', function()
	local copsOnDuty = 0
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local accountMoney =  Player.PlayerData.money["bank"]
	if ActiveMission == 0 then
		if accountMoney < Config.ActivationCost then
			TriggerClientEvent('QBCore:Notify', src, Lang:t('mission.activation_cost', {ActivationCost = Config.ActivationCost}))
		else
			for _, v in pairs(QBCore.Functions.GetPlayers()) do
				local _Player = QBCore.Functions.GetPlayer(v)
				if _Player ~= nil then
					if Player.PlayerData.job.name == "police" then
						if Player.PlayerData.job.onduty then
							copsOnDuty = copsOnDuty + 1
						end
					end
				end
			end
			if copsOnDuty >= Config.ActivePolice then
				TriggerClientEvent("truckrobbery:StartMission", src)
				Player.Functions.RemoveMoney('bank', Config.ActivationCost, "armored-truck")
				HitTimer(src)
			else
				TriggerClientEvent('QBCore:Notify', src, Lang:t('error.activepolice', {ActivePolice = Config.ActivePolice}))
			end
		end
	else
		TriggerClientEvent('QBCore:Notify', src, Lang:t('error.alreadyactive'))
	end
end)

RegisterNetEvent('truckrobbery:server:callCops')
AddEventHandler('truckrobbery:server:callCops', function(coords)
	local msg = Lang:t("info.alert_desc")
    local alertData = {
        title = Lang:t("info.alerttitle"),
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                TriggerClientEvent("truckrobbery:client:robberyCall", Player.PlayerData.source, msg, coords)
                TriggerClientEvent("qb-phone:client:addPoliceAlert", Player.PlayerData.source, alertData)
            end
        end
    end
end)

function HitTimer()
	ActiveMission = 1
	Wait(Config.ResetTimer)
	ActiveMission = 0
	TriggerClientEvent('truckrobbery:CleanUp', -1)
end

RegisterNetEvent('truckrobbery:RobberySucess')
AddEventHandler('truckrobbery:RobberySucess', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local bags = math.random(Config.BagsA, Config.BagsB)
	local info = {
		worth = math.random(Config.cashA, Config.cashB)
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")

	local chance = math.random(1, 100)
	TriggerClientEvent('QBCore:Notify', src, Lang:t('success.took_bags', {bags = bags}))

	if chance >= 95 then
		Player.Functions.AddItem('security_card_01', 1)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['security_card_01'], "add")
	end
	Wait(2500)
end)
