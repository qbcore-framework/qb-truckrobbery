-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

local gotem = false
local pickingup = false
local attempted = 0
local pickup = false

-- Functions

local function GetTheStreet()
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z, currentStreetHash, intersectStreetHash)
    currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    zone = tostring(GetNameOfZone(x, y, z))
    playerStreetsLocation = Config.zoneNames[tostring(zone)]

    if not zone then
        zone = "UNKNOWN"
        Config.zoneNames['UNKNOWN'] = zone
    elseif not Config.zoneNames[tostring(zone)] then
        local undefinedZone = zone .. " " .. x .. " " .. y .. " " .. z
        Config.zoneNames[tostring(zone)] = "Undefined Zone"
    end

    if intersectStreetName ~= nil and intersectStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. " | " .. intersectStreetName .. " | " .. Config.zoneNames[tostring(zone)]
    elseif currentStreetName ~= nil and currentStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. " | " .. Config.zoneNames[tostring(zone)]
    else
        playerStreetsLocation = Config.zoneNames[tostring(zone)]
    end
end

local function pickUpCash()
    if not pickingup then
        local coords = GetEntityCoords(PlayerPedId())
        pickingup = true
        RequestAnimDict("mini@repair")

        while not HasAnimDictLoaded("mini@repair") do Citizen.Wait(0) end

        while pickingup do
            Citizen.Wait(1)
            local coords2 = GetEntityCoords(PlayerPedId())
            local aDist = GetDistanceBetweenCoords(coords["x"], coords["y"], coords["z"], coords2["x"],  coords2["y"], coords2["z"])
            if aDist > 1.0 or not pickup then pickingup = false end
            if IsEntityPlayingAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 3) then
            else
                TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8, -1, 49, 0, 0, 0, 0)
                FreezeEntityPosition(PlayerPedId(), true)
            end
            Progressbar(11,"Collecting Items")

            local chance = math.random(1, 100)
            if chance >= 50 then
                TriggerServerEvent('truckrobbery:addItem', "security_card_01", 1)
            end

            for i = 1, #Config.Items, 1 do
                Wait(3000)
                TriggerServerEvent('truckrobbery:addItem', Config.Items[i].name, Config.Items[i].count)
            end
            TriggerServerEvent('truckrobbery:addMoney', Config.Money)
            pickingup = false
            FreezeEntityPosition(PlayerPedId(), false)
        end
        ClearPedTasks(PlayerPedId())
    end
end

local function FindEndPointCar(x, y)
    local randomPool = 50.0
    while true do
        if (randomPool > 2900) then return end
        local vehSpawnResult = {}
        vehSpawnResult["x"] = 0.0
        vehSpawnResult["y"] = 0.0
        vehSpawnResult["z"] = 30.0
        vehSpawnResult["x"] = x + math.random(randomPool - (randomPool * 2), randomPool) + 1.0
        vehSpawnResult["y"] = y + math.random(randomPool - (randomPool * 2), randomPool) + 1.0
        roadtest, vehSpawnResult, outHeading = GetClosestVehicleNode(vehSpawnResult["x"], vehSpawnResult["y"], vehSpawnResult["z"], 0, 55.0, 55.0)
        Citizen.Wait(1000)
        if vehSpawnResult["z"] ~= 0.0 then
            local caisseo = GetClosestVehicle(vehSpawnResult["x"], vehSpawnResult["y"], vehSpawnResult["z"], 20.000, 0, 70)
            if not DoesEntityExist(caisseo) then
                return vehSpawnResult["x"], vehSpawnResult["y"], vehSpawnResult["z"], outHeading
            end
        end
        randomPool = randomPool + 50.0
    end
end

local function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        offset = offset - 1
        if vehicle ~= 0 then break end
    end

    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    if distance > 25 then vehicle = nil end
    return vehicle ~= nil and vehicle or 0
end

function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

function Progressbar(duration, label)
	local retval = nil
	QBCore.Functions.Progressbar("drugs", label, duration, false, false, {
		disableMovement = false,
		disableCarMovement = false,
		disableMouse = false,
		disableCombat = false,
	}, {}, {}, {}, function()
		retval = true
	end, function()
		retval = false
	end)

	while retval == nil do
		Wait(1)
	end

	return retval
end

-- Events

RegisterNetEvent('truckrobbery:gruppeCard', function()
    local coordA = GetEntityCoords(PlayerPedId(), 1)
    local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 100.0, 0.0)
    local targetVehicle = getVehicleInDirection(coordA, coordB)
    if targetVehicle ~= 0 and GetHashKey("stockade") == GetEntityModel(targetVehicle) then
        local entityCreatePoint = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0, -4.0, 0.0)
        local coords = GetEntityCoords(PlayerPedId())
        local aDist = GetDistanceBetweenCoords(coords["x"], coords["y"], coords["z"], entityCreatePoint["x"], entityCreatePoint["y"], entityCreatePoint["z"])
        if aDist < 2.0 then
            local randomcode = math.random(1000, 9999)
            local street = GetTheStreet()
            TriggerEvent("truckrobbery:AttemptHeist", targetVehicle)
        else
            QBCore.Functions.Notify('You need to do this from behind the vehicle.')
        end
    end
