ESX = nil
ped = GetPlayerPed(-1)
playerid = PlayerId()
isDead = false
isAdmin = false
whitelisted = false
isloaded = false
notsend = false
local PlayerData = {}
local DisableAttack = true
local notify = true
local commandcount = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
    PlayerData = ESX.GetPlayerData()
    CheckForBlips()
    CheckSkin()
    ESX.TriggerServerCallback('esx_aduty:checkAdmin', function(admin)
        isAdmin =  admin
    end)
end)
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
isloaded = true
TriggerServerEvent("ac:loaded")
end)
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

AddEventHandler("playerSpawned", function()
	commandcount = #GetRegisteredCommands()
	resourcecount = GetNumResources()
end)

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(10000)
	  if isAdmin then
	  print('admin : '.. tostring(isAdmin))
	  else
        local curPed = PlayerPedId()
        local curHealth = GetEntityHealth( curPed )
        SetEntityHealth( curPed, curHealth-2)
        local curWait = math.random(10,150)
        Citizen.Wait(curWait)
		if PlayerPedId() == curPed and GetEntityHealth(curPed) == curHealth and GetEntityHealth(curPed) ~= 0 and GetEntityHealth(curPed) > 2 then
			TriggerServerEvent("ac:adminalarm","Mashkuk Be God Mode(Tactical Detection)")
        elseif GetEntityHealth(curPed) == curHealth-2 then
            SetEntityHealth(curPed, GetEntityHealth(curPed)+2)
        end
        if GetPlayerInvincible(PlayerId()) then
            ban("God Mode(FiveM Native)")
			Wait(2000)
        end  
        end
    end
end)

Citizen.CreateThread(function() 
    while true do
	local ped = GetPlayerPed(-1)
	            --armor 200
				local armor = GetPedArmour(Ped)
				if armor > 100 then
				SetPedArmour(Ped,0)
			    ban("Full Armor Cheat(#1)") --Over 100
			    Wait(1000)
			    else
				end
				--armor 99
				local armor = GetPedArmour(Ped)
				if armor >= 99 then
				SetPedArmour(Ped,0)
			    ban('Full Armor Cheat')
				--TriggerServerEvent("ac:adminalarm","Full Armor Cheat")
			    Wait(1000)
			    else
				end
				--Health 200
				if GetEntityHealth(PlayerPedId()) > 200 then
			    ban("Full Health(#1)") --over 100
			    Wait(1000)
			    else
				end
				--anti spect
		        if NetworkIsInSpectatorMode() then
    			ban("Spectator Mode")
				Wait(2000)
                end	
		      	if (GetOnscreenKeyboardResult()) then
                 local result = GetOnscreenKeyboardResult()
                 if result:find('^/e') or result:find('^/f') or result:find('^/d') then
                ban("Use On Screen Keyboard For Cheat")
				Wait(2000)
               end
               end
			
			if IsPedSittingInAnyVehicle(ped) and IsVehicleVisible(GetVehiclePedIsIn(ped)) then
            ban("Use Invisible Vehicle")
            Wait(2000)
            end
		if GetUsingseethrough() and PlayerData.job.name ~= "police" and PlayerData.job.name ~= "government" then
			 ban("Use Thermal Vision")
             Wait(2000)
        end
        if GetUsingnightvision() and PlayerData.job.name ~= "police" and PlayerData.job.name ~= "government" then
           ban("Use Night Vision")
           Wait(2000)
        end
		
		if not IsEntityVisible(ped) and not whitelisted then
                TriggerServerEvent("ac:adminalarm","Mashkuk Be Invisible")
        end        	
		--hash changer
           lsveh = nil
			lsvehent = nil
			local veh = GetVehiclePedIsUsing(ped)
			local vehent = GetEntityModel(veh)
			if IsPedSittingInAnyVehicle(ped) then
				if veh == lsveh and vehent ~= lsvehent and lsvehent ~= nil and lsvehent ~= 0 then
					DeleteVehicle(veh)
					ban("Change Vehicle Hash")
					return
				end
			end;
			lsveh = veh
			lsvehent = vehent 
			------
			--[[if not IsPedInAnyVehicle(ped, 1) then
	if GetEntitySpeed(ped) > 10.0 and not isAdmin and not notsend and not whitelisted and isloaded then
			if not IsPedFalling(ped) then
				TriggerServerEvent("ac:adminalarm","Mashkuk Speed Hack(On Foot)")
			end
		end
	end]]
	--[[commandcountnew = #GetRegisteredCommands()
			if commandcount ~= nil then
				if commandcountnew ~= commandcount then
					ban("Register New Command")
				end
	end]]
        Wait(500)
    end
end)

