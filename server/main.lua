local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("security_card_02", function(source, item)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	TriggerClientEvent("truckrobbery:gruppeCard", src)
end)

RegisterNetEvent('truckrobbery:addItem', function(item, count)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, count)
end)

RegisterNetEvent('truckrobbery:removeItem', function(item, count)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, count) 
end)

local cashA = 250 --<<how much minimum you can get from a robbery
local cashB = 450 --<< how much maximum you can get from a robbery

RegisterNetEvent('truckrobbery:addMoney', function(count)
	local Player = QBCore.Functions.GetPlayer(source)
	local bags = math.random(1,3)
	local info = {
		worth = math.random(cashA, cashB)
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], "add")

	local chance = math.random(1, 100)
	TriggerClientEvent('QBCore:Notify', source, 'You took '..bags..' bags of cash from the van')

	if chance >= 95 then
	Player.Functions.AddItem('security_card_01', 1)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['security_card_01'], "add")
	end
end)
