-- Set proxy Interface
vRP = Proxy.getInterface("vRP")

-- gloabal vars
is_addicted = ''
player = ''
user_id = '' 
---end gloabal vars 

function SetEntityAddicted()
	RequestAnimSet("move_m@injured")
	SetPedMovementClipset(GetPlayerPed(-1), "move_m@injured", true)
end

function  SetEntityNotAddicted()
	RequestAnimSet("move_m@generic")
	SetPedMovementClipset(GetPlayerPed(-1), "move_m@generic", true)
end

RegisterNetEvent("lsd:setnotaddicted")
AddEventHandler("lsd:setnotaddicted",function(player)
	--stop injured walk after the lsd:free event fire 
	SetEntityNotAddicted()
	vRPclient.notify(player,{"Mi sto sentendo meglio sto riprendendo le mie capacità motorie"})
end)

--Sever event to called only when user take drugs
RegisterNetEvent('lsd:check')
AddEventHandler('lsd:check', function (user_id,player)
	TriggerServerEvent('lsd:servercheck', user_id, player)
	RegisterNetEvent('lsd:getresponse') -- Getting response from server
	AddEventHandler('lsd:getresponse',function(user_id, player , dipendente)
		--updating global var 
		is_addicted = dipendente 
		player = player
		user_id = user_id
	end)
end)

RegisterNetEvent('lsd:trcreate')
AddEventHandler('lsd:trcreate', function(player)
	TriggerServerEvent('lsd:taken')
end)

RegisterNetEvent('lsd:metataken')
AddEventHandler('lsd:metataken',function(player)
	TriggerServerEvent('lsd:free')
end)
--free player from addiction

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if is_addicted == true and player ~= nil then
			--Make life difficult 
			Citizen.Wait(10000)
				StartScreenEffect("DrugsDrivingIn",30000)
			--Animation stop after a player complete is medical plan 
			SetEntityAddicted()
		elseif is_addicted == false then
			--print("sono im loop")
			SetEntityNotAddicted()
		end
	end
end)

