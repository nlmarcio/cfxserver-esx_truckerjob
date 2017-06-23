--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Script serveur No Brain 
-- www.nobrain.org
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
------------------- Configuration du script
--------------------------------------------------------------------------------
local livraisonmax = 10
local prixcamion = 1500
--------------------------------------------------------------------------------
-- NE RIEN MODIFIER
--------------------------------------------------------------------------------
local namezone = "Delivery"
local namezonenum = 0
local namezoneregion = 0
local MissionRegion = 0
local viemaxvehicule = 1000
local argentretire = 0
local livraisonTotalPaye = 0
local livraisonnombre = 0
local MissionRetourCamion = false
local MissionNum = 0
local MissionLivraison = false
local isInService = false
local PlayerData              = {}
local GUI                     = {}
GUI.Time                      = 0
local hasAlreadyEnteredMarker = false;
local lastZone                = nil;
local Blips                   = {}
--------------------------------------------------------------------------------
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

AddEventHandler('playerSpawned', function(spawn)
	TriggerServerEvent('esx_truckerjob:requestPlayerData', 'playerSpawned')
end)

AddEventHandler('esx_truckerjob:hasEnteredMarker', function(zone)

	if zone == 'CloakRoom' then
		SendNUIMessage({
			showControls = true,
			controls     = 'cloakroom'
		})
	end

	if zone == 'VehicleSpawner' then
		if isInService and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
			if MissionRetourCamion or MissionLivraison then
				TriggerEvent('esx:showNotification', 'On t\'as deja fournie un camion !')
			else
				SendNUIMessage({
					showControls = true,
					controls     = 'vehiclespawner'
				})
			end
		end
	end

	if zone == namezone then
		if isInService and MissionLivraison and MissionNum == namezonenum and MissionRegion == namezoneregion and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
			if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("mule3", _r)) then
				VerifPlaqueVehiculeActuel()
				
				if plaquevehicule == plaquevehiculeactuel then
					if Blips['delivery'] ~= nil then
						RemoveBlip(Blips['delivery'])
						Blips['delivery'] = nil
					end

					SendNUIMessage({
						showControls = true,
						controls     = 'delivery'
					})
				else
					TriggerEvent('esx:showNotification', 'Ce n\'est pas le camion qu\'on t\'as fournie !')
				end
			else
				TriggerEvent('esx:showNotification', 'Vous devez être dans le camion qu\'on vous as fournie !')
			end
		end
	end

	if zone == 'AnnulerMission' then
		if isInService and MissionLivraison and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
			if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("mule3", _r)) then
				VerifPlaqueVehiculeActuel()
				
				if plaquevehicule == plaquevehiculeactuel then
					SendNUIMessage({
						showControls = true,
						controls     = 'retourcamionannulermission'
					})
				else
					TriggerEvent('esx:showNotification', 'Ce n\'est pas le camion qu\'on t\'as fournie !')
				end
			else
				SendNUIMessage({
					showControls = true,
					controls     = 'retourcamionperduannulermission'
				})
			end
		end
	end

	if zone == 'RetourCamion' then
		if isInService and MissionRetourCamion and PlayerData.job.name ~= nil and PlayerData.job.name == 'trucker' then
			if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and IsVehicleModel(GetVehiclePedIsUsing(GetPlayerPed(-1)), GetHashKey("mule3", _r)) then
				VerifPlaqueVehiculeActuel()
				
				if plaquevehicule == plaquevehiculeactuel then
					SendNUIMessage({
						showControls = true,
						controls     = 'retourcamion'
					})
				else
					TriggerEvent('esx:showNotification', 'Ce n\'est pas le camion qu\'on t\'as fournie !')
				end
			else
				SendNUIMessage({
					showControls = true,
					controls     = 'retourcamionperdu'
				})
			end
		end
	end

end)

