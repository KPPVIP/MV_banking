ESX = nil
local PlayerData = {}
local bankMenu = true
local keys = {
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

function playAnim(animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setFrak')
AddEventHandler('esx:setFrak', function(frak)
	ESX.PlayerData.frak = frak
end)

RegisterNetEvent('esx:setFrakrank')
AddEventHandler('esx:setFrakrank', function(frakrank)
	ESX.PlayerData.frakrank = frakrank
end)

RegisterNetEvent('esx:setLevel')
AddEventHandler('esx:setLevel', function(level)
	ESX.PlayerData.level = level
end)

RegisterNetEvent('esx:setRP')
AddEventHandler('esx:setRP', function(rp)
	ESX.PlayerData.rp = rp
end)

local enableField = false

function toggleField(enable)
    SetNuiFocus(enable, enable)
    enableField = enable

    if enable then
        SendNUIMessage({
            action = 'open'
        }) 
    else
        SendNUIMessage({
            action = 'close'
        }) 
    end
end

AddEventHandler('onResourceStart', function(name)
    if GetCurrentResourceName() ~= name then
        return
    end

    toggleField(false)
end)

RegisterNetEvent('currentbalance1')
AddEventHandler('currentbalance1', function(balance,namee)
	local id = PlayerId()
	local playerName = GetPlayerName(id)

	SendNUIMessage({
		action = "setKontostand",
		bank = balance
		})
		
	SendNUIMessage({
		action = "setName",
		name = namee
		})	
end)

RegisterNUICallback('Exit', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)

    cb('ok')
end)

RegisterNUICallback('Einzahlen', function(data, cb)
	TriggerServerEvent('Jason_Bank:deposit', tonumber(data.amount))
	TriggerServerEvent('Jason_Bank:balance')
    cb('ok')
end)

RegisterNUICallback('Auszahlen', function(data, cb)
	TriggerServerEvent('Jason_Bank:withdraw', tonumber(data.amount))
	TriggerServerEvent('Jason_Bank:balance')
    cb('ok')
end)

RegisterNUICallback('Ueberweisen', function(data, cb)
	TriggerServerEvent('Jason_Bank:transfer', data.id, data.amount)
	TriggerServerEvent('Jason_Bank:balance')
    cb('ok')
end)


--===============================================
--==             Core Threading                ==
--===============================================
if bankMenu then
	Citizen.CreateThread(function()
		while true do
			local sleep = 500
			if nearBank() or nearATM() then
				sleep = 4
				if IsControlJustPressed(1, keys[Config.Keys.Open]) then
					toggleField(true)
					TriggerServerEvent('Jason_Bank:balance')
					local ped = GetPlayerPed(-1)
				end
			end

			if IsControlJustPressed(1, keys[Config.Keys.Close]) then
				if nearBank() or nearATM() then
					toggleField(false)
				end
			end
			Citizen.Wait(sleep)
		end
	end)
end

--BANK
Citizen.CreateThread(function()
	if Config.ShowBlips then
	  for k,v in ipairs(Config.Bank)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite (blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.9)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Bank")
		EndTextCommandSetBlipName(blip)
	  end
	end
end)

--ATM
Citizen.CreateThread(function()
	if Config.ShowBlips and Config.OnlyBank == false then
	  for k,v in ipairs(Config.ATM)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite (blip, v.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.9)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("ATM")
		EndTextCommandSetBlipName(blip)
	  end
	end
end)

function nearBank()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)

	for _, search in pairs(Config.Bank) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)

		if distance <= 3 then
			return true
		end
	end
end

function nearATM()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)

	for _, search in pairs(Config.ATM) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)

		if distance <= 2 then
			return true
		end
	end
end


