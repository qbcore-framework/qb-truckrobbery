local QBCore = exports['qb-core']:GetCoreObject()

local PickupMoney = 0
local BlowBackdoor = 0
local PoliceAlert = 0
local LootTime = 1
local GuardsDead = 0
local lootable = 0
local BlownUp = 0
local TruckBlip
local transport
local MissionStart = 0
local warning = 0
local dealer
local PlayerJob = {}
local VehicleCoords = nil
local bag = nil
local pilot = nil
local navigator = nil

-- Functions

local function createKeyListener(key, eventType, event)
	local listening = true
	CreateThread(function()
		while listening do
			if IsControlJustPressed(0, key) then
				if eventType == 'client' then
					TriggerEvent(event)
				elseif eventType == 'server' then
					TriggerServerEvent(event)
				end
				exports['qb-core']:KeyPressed()
				listening = false
			end
			Wait()
		end
	end)
end

function CheckVehicleInformation()
	if IsVehicleStopped(transport) then
		if GuardsDead == 1 then
			if not IsEntityInWater(PlayerPedId()) then
				RequestAnimDict('anim@heists@ornate_bank@thermal_charge_heels')
				while not HasAnimDictLoaded('anim@heists@ornate_bank@thermal_charge_heels') do
					Wait(50)
				end
				local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
				prop = CreateObject(GetHashKey('prop_c4_final_green'), x, y, z+0.2,  true,  true, true)
				AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.06, 0.0, 0.06, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
				SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"),true)
				FreezeEntityPosition(PlayerPedId(), true)
				TaskPlayAnim(PlayerPedId(), 'anim@heists@ornate_bank@thermal_charge_heels', "thermal_charge", 3.0, -8, -1, 63, 0, 0, 0, 0 )
				Wait(5500)
				ClearPedTasks(PlayerPedId())
				DetachEntity(prop)
				AttachEntityToEntity(prop, transport, GetEntityBoneIndexByName(transport, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
				QBCore.Functions.Notify(Lang:t('info.bomb_timer', {TimeToBlow = Config.TimeToBlow / 1000}), "error")
				FreezeEntityPosition(PlayerPedId(), false)
				Wait(Config.TimeToBlow)
				local transCoords = GetEntityCoords(transport)
				SetVehicleDoorBroken(transport, 2, false)
				SetVehicleDoorBroken(transport, 3, false)
				AddExplosion(transCoords.x,transCoords.y,transCoords.z, 'EXPLOSION_TANKER', 2.0, true, false, 2.0)
				ApplyForceToEntity(transport, 0, 20.0, 500.0, 0.0, 0.0, 0.0, 0.0, 1, false, true, true, false, true)
				BlownUp = 1
				lootable = 1
				QBCore.Functions.Notify(Lang:t('info.collect'), "success")
				RemoveBlip(TruckBlip)
				if Config.UseTarget then
					exports['qb-target']:RemoveTargetEntity(transport, Lang:t("info.plant_bomb")) 
				end
			else
				QBCore.Functions.Notify(Lang:t('info.get_out_water'), "error")
			end
		else
			QBCore.Functions.Notify(Lang:t('error.guards_dead'), "error")
		end
	else
		QBCore.Functions.Notify(Lang:t('error.truck_ismoving'), "error")
	end
end

function TakingMoney()
	local PedCoords = GetEntityCoords(PlayerPedId())
	bag = CreateObject(GetHashKey('prop_cs_heist_bag_02'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
	AttachEntityToEntity(bag, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
	QBCore.Functions.Notify(Lang:t('success.packing_cash'), "success")
	local _time = GetGameTimer()
	QBCore.Functions.Progressbar('Grabbing_money', Lang:t('info.grabing_money'), 5000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = 'anim@heists@ornate_bank@grab_cash_heels',
		anim = 'grab',
		flags = 1,
	}, {}, {}, function() -- Play When Done
		ClearPedTasks(PlayerPedId())
		LootTime = GetGameTimer() - _time
		if Config.UseTarget then
			exports['qb-target']:RemoveTargetEntity(transport, Lang:t("info.take_money_target")) 
		end
		DeleteEntity(bag)
		SetPedComponentVariation(PlayerPedId(), 5, 45, 0, 2)
		TriggerServerEvent("truckrobbery:RobberySucess", LootTime)
		TriggerEvent('truckrobbery:CleanUp')
	end, function() -- Play When Cancel
		ClearPedTasks(PlayerPedId())
		lootable = 1
	end)
end

function MissionNotification()
	Wait(2000)
	TriggerServerEvent('qb-phone:server:sendNewMail', {
	sender = Lang:t('mission.sender'),
	subject = Lang:t('mission.subject'),
	message = Lang:t('mission.message'),
	})
	Wait(3000)
end

function CheckGuards()
	if IsPedDeadOrDying(pilot) and IsPedDeadOrDying(navigator) then
		GuardsDead = 1
	end
	Wait(500)
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
	PlayerJob = jobInfo
end)

RegisterNetEvent('truckrobbery:client:911alert', function()
    if PoliceAlert == 0 then
        local transCoords = GetEntityCoords(transport)
        TriggerServerEvent("truckrobbery:server:callCops", transCoords)

        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
        PoliceAlert = 1
    end
end)

RegisterNetEvent('truckrobbery:CleanUp', function()
    PickupMoney = 0
    BlowBackdoor = 0
    PoliceAlert = 0
    LootTime = 1
    GuardsDead = 0
    lootable = 0
    BlownUp = 0
    MissionStart = 0
    warning = 0
end)

RegisterNetEvent('truckrobbery:client:robberyCall', function(msg, coords)
	local msg = msg
   	local coords = coords
	local store = "Armored Truck"

    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
	QBCore.Functions.Notify(msg, 'police', 10000)

	local transG = 250
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 487)
    SetBlipColour(blip, 4)
    SetBlipDisplay(blip, 4)
    SetBlipAlpha(blip, transG)
    SetBlipScale(blip, 1.2)
    SetBlipFlashes(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Lang:t('info.cop_blip'))
    EndTextCommandSetBlipName(blip)
    while transG ~= 0 do
        Wait(180 * 4)
        transG = transG - 1
        SetBlipAlpha(blip, transG)
        if transG == 0 then
            SetBlipSprite(blip, 2)
            RemoveBlip(blip)
            return
        end
    end
end)

RegisterNetEvent('truckrobbery:StartMission', function()
	MissionNotification()
	ClearPedTasks(dealer)
	TaskWanderStandard(dealer, 10.0, 10)
	local DrawCoord = math.random(1, 5)
	if DrawCoord == 1 then
		VehicleCoords = Config.VehicleSpawn1
	elseif DrawCoord == 2 then
		VehicleCoords = Config.VehicleSpawn2
	elseif DrawCoord == 3 then
		VehicleCoords = Config.VehicleSpawn3
	elseif DrawCoord == 4 then
		VehicleCoords = Config.VehicleSpawn4
	elseif DrawCoord == 5 then
		VehicleCoords = Config.VehicleSpawn5
	end

	RequestModel(GetHashKey(Config.TruckModel))
	while not HasModelLoaded(GetHashKey(Config.TruckModel)) do
		Wait(0)
	end

	SetNewWaypoint(VehicleCoords.x, VehicleCoords.y)
	ClearAreaOfVehicles(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 15.0, false, false, false, false, false)
	transport = CreateVehicle(GetHashKey(Config.TruckModel), VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 52.0, true, true)
	SetEntityAsMissionEntity(transport)
	TruckBlip = AddBlipForEntity(transport)
	SetBlipSprite(TruckBlip, 67)
	SetBlipColour(TruckBlip, 1)
	SetBlipFlashes(TruckBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Lang:t('mission.stockade'))
	EndTextCommandSetBlipName(TruckBlip)
	--
	RequestModel(Config.Guard)
	while not HasModelLoaded(Config.Guard) do
		Wait(10)
	end
	pilot = CreatePed(26, Config.Guard, VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 268.9422, true, false)
	navigator = CreatePed(26, Config.Guard, VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 268.9422, true, false)
	SetPedIntoVehicle(pilot, transport, -1)
	SetPedIntoVehicle(navigator, transport, 0)
	SetPedFleeAttributes(pilot, 0, 0)
	SetPedCombatAttributes(pilot, 46, 1)
	SetPedCombatAbility(pilot, 100)
	SetPedCombatMovement(pilot, 2)
	SetPedCombatRange(pilot, 2)
	SetPedKeepTask(pilot, true)
	GiveWeaponToPed(pilot, GetHashKey(Config.DriverWep),250,false,true)
	SetPedAsCop(pilot, true)
	--
	SetPedFleeAttributes(navigator, 0, 0)
	SetPedCombatAttributes(navigator, 46, 1)
	SetPedCombatAbility(navigator, 100)
	SetPedCombatMovement(navigator, 2)
	SetPedCombatRange(navigator, 2)
	SetPedKeepTask(navigator, true)
	TaskEnterVehicle(navigator,transport,-1,0,1.0,1)
	GiveWeaponToPed(navigator, GetHashKey(Config.NavWep),250,false,true)
	SetPedAsCop(navigator, true)
	--
	TaskVehicleDriveWander(pilot, transport, 80.0, 536871867)
	MissionStart = 1
end)

-- Threads

CreateThread(function()
	if not DoesEntityExist(dealer) then
		RequestModel(Config.Dealer)
		repeat Wait() until HasModelLoaded(Config.Dealer)
		dealer = CreatePed(
			26, 
			GetHashKey(Config.Dealer), 
			Config.dealerCoords.x, 
			Config.dealerCoords.y, 
			Config.dealerCoords.z, 
			Config.dealerCoords.w, 
			false, 
			false
		)
		SetEntityHeading(dealer, 1.8)
		SetBlockingOfNonTemporaryEvents(dealer, true)
		SetEntityAsMissionEntity(dealer)
		FreezeEntityPosition(dealer, true)
		SetEntityInvincible(dealer, true)
		TaskStartScenarioInPlace(dealer, "WORLD_HUMAN_AA_SMOKE", 0, false)
		if Config.UseTarget then
			exports['qb-target']:AddTargetEntity(dealer, {
				options = {
					{
						type = "server",
						event = "truckrobbery:AcceptMission",
						icon = "fas fa-circle-check",
						label = Lang:t("mission.accept_mission_target"),
						canInteract = function(entity, distance, data)
							if PlayerJob.name == "police" then return false end
							return true
						end,
					},
				},
				distance = 3.0
			})
		else
			if not dealerZone then
				dealerZone = BoxZone:Create(Config.dealerCoords, 5.0, 5.0, {
					name = 'truckrobbery:dealerZone',
					debugPoly = false,
				})
				dealerZone:onPointInOut(PolyZone.getPlayerPosition ,function(isPointInside, point)
					if isPointInside then
						exports['qb-core']:DrawText(Lang:t('mission.accept_mission'), 'left')
						createKeyListener(38, 'server', 'truckrobbery:AcceptMission')
					else
						exports['qb-core']:HideText()
					end
				end)
			end
		end
	end
end)

CreateThread(function()
    while true do
        Wait(5)
		if MissionStart == 1 then
			local plyCoords = GetEntityCoords(PlayerPedId(), false)
			local transCoords = GetEntityCoords(transport)
			local dist = #(plyCoords - transCoords)

			if dist <= 75.0 and PlayerJob.name ~= 'police' then
				--DrawMarker(0, transCoords.x, transCoords.y, transCoords.z+4.5, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 135, 31, 35, 100, 1, 0, 0, 0)
				if warning == 0 then
					warning = 1
					QBCore.Functions.Notify(Lang:t("info.before_bomb"), "error")
				end

				if GuardsDead == 0 then
					CheckGuards()
				elseif GuardsDead == 1 and BlownUp == 0 then
					TriggerEvent('truckrobbery:client:911alert')
				end
			else
				Wait(500)
			end

			if dist <= 7 and BlownUp == 0  then
				if PlayerJob.name ~= 'police' then
					
					if GuardsDead == 1 and BlownUp == 0 then
						if Config.UseTarget then
							if BlowBackdoor == 0 and GuardsDead == 1 then
								QBCore.Functions.Notify(Lang:t("info.detonate_bomb_target"), "primary")
								BlowBackdoor = 1
							end
							exports['qb-target']:AddTargetEntity(transport, {
								options = {
									{
										icon = "fas fa-bomb",
										label = Lang:t("info.plant_bomb"),
										action = function(entity)
											if PlayerJob.name == 'police' then return false end
												CheckVehicleInformation()
												return true
										end,
										canInteract = function(entity, distance, data) 
											if PlayerJob.name == "police" then return false end 
											return true
										end,
									},
								},
								distance = 3.0
							})
							Wait(500)
						else
							if BlowBackdoor == 0 then
								QBCore.Functions.Notify(Lang:t("info.detonate_bomb"), "primary")
								BlowBackdoor = 1
							end
							if IsControlPressed(0, 47) and GuardsDead == 1 then
								CheckVehicleInformation()
								Wait(500)
							end
						end
					end
				end
			end
		else
			Wait(1500)
		end
	end
end)

CreateThread(function()
    while true do
        Wait(5)
		if lootable == 1 then
			local plyCoords = GetEntityCoords(PlayerPedId(), false)
			local transCoords = GetEntityCoords(transport)
            local dist = #(plyCoords - transCoords)

            if dist > 45.0 then
                Wait(500)
            end
            
			if Config.UseTarget then
				exports['qb-target']:AddTargetEntity(transport, {
					options = {
						{
							icon = "fas fa-sack-dollar",
							label = Lang:t("info.take_money_target"),
							action = function(entity)
								if PlayerJob.name == 'police' then return false end
								lootable = 0
								TakingMoney()
							end,
							canInteract = function(entity, distance, data) 
								if PlayerJob.name == "police" then return false end 
								return true
							end,
						},
					},
					distance = 3.0
				})
			else
				if dist <= 4.5 then
					if PickupMoney == 0 then
						QBCore.Functions.Notify(Lang:t("info.take_money"), 'primary', 7500)
						PickupMoney = 1
					end
					if IsControlJustPressed(0, 38) then
						lootable = 0
						TakingMoney()
						Wait(500)
					end
				end
			end
		else
			Wait(1500)
		end
	end
end)