AddEventHandler('esx_truckerjob:hasExitedMarker', function(zone)

	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_truckerjob:responsePlayerData')
AddEventHandler('esx_truckerjob:responsePlayerData', function(data, reason)
	PlayerData = data
end)

RegisterNetEvent('esx_truckerjob:finService')
AddEventHandler('esx_truckerjob:finService', function()
	isInService = false
end)

RegisterNUICallback('select', function(data, cb)

	if data.menu == 'cloakroom' then

		if data.val == 'citizen_wear' then
			SendNUIMessage({
				showControls = false,
				showMenu     = false,
			})
			TriggerEvent('esx_truckerjob:finService')
			TriggerEvent('esx_skin:loadSkin', PlayerData.skin)
		end

		if data.val == 'trucker_wear' then
			SendNUIMessage({
				showControls = false,
				showMenu     = false,
			})
			if PlayerData.skin.sex == 0 then
				isInService = true
				TriggerEvent('esx_skin:loadJobSkin', PlayerData.skin, PlayerData.job.skin_male)
			else
				isInService = true
				TriggerEvent('esx_skin:loadJobSkin', PlayerData.skin, PlayerData.job.skin_female)
			end
		end

	end

	if data.menu == 'retourcamion' then

		if data.val == 'retourcamion_oui' then
			retourcamion_oui()
		end

		if data.val == 'retourcamion_non' then
			retourcamion_non()
		end

	end

	if data.menu == 'retourcamionperdu' then

		if data.val == 'retourcamionperdu_oui' then
			retourcamionperdu_oui()
		end

		if data.val == 'retourcamionperdu_non' then
			retourcamionperdu_non()
		end

	end

	if data.menu == 'retourcamionannulermission' then

		if data.val == 'retourcamionannulermission_oui' then
			retourcamionannulermission_oui()
		end

		if data.val == 'retourcamionannulermission_non' then
			retourcamionannulermission_non()
		end

	end

	if data.menu == 'retourcamionperduannulermission' then

		if data.val == 'retourcamionperduannulermission_oui' then
			retourcamionperduannulermission_oui()
		end

		if data.val == 'retourcamionperduannulermission_non' then
			retourcamionperduannulermission_non()
		end

	end

	if data.menu == 'vehiclespawner' then

		local playerPed = GetPlayerPed(-1)

		Citizen.CreateThread(function()

			local coords       = Config.Zones.VehicleSpawnPoint.Pos
			local vehicleModel = GetHashKey(data.val)

			RequestModel(vehicleModel)

			while not HasModelLoaded(vehicleModel) do
				Citizen.Wait(0)
			end

			if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
				local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, 269.12, true, false)
				SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
				SetEntityAsMissionEntity(vehicle,  true,  true)
				platenum = math.random(1000, 9999)
				SetVehicleNumberPlateText(vehicle, "WAL"..platenum)
				local id = NetworkGetNetworkIdFromEntity(vehicle)
				SetNetworkIdCanMigrate(id, true)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				Wait(1000)
				SavePlaqueVehicule()
			end

		end)
		
		if data.val == "mule3" then
			MissionLivraisonSelect()
		end

	end

	cb('ok')

end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		
		if MissionLivraison then
			DrawMarker(destination.Type, destination.Pos.x, destination.Pos.y, destination.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, destination.Size.x, destination.Size.y, destination.Size.z, destination.Color.r, destination.Color.g, destination.Color.b, 100, false, true, 2, false, false, false, false)
			DrawMarker(Config.Livraison.AnnulerMission.Type, Config.Livraison.AnnulerMission.Pos.x, Config.Livraison.AnnulerMission.Pos.y, Config.Livraison.AnnulerMission.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Livraison.AnnulerMission.Size.x, Config.Livraison.AnnulerMission.Size.y, Config.Livraison.AnnulerMission.Size.z, Config.Livraison.AnnulerMission.Color.r, Config.Livraison.AnnulerMission.Color.g, Config.Livraison.AnnulerMission.Color.b, 100, false, true, 2, false, false, false, false)
		elseif MissionRetourCamion then
			DrawMarker(destination.Type, destination.Pos.x, destination.Pos.y, destination.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, destination.Size.x, destination.Size.y, destination.Size.z, destination.Color.r, destination.Color.g, destination.Color.b, 100, false, true, 2, false, false, false, false)
		end
		
	end
end)

