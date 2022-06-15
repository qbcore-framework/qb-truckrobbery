local QBCore = exports['qb-core']:GetCoreObject()

local PickupMoney = 0
local BlowBackdoor = 0
local PoliceAlert = 0
local LootTime = 1
local GuardsDead = 0
local prop
local lootable = 0
local BlownUp = 0
local TruckBlip
local transport
local MissionStart = 0
local warning = 0
local VehicleCoords = nil
local dealer
local PlayerJob = {}
local pilot = nil
local navigator = nil

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

CreateThread(function()
    while true do
        Wait(2)
		local plyCoords = GetEntityCoords(PlayerPedId(), false)
		local dist = #(plyCoords - vector3(Config.MissionMarker.x, Config.MissionMarker.y, Config.MissionMarker.z))
	
		if dist <= 50.0 and PlayerJob.name ~= 'police' then
		if not DoesEntityExist(dealer) then
				RequestModel(Config.Dealer)
				while not HasModelLoaded(Config.Dealer) do
					Wait(10)
				end
				dealer = CreatePed(26, Config.Dealer, Config.dealerCoords.x, Config.dealerCoords.y, Config.dealerCoords.z, 268.9422, false, false)
				SetEntityHeading(dealer, 1.8)
				SetBlockingOfNonTemporaryEvents(dealer, true)
				TaskStartScenarioInPlace(dealer, "WORLD_HUMAN_AA_SMOKE", 0, false)
			end
			if MissionStart == 0 and dist <= 2 then
				if Config.UseTarget then
					exports['qb-target']:AddTargetEntity(dealer, {
						options = {
							{
								type = "server",
								event = "truckrobbery:AcceptMission",
								icon = "fas fa-circle-check",
								label = Lang:t("mission.accept_mission_target"),
								canInteract = function()
									if PlayerJob.name == "police" or PlayerJob.name == "sheriff" then return false end
									return true
								end,
							},
						},
						distance = 3.0
					})
				else
					DrawMarker(25, Config.dealerCoords.x, Config.dealerCoords.y, Config.dealerCoords.z - 0.90, 0, 0, 0, 0, 0, 0, 1.301, 1.3001, 1.3001, 0, 205, 250, 200, 0, 0, 0, 0)
					if dist <= 1.5 then
						QBCore.Functions.DrawText3D(Config.dealerCoords.x, Config.dealerCoords.y, Config.dealerCoords.z, Lang:t("mission.accept_mission"))
						if IsControlJustPressed(0, 38) and dist <= 4.0 then
							TriggerServerEvent("truckrobbery:AcceptMission")
							Wait(500)
						end
					end
				end
			else
				exports['qb-target']:RemoveTargetEntity(dealer, Lang:t("mission.accept_mission_target"))
			end
		elseif DoesEntityExist(dealer) then
			DeleteEntity(dealer)
		else
			Wait(1500)
		end
	end
end)

function CheckGuards()
	if IsPedDeadOrDying(pilot) and IsPedDeadOrDying(navigator) then
		GuardsDead = 1
	end
	Wait(500)
end

RegisterNetEvent('truckrobbery:client:911alert', function()
    if PoliceAlert == 0 then
        local transCoords = GetEntityCoords(transport)
        TriggerServerEvent("truckrobbery:server:callCops", transCoords)

        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 0)
        PoliceAlert = 1
    end
end)