end)

RegisterNetEvent('truckrobbery:AttemptHeist', function(veh)
    attempted = veh
    SetEntityAsMissionEntity(attempted, true, true)
    local plate = GetVehicleNumberPlateText(veh)
    local pedCo = GetEntityCoords(PlayerPedId())
    QBCore.Functions.Progressbar("unlockdoor_action", "Unlocking Vehicle", 1, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 49
    }, {}, {}, function(status)
        if not status then
            TriggerEvent("truckrobbery:AllowHeist", veh)
            TriggerServerEvent("truckrobbery:removeItem", "security_card_02", 1)
        end
    end)
end)

RegisterNetEvent('truckrobbery:AllowHeist', function(veh)
    TriggerEvent("truckrobbery:AddPeds", attempted)
    SetVehicleDoorOpen(attempted, 2, 0, 0)
    SetVehicleDoorOpen(attempted, 3, 0, 0)
    TriggerEvent("truckrobbery:PickupCash")
end)

RegisterNetEvent('truckrobbery:AddPeds', function(veh)
    local cType = 'ig_casey'

    local pedmodel = GetHashKey(cType)
    RequestModel(pedmodel)
    while not HasModelLoaded(pedmodel) do
        RequestModel(pedmodel)
        Citizen.Wait(100)
    end

    ped2 = CreatePedInsideVehicle(veh, 4, pedmodel, 0, 1, 0.0)
    ped3 = CreatePedInsideVehicle(veh, 4, pedmodel, 1, 1, 0.0)
    ped4 = CreatePedInsideVehicle(veh, 4, pedmodel, 2, 1, 0.0)

    GiveWeaponToPed(ped2, GetHashKey('WEAPON_SPECIALCARBINE'), 420, 0, 1)
    GiveWeaponToPed(ped3, GetHashKey('WEAPON_SPECIALCARBINE'), 420, 0, 1)
    GiveWeaponToPed(ped4, GetHashKey('WEAPON_SPECIALCARBINE'), 420, 0, 1)

    SetPedMaxHealth(ped2, 350)
    SetPedMaxHealth(ped3, 350)
    SetPedMaxHealth(ped4, 350)

    SetPedDropsWeaponsWhenDead(ped2, false)
    SetPedRelationshipGroupDefaultHash(ped2, GetHashKey('COP'))
    SetPedRelationshipGroupHash(ped2, GetHashKey('COP'))
    SetPedAsCop(ped2, true)
    SetCanAttackFriendly(ped2, false, true)

    SetPedDropsWeaponsWhenDead(ped3, false)
    SetPedRelationshipGroupDefaultHash(ped3, GetHashKey('COP'))
    SetPedRelationshipGroupHash(ped3, GetHashKey('COP'))
    SetPedAsCop(ped3, true)
    SetCanAttackFriendly(ped3, false, true)

    SetPedDropsWeaponsWhenDead(ped4, false)
    SetPedRelationshipGroupDefaultHash(ped4, GetHashKey('COP'))
    SetPedRelationshipGroupHash(ped4, GetHashKey('COP'))
    SetPedAsCop(ped4, true)
    SetCanAttackFriendly(ped4, false, true)

    TaskCombatPed(ped2, PlayerPedId(), 0, 16)
    TaskCombatPed(ped3, PlayerPedId(), 0, 16)
    TaskCombatPed(ped4, PlayerPedId(), 0, 16)
end)

RegisterNetEvent('truckrobbery:PickupCash', function()
    pickup = true
    TriggerEvent("truckrobbery:PickupCashLoop")
    Wait(180000)
    pickup = false
end)

RegisterNetEvent('truckrobbery:PickupCashLoop', function()
    local markerlocation = GetOffsetFromEntityInWorldCoords(attempted, 0.0, -3.7, 0.1)
    SetVehicleHandbrake(attempted, true)
    while pickup do
        Citizen.Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        local aDist = GetDistanceBetweenCoords(coords["x"], coords["y"], coords["z"], markerlocation["x"], markerlocation["y"], markerlocation["z"])
        if aDist < 10.0 then

            if aDist < 2.0 and pickup then
                if IsDisabledControlJustReleased(0, 38) then
                    pickUpCash()
                    pickup = false
                end
                DrawText3Ds(markerlocation["x"], markerlocation["y"], markerlocation["z"], "[E] - Grab Items")
            else
                DrawText3Ds(markerlocation["x"], markerlocation["y"], markerlocation["z"], "Grab Items")
            end
        end
    end
end)