RegisterNUICallback('select_control', function(data, cb)

	if data.control == 'delivery' then
		nouvelledestination()
	end

	if data.control == 'retourcamion_oui' then
		retourcamion_oui()
	end

	if data.control == 'retourcamion_non' then
		retourcamion_non()
	end

	if data.control == 'retourcamionperdu_oui' then
		retourcamionperdu_oui()
	end

	if data.control == 'retourcamionperdu_non' then
		retourcamionperdu_non()
	end

	if data.control == 'retourcamionannulermission_oui' then
		retourcamionannulermission_oui()
	end

	if data.control == 'retourcamionannulermission_non' then
		retourcamionannulermission_non()
	end

	if data.control == 'retourcamionperduannulermission_oui' then
		retourcamionperduannulermission_oui()
	end

	if data.control == 'retourcamionperduannulermission_non' then
		retourcamionperduannulermission_non()
	end

	cb('ok')
end)

function nouvelledestination()
	livraisonnombre = livraisonnombre+1
	livraisonTotalPaye = livraisonTotalPaye+destination.Paye

	if livraisonnombre >= livraisonmax then
		MissionLivraisonStopRetourDepot()
	else

		livraisonsuite = math.random(0, 100)
		
		if livraisonsuite <= 10 then
			MissionLivraisonStopRetourDepot()
		elseif livraisonsuite <= 99 then
			MissionLivraisonSelect()
		elseif livraisonsuite <= 100 then
			if MissionRegion == 1 then
				MissionRegion = 2
			elseif MissionRegion == 2 then
				MissionRegion = 1
			end
			MissionLivraisonSelect()	
		end
	end
end

function retourcamion_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	MissionRetourCamion = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapaye()
end

function retourcamion_non()
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	if livraisonnombre >= livraisonmax then
		TriggerEvent('esx:showNotification', 'Ouai mais il faut là !')
	else
		TriggerEvent('esx:showNotification', 'Ok, au boulot alors !')
		nouvelledestination()
	end
end

function retourcamionperdu_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	MissionRetourCamion = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapayesanscamion()
end

function retourcamionperdu_non()
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	TriggerEvent('esx:showNotification', 'Ok tu m\'as fait peur là !')
end

function retourcamionannulermission_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	MissionLivraison = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapaye()
end

function retourcamionannulermission_non()
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	TriggerEvent('esx:showNotification', 'Ok, reprend ta livraison alors !')
end

function retourcamionperduannulermission_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	MissionLivraison = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapayesanscamion()
end

function retourcamionperduannulermission_non()
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	TriggerEvent('esx:showNotification', 'Ok, reprend ta livraison alors ! ')
end

--fonction pour supprimer voiture
function deleteCar( entity )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
end
--fonction pour arondir
function round(num, numDecimalPlaces)
  local mult = 5^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function donnerlapaye()
	ped = GetPlayerPed(-1)
	vehicle = GetVehiclePedIsIn(ped, false)
	vievehicule = GetVehicleEngineHealth(vehicle)
	calculargentretire = round(viemaxvehicule-vievehicule)
	
	if calculargentretire <= 0 then
		argentretire = 0
	else
		argentretire = calculargentretire
	end
	
	-- despawn camion
	SetEntityAsMissionEntity( vehicle, true, true )
	deleteCar( vehicle )
	
	-- donne paye
	local amount = livraisonTotalPaye-argentretire
	
	if vievehicule >= 1 then
		if livraisonTotalPaye == 0 then
			TriggerEvent('esx:showNotification', 'Pas de livraison, pas de cheque mec !')
			TriggerEvent('esx:showNotification', 'Parcontre tu paye les réparations hein !')
			TriggerEvent('esx:showNotification', 'Réparations camion : -'..argentretire)
			TriggerServerEvent("esx_truckerjob:pay", amount)
			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then
				TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
					TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			else
				TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
				TriggerEvent('esx:showNotification', 'Réparations camion : -'..argentretire)
					TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			end
		end
	else
		if livraisonTotalPaye ~= 0 and amount <= 0 then
			TriggerEvent('esx:showNotification', 'Pas de cheque mec, vue l\'état du camion !')
			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then
				TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
					TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			else
				TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
				TriggerEvent('esx:showNotification', 'Réparations camion : -'..argentretire)
					TriggerServerEvent("esx_truckerjob:pay", amount)
				livraisonTotalPaye = 0
			end
		end
	end