RegisterNetEvent('truckrobbery:client:robberyCall', function(msg, coords)
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

function MissionNotification()
	Wait(2000)
	TriggerServerEvent('qb-phone:server:sendNewMail', {
	sender = Lang:t('mission.sender'),
	subject = Lang:t('mission.subject'),
	message = Lang:t('mission.message'),
	})
	Wait(3000)
end

RegisterNetEvent('truckrobbery:StartMission', function()
	MissionNotification()
	ClearPedTasks(dealer)
	TaskWanderStandard(dealer, 10.0, 10)
	local DrawCoord = math.random(1, Config.MaxSpawns)
	VehicleCoords = Config.VehicleSpawns[DrawCoord]

	RequestModel(GetHashKey(Config.TruckModel))
	while not HasModelLoaded(GetHashKey(Config.TruckModel)) do
		Wait(0)
	end

	ClearAreaOfVehicles(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, 15.0, false, false, false, false, false)
	transport = CreateVehicle(GetHashKey(Config.TruckModel), VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, VehicleCoords.w, true, true)
	SetEntityAsMissionEntity(transport)
	TruckBlip = AddBlipForEntity(transport)
	SetBlipSprite(TruckBlip, 67)
	SetBlipColour(TruckBlip, 1)
	SetBlipFlashes(TruckBlip, true)
	SetBlipRoute(TruckBlip,  true)
	SetBlipRouteColour(TruckBlip, Config.RouteColor)
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
	TaskVehicleDriveWander(navigator, transport, 80.0, 536871867)
	MissionStart = 1
end)

CreateThread(function()
    while true do
        Wait(5)
		if MissionStart == 1 then
			local plyCoords = GetEntityCoords(PlayerPedId(), false)
			local transCoords = GetEntityCoords(transport)
			local dist = #(plyCoords - transCoords)

			if dist <= 75.0 and PlayerJob.name ~= 'police' then
				DrawMarker(0, transCoords.x, transCoords.y, transCoords.z+4.5, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 135, 31, 35, 100, 1, 0, 0, 0)
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
										action = function()
											if PlayerJob.name == 'police' then return false end
											CheckVehicleInformation()
											return true
										end,
										canInteract = function()
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

function CheckVehicleInformation()
	if IsVehicleStopped(transport) then
		if GuardsDead == 1 then
			if not IsEntityInWater(PlayerPedId()) then
				if Config.UseTarget then
					exports['qb-target']:RemoveTargetEntity(transport, Lang:t('info.plant_bomb'))
				end
				BlownUp = 1
				local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
				prop = CreateObject(GetHashKey('prop_c4_final_green'), x, y, z+0.2,  true,  true, true)
				AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.06, 0.0, 0.06, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
				SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"),true)
				Wait(500)
				QBCore.Functions.Progressbar('planting_bomb', Lang:t('info.planting_bomb'), 5000, false, true, { -- Name | Label | Time | useWhileDead | canCancel
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
				}, {
					animDict = 'anim@heists@ornate_bank@thermal_charge_heels',
					anim = 'thermal_charge',
					flags = 16,
				}, {}, {}, function() -- Play When Done
					ClearPedTasks(PlayerPedId())
					DetachEntity(prop)
					AttachEntityToEntity(prop, transport, GetEntityBoneIndexByName(transport, 'door_pside_r'), -0.7, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
					QBCore.Functions.Notify(Lang:t('info.bomb_timer', {TimeToBlow = Config.TimeToBlow / 1000}), "error")
					Wait(Config.TimeToBlow)
					local transCoords = GetEntityCoords(transport)
					SetVehicleDoorBroken(transport, 2, false)
					SetVehicleDoorBroken(transport, 3, false)
					AddExplosion(transCoords.x,transCoords.y,transCoords.z, 'EXPLOSION_TANKER', 2.0, true, false, 2.0)
					ApplyForceToEntity(transport, 0, 20.0, 500.0, 0.0, 0.0, 0.0, 0.0, 1, false, true, true, false, true)
					lootable = 1
					QBCore.Functions.Notify(Lang:t('info.collect'), "success")
				end, function() -- Play When Cancel
					ClearPedTasks(PlayerPedId())
					DetachEntity(prop)
					BlownUp = 0
				end)
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
							action = function()
								if PlayerJob.name == 'police' then return false end
								if lootable then
									TakingMoney()
								end
							end,
							canInteract = function()
								if PlayerJob.name == "police" or not lootable then return false end
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
						if IsControlJustPressed(0, 38) and lootable then
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
    RemoveBlip(TruckBlip)
	SetBlipRoute(TruckBlip, false)
end)

function TakingMoney()
	if lootable == 1 then
		lootable = 0
		if Config.UseTarget then
			exports['qb-target']:RemoveTargetEntity(transport, Lang:t("info.take_money_target"))
		end
		local PedCoords = GetEntityCoords(PlayerPedId())
		local bag = CreateObject(GetHashKey('prop_cs_heist_bag_02'),PedCoords.x, PedCoords.y,PedCoords.z, true, true, true)
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
			DeleteEntity(bag)
			SetPedComponentVariation(PlayerPedId(), 5, 45, 0, 2)
			TriggerServerEvent("truckrobbery:RobberySucess", LootTime)
			TriggerEvent('truckrobbery:CleanUp')
		end, function() -- Play When Cancel
			ClearPedTasks(PlayerPedId())
			lootable = 1
		end)
	end
end