--[[Citizen.CreateThread(function()
    while true do
	ped = GetPlayerPed(-1)
     local coords = GetEntityCoords(ped)
     Citizen.Wait(2000)
     local coordsTwo = GetEntityCoords(ped)
     local distance = GetDistanceBetweenCoords(coordsTwo, coords)
     local InVehicle = IsPedInAnyVehicle(ped)
     local falling = IsPedFalling(ped)
     local parafall = IsPedInParachuteFreeFall(ped)
     if distance > 15 and ESX.GetPlayerData()['IsPlayerLoaded'] == 1 and ESX.GetPlayerData()['admin'] ~= 1 and not InVehicle and not falling and not parafall and not notsend and isloaded then
       TriggerServerEvent("ac:adminalarm","Mashkuk Teleport Hack Ast!")
     end   
    end
end)]]

Citizen.CreateThread(function()
	while true do
	if not isAdmin then
		SetEntityCanBeDamaged(ped, true)
		SetPedInfiniteAmmoClip(ped, false)
        SetPlayerHealthRechargeMultiplier(playerid, 0.0)
		SetRunSprintMultiplierForPlayer(playerid, 1.0)
		SetPedMoveRateOverride(playerid, 1.0)
		SetSwimMultiplierForPlayer(playerid, 1.0)
        SetEntityProofs(ped, false, true, true, false, false, false, false, false)		
		end
		Citizen.Wait(1)
	end

end)

RegisterNetEvent('sprguard:gunhack')
AddEventHandler('sprguard:gunhack', function(weaponName)
RemoveAllPedWeapons(GetPlayerPed(-1), 1)
TriggerServerEvent("ac:adminalarm","Try To Add Weapon With Cheat Or Glitch : "..weaponName)
end)

RegisterNetEvent('sprguard:gunhack2')
AddEventHandler('sprguard:gunhack2', function(weaponName)
RemoveWeaponFromPed(GetPlayerPed(-1), GetHashKey(weaponName))
end)

RegisterNetEvent('acguard:deletePed')
AddEventHandler('acguard:deletePed', function(ped)

    local ped = NetworkGetEntityFromNetworkId(ped)

    if DoesEntityExist(ped) then

        if not IsPedAPlayer(ped) then
           local model = GetEntityModel(ped)
            --if model ~= GetHashKey('mp_f_freemode_01') and model ~= GetHashKey('mp_m_freemode_01') then
                if IsPedInAnyVehicle(ped) then
                    -- vehicle delete
                    local vehicle = GetVehiclePedIsIn(ped)
                    NetworkRequestControlOfEntity(vehicle)
                    local timeout = 2000
                    while timeout > 0 and not NetworkHasControlOfEntity(vehicle) do
                        Wait(100)
                        timeout = timeout - 100
                    end
                    SetEntityAsMissionEntity(vehicle, true, true)
                    local timeout = 2000
                    while timeout > 0 and not IsEntityAMissionEntity(vehicle) do
                        Wait(100)
                      timeout = timeout - 100
                    end              
                    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle) )
                    DeleteEntity(vehicle)
                    -- ped delete
                    NetworkRequestControlOfEntity(ped)   
                    local timeout = 2000
                    while timeout > 0 and not NetworkHasControlOfEntity(ped) do
                        Wait(100)
                        timeout = timeout - 100
                    end                  
                    DeleteEntity(ped)
                else
                    NetworkRequestControlOfEntity(ped)
                    local timeout = 2000
                    while timeout > 0 and not NetworkHasControlOfEntity(ped) do
                        Wait(100)
                        timeout = timeout - 100
                    end
                    DeleteEntity(ped)

                end    
            --end
         end
   end
end)

RegisterNetEvent('acguard:deleteobj')
AddEventHandler('acguard:deleteobj', function(veh)
    if DoesEntityExist(veh) then
     DeleteEntity(veh)                                    
   end
end)


local Config.WhiteListSkins

function CheckSkin()
	local allowedSkin = false
	local playerPed = PlayerPedId()
	for _,whiteListedSkin in ipaac(WhiteListSkins) do
		if whiteListedSkin == GetEntityModel(playerPed) then
			allowedSkin = true
		end
	end
	if not allowedSkin and not isAdmin then
		ban("Change Player PED(Dont White List Ped)")
		Wait(2000)
	end
	SetTimeout(2000, CheckSkin)
end


AddEventHandler('populationPedCreating', function()
    CancelEvent()
end)

RegisterNetEvent('acguard:deleteOBJ')
AddEventHandler('acguard:deleteOBJ', function(object)
    local object = NetworkGetEntityFromNetworkId(object)
    if DoesEntityExist(object) then
        ESX.Game.DeleteObject(object)
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		for _, weapon in ipaac(BlacklistedWeapons) do
			Wait(1)
			if HasPedGotWeapon(PlayerPedId(),GetHashKey(weapon),false) == 1 then
					 RemoveAllPedWeapons(GetPlayerPed(-1), 1)
					 TriggerServerEvent("ac:adminalarm","Black List Weapon : ".. weapon)
					 ban('Black List Weapon : ' .. weapon)
					 Wait(1000)
					break
			end
		end
	end
end)

--------------------function
function SetPlayerVisible(state)
    whitelisted = not state
    SetEntityVisible(GetPlayerPed(-1), state)
end

function Whitelist(state)
    notsend = state
end


function ban(Reason)
if not isAdmin then
TriggerServerEvent('cheat:banme',Reason)
end
end
	