end

function donnerlapayesanscamion()
	ped = GetPlayerPed(-1)
	argentretire = prixcamion
	
	-- donne paye
	local amount = livraisonTotalPaye-argentretire
	
	if livraisonTotalPaye == 0 then
		TriggerEvent('esx:showNotification', 'Pas de livraison, pas de camion ! C\'est une blague?')
		TriggerEvent('esx:showNotification', 'Prix camion : -'..argentretire)
					TriggerServerEvent("esx_truckerjob:pay", amount)
		livraisonTotalPaye = 0
	else
		if amount >= 1 then
			TriggerEvent('esx:showNotification', 'Livraisons : +'..livraisonTotalPaye)
			TriggerEvent('esx:showNotification', 'Prix camion : -'..argentretire)
					TriggerServerEvent("esx_truckerjob:pay", amount)
			livraisonTotalPaye = 0
		else
			TriggerEvent('esx:showNotification', 'Pas de cheque mec, vue l\'état du camion !')
			livraisonTotalPaye = 0
		end
	end
end

-- Display markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Zones) do

			if isInService and (PlayerData.job ~= nil and PlayerData.job.name == 'trucker' and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end

		end
	end
end)

Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Cloakroom) do

			if(PlayerData.job ~= nil and PlayerData.job.name == 'trucker' and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end

		end
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		if(PlayerData.job ~= nil and PlayerData.job.name == 'trucker') then

			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end
			
			for k,v in pairs(Config.Cloakroom) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end
			
			for k,v in pairs(Config.Livraison) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
				lastZone                = currentZone
				TriggerEvent('esx_truckerjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_truckerjob:hasExitedMarker', lastZone)
			end

		end

	end
end)

-- Create blips
Citizen.CreateThread(function()

	local blip = AddBlipForCoord(Config.Cloakroom.CloakRoom.Pos.x, Config.Cloakroom.CloakRoom.Pos.y, Config.Cloakroom.CloakRoom.Pos.z)
  
  SetBlipSprite (blip, 67)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.2)
  SetBlipColour (blip, 5)
  SetBlipAsShortRange(blip, true)
	
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Walker Logistics")
  EndTextCommandSetBlipName(blip)

end)

-- Menu Controls
Citizen.CreateThread(function()
	while true do

		Wait(0)

		if IsControlPressed(0, Keys['ENTER']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				enterPressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['BACKSPACE']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				backspacePressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['LEFT']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'LEFT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['RIGHT']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'RIGHT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['TOP']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'UP'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['DOWN']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'DOWN'
			})

			GUI.Time = GetGameTimer()

		end

	end
end)

-------------------------------------------------
-- Fonctions
-------------------------------------------------
-- Fonction selection nouvelle mission livraison
function MissionLivraisonSelect()
	if MissionRegion == 0 then
		MissionRegion = math.random(1,2)
	end
	
	if MissionRegion == 1 then -- Los santos
		MissionNum = math.random(1, 10)
	
		if MissionNum == 1 then destination = Config.Livraison.Delivery1LS namezone = "Delivery1LS" namezonenum = 1 namezoneregion = 1
		elseif MissionNum == 2 then destination = Config.Livraison.Delivery2LS namezone = "Delivery2LS" namezonenum = 2 namezoneregion = 1
		elseif MissionNum == 3 then destination = Config.Livraison.Delivery3LS namezone = "Delivery3LS" namezonenum = 3 namezoneregion = 1
		elseif MissionNum == 4 then destination = Config.Livraison.Delivery4LS namezone = "Delivery4LS" namezonenum = 4 namezoneregion = 1
		elseif MissionNum == 5 then destination = Config.Livraison.Delivery5LS namezone = "Delivery5LS" namezonenum = 5 namezoneregion = 1
		elseif MissionNum == 6 then destination = Config.Livraison.Delivery6LS namezone = "Delivery6LS" namezonenum = 6 namezoneregion = 1
		elseif MissionNum == 7 then destination = Config.Livraison.Delivery7LS namezone = "Delivery7LS" namezonenum = 7 namezoneregion = 1
		elseif MissionNum == 8 then destination = Config.Livraison.Delivery8LS namezone = "Delivery8LS" namezonenum = 8 namezoneregion = 1
		elseif MissionNum == 9 then destination = Config.Livraison.Delivery9LS namezone = "Delivery9LS" namezonenum = 9 namezoneregion = 1
		elseif MissionNum == 10 then destination = Config.Livraison.Delivery10LS namezone = "Delivery10LS" namezonenum = 10 namezoneregion = 1
		end
		
	elseif MissionRegion == 2 then -- Blaine County
		MissionNum = math.random(1, 10)
	
		if MissionNum == 1 then destination = Config.Livraison.Delivery1BC namezone = "Delivery1BC" namezonenum = 1 namezoneregion = 2
		elseif MissionNum == 2 then destination = Config.Livraison.Delivery2BC namezone = "Delivery2BC" namezonenum = 2 namezoneregion = 2
		elseif MissionNum == 3 then destination = Config.Livraison.Delivery3BC namezone = "Delivery3BC" namezonenum = 3 namezoneregion = 2
		elseif MissionNum == 4 then destination = Config.Livraison.Delivery4BC namezone = "Delivery4BC" namezonenum = 4 namezoneregion = 2
		elseif MissionNum == 5 then destination = Config.Livraison.Delivery5BC namezone = "Delivery5BC" namezonenum = 5 namezoneregion = 2
		elseif MissionNum == 6 then destination = Config.Livraison.Delivery6BC namezone = "Delivery6BC" namezonenum = 6 namezoneregion = 2
		elseif MissionNum == 7 then destination = Config.Livraison.Delivery7BC namezone = "Delivery7BC" namezonenum = 7 namezoneregion = 2
		elseif MissionNum == 8 then destination = Config.Livraison.Delivery8BC namezone = "Delivery8BC" namezonenum = 8 namezoneregion = 2
		elseif MissionNum == 9 then destination = Config.Livraison.Delivery9BC namezone = "Delivery9BC" namezonenum = 9 namezoneregion = 2
		elseif MissionNum == 10 then destination = Config.Livraison.Delivery10BC namezone = "Delivery10BC" namezonenum = 10 namezoneregion = 2
		end
		
	end
	
	MissionLivraisonLetsGo()
end

-- Fonction active mission livraison
function MissionLivraisonLetsGo()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
	SetBlipRoute(Blips['delivery'], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Walker Logistics : Livraison")
	EndTextCommandSetBlipName(Blips['delivery'])
	
	Blips['annulermission'] = AddBlipForCoord(Config.Livraison.AnnulerMission.Pos.x,  Config.Livraison.AnnulerMission.Pos.y,  Config.Livraison.AnnulerMission.Pos.z)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Walker Logistics : Terminer")
	EndTextCommandSetBlipName(Blips['annulermission'])

	if MissionRegion == 1 then -- Los santos
		TriggerEvent('esx:showNotification', 'Rendez-vous au point de livraison à Los Santos')
	elseif MissionRegion == 2 then -- Blaine County
		TriggerEvent('esx:showNotification', 'Rendez-vous au point de livraison à Blaine County')
	elseif MissionRegion == 0 then -- au cas ou
		TriggerEvent('esx:showNotification', 'Rendez-vous au point de livraison')
	end

	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})

	MissionLivraison = true
end

--Fonction retour au depot
function MissionLivraisonStopRetourDepot()
	destination = Config.Livraison.RetourCamion
	
	Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
	SetBlipRoute(Blips['delivery'], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Walker Logistics : dépot")
	EndTextCommandSetBlipName(Blips['delivery'])
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end

	TriggerEvent('esx:showNotification', 'Retournez au dépot.')
	
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
	
	MissionRegion = 0
	MissionLivraison = false
	MissionNum = 0
	MissionRetourCamion = true
end

function SavePlaqueVehicule()
	plaquevehicule = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end

function VerifPlaqueVehiculeActuel()
	plaquevehiculeactuel = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end