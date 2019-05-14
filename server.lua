--Importing API
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy") 
--Importing cfg
--local cfg = module("cfg/drug.lua")
--Timestamps
ts = os.time()
timestamp = os.date('%Y-%m-%d %H:%M:%S', ts)


--mysql database connection
MySQL = module("vrp_mysql", "MySQL")

-- connecting to API
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_dipendenza")

--print start script
print("\n****vRP Drug addiction is Ready (coded by Giorgio Bella)****")
print("****vRP drugs addiction is Ready****\n")
-- MySQL queries
MySQL.createCommand("vRP/create_dipendenza","INSERT INTO vrp_user_dipendenza(user_id, dipendente, lsd_count_taken) VALUES(@user_id, @dipendente, @lsd_taken_count)")
MySQL.createCommand("vRP/check_dipendente","SELECT dipendente FROM  vrp_user_dipendenza WHERE user_id =@users_id ")
MySQL.createCommand("vRP/check_all", "SELECT dipendente, lsd_count_taken, count_med_taken, med_last_taken FROM vrp_user_dipendenza WHERE user_di =@user_id")
MySQL.createCommand("vRP/update_dipendente","UPDATE vrp_user_dipendenza SET dipendente =@dipendente, lsd_count_taken =@lsd_count_taken WHERE user_id=@user_id ")
MySQL.createCommand("vRP/update_count","UPDATE vrp_user_dipendenza SET lsd_count_taken =@lsd_taken_count  WHERE user_id=@user_id ")
MySQL.createCommand("vRP/exit_dipendente","UPDATE vrp_user_dipendenza SET dipendente =@dipendente WHERE user_id=@user_id ")
MySQL.createCommand("vRP/update_med","UPDATE vrp_user_dipendenza SET count_med_taken=@count_med_taken, med_last_taken= @med_last_taken WHERE user_id=@user_id")
MySQL.createCommand("vRP/update_all","UPDATE vrp_user_dipendenza SET lsd_count_taken=@lsd_taken_count , count_med_taken=@count_med_taken, med_last_taken=@med_last_take WHERE user_id= @user_id")

---functions---
function CheckDipendenza(source)
	--print(" ("..u_id..") ")
	print(source)
	local user_id = vRP.getUserId({source})
	--print(u_id)
	MySQL.query("vRP/check_dipendente",{user_id = user_id},function(rows, effected)
		local dipendente = false
		for i,v in ipairs(rows) do
			if v.dipendente == false then
				dipendente = false
			else
				dipendente = true
			end
		end
		return dipendente
	end)
end

function AddLsdCount(user_id,lsd_taken_count)
	MySQL.execute("vRP/update_count",{lsd_count_taken = lsd_taken_count})
	print('[vRP Drug Addiction]User '..user_id..' has taken lsd for '.. lsd_taken_count..'')
	TriggerClientEvent("lsd:check") --TriggerClientEvent loop 
end

function UpdateDipendenza(user_id,dipendente,lsd_taken_count)
	MySQL.execute("vRP/update_dipendente",{dipendente = dipendente, lsd_count_taken =  lsd_taken_count})
	print('[vRP Drug Addiction]User '..user_id..' has taken lsd for '.. lsd_taken_count..'')
	TriggerClientEvent("lsd:check")
end
--END FUNCTIONS

-- Called when the effect of the drug is vanished and you are starting to get addidcted
RegisterServerEvent('lsd:taken')
AddEventHandler('lsd:taken', function()
	--initialize vars
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({source})
	lsd_takent_count = 0
	dipendente = false
	--check if the user has taken the lsd before
	MySQL.query("vRP/check_dipendente",{user_id = user_id},function(rows,effected)
		if #rows < 0 then
			local lsd_taken_count = 1
			local dipendente = true
			MySQL.query("vRP/create_dipenza",{user_id = user_id, dipendente = dipendente, lsd_count_taken = lsd_count_taken},function(rows,effected)
				if	#rows > 0 then
					print('[vRP Drug Addiction]User '..user_id..' has taken lsd for the first time')
					 TriggerClientEvent("lsd:check")
				end
			end)
		else
			for k,v in pairs(rows) do
				if v.dipendente == false then
					lsd_taken_count = v.lsd_count_taken + 1
					dipendente = true
					UpdateDipendenza(user_id,dipendente,lsd_taken_count)
				else
					lsd_taken_count = v.lsd_count_taken +1
					AddLsdCount(user_id,lsd_taken_count)
				end
			end
		end
	end)
end)

--called from client
RegisterServerEvent("lsd:servercheck")
AddEventHandler("lsd:servercheck", function(user_id,player)
	dipendente = CheckDipendenza(source)
	TriggerClientEvent("lsd:getresponse", user_id, palyer, dipendente)
end)

-- Event to chek and free from addiction called from item function 
RegisterServerEvent("lsd:free")
AddEventHandler("lsd:free", function(user_id,player)
	MySQL.query("vRP/check_all",{user_id = user_di},function(rows,effected)
		if #rows > 0 then
			for i,v in ipairs(rows) do
				if v.dipendente == true then
					local dipendente = false
					-- Handle the exit from addiction based on How many times a user have used lsd
					if v.lsd_count_taken <= 10 then
						if v.count_med_taken == 5 then
							MySQL.query("vRP/exit_dipendente",{dipendente=dipendente,user_id=user_id},function(rows, effected)
								if effected ~= nil then
									vRPclient.notify(player,{"Ooo... Finalmente ho finito il trattamento è sono li bero dalla droga"})
									TriggerClientEvent("lsd:setnotaddicted",player)
								end
							end)
						else
							 local count_med_taken = v.count_med_taken +1
							MySQL.query("vRP/update_med",{count_med_taken= count_med_taken, med_last_taken= timestamp,user_id=user_id}, function(rows, effected)
								if effected ~= nil then 
									vRPclient.notify(player,{"Sei un passo piu' vicino alla fine della terapia!"})
								end
							end)
						end  
					elseif v.lsd_count_taken <= 20 then
						if v.count_med_taken == 10 then
								MySQL.query("vRP/exit_dipendente",{dipendente=dipendente,user_id=user_id},function(rows, effected)
								if effected ~= nil then
									vRPclient.notify(player,{"Ooo... Finalmente ho finito il trattamento è sono li bero dalla droga"})
									TriggerClientEvent("lsd:setnotaddicted",player)
								end
							end)
						else
							 local count_med_taken = v.count_med_taken +1
							MySQL.query("vRP/update_med",{count_med_taken= count_med_taken, med_last_taken= timestamp, user_id=user_id}, function(rows, effected)
								if effected ~= nil then 
									vRPclient.notify(player,{"Sei un passo piu' vicino alla fine della terapia!"})
								end
							end)
						end
					elseif v.lsd_count_taken <= 40 then
						if v.count_med_taken == 20 then
							MySQL.query("vRP/exit_dipendente",{dipendente=dipendente,user_id=user_id},function(rows, effected)
								if effected ~= nil then
									vRPclient.notify(player,{"Ooo... Finalmente ho finito il trattamento è sono li bero dalla droga"})
									TriggerClientEvent("lsd:setnotaddicted",player)
								end
							end)
						else
							 local count_med_taken = v.count_med_taken +1
							MySQL.query("vRP/update_med",{count_med_taken= count_med_taken, med_last_taken= timestamp,user_id=user_id}, function(rows, effected)
								if effected ~= nil then 
									vRPclient.notify(player,{"Sei un passo piu' vicino alla fine della terapia!"})
								end
							end)
						end
					elseif v.lsd_count_taken <= 60 then
						if v.count_med_taken == 40 then
							MySQL.query("vRP/exit_dipendente",{dipendente=dipendente,user_id=user_id},function(rows, effected)
								if effected ~= nil then
									vRPclient.notify(player,{"Ooo... Finalmente ho finito il trattamento è sono li bero dalla droga"})
									TriggerClientEvent("lsd:setnotaddicted",player)
								end
							end)
						else
							 local count_med_taken = v.count_med_taken +1
							MySQL.query("vRP/update_med",{count_med_taken= count_med_taken, med_last_taken= timestamp,user_id=user_id}, function(rows, effected)
								if effected ~= nil then 
									vRPclient.notify(player,{"Sei un passo piu' vicino alla fine della terapia!"})
								end
							end)
						end
					elseif v.lsd_count_taken <= 80 then
						if v.count_med_taken == 60 then
							MySQL.query("vRP/exit_dipendente",{dipendente=dipendente,user_id=user_id},function(rows, effected)
								if effected ~= nil then
									vRPclient.notify(player,{"Ooo... Finalmente ho finito il trattamento è sono li bero dalla droga"})
									TriggerClientEvent("lsd:setnotaddicted",player)
								end
							end)
						else
							 local count_med_taken = v.count_med_taken +1
							MySQL.query("vRP/update_med",{count_med_taken= count_med_taken, med_last_taken= timestamp,user_id=user_id}, function(rows, effected)
								if effected ~= nil then 
									vRPclient.notify(player,{"Sei un passo piu' vicino alla fine della terapia!"})
								end
							end)
						end
					else
						if v.count_med_taken == 80 then
							MySQL.query("vRP/exit_dipendente",{dipendente=dipendente,user_id=user_id},function(rows,effected)
								if effected ~= nil then 
									MySQL.query("vRP/update_all",{lsd_count_taken=0,med_last_taken=0,med_last_taken= timestamp,user_id=user_id},function (rows,effected)
										if effected ~=nil then
											vRPclient.notify(player,{"Ooo... Finalmente ho finito il trattamento è sono li bero dalla droga"})
											TriggerClientEvent("lsd:setnotaddicted",player)
										end
									end)
								end
							end)
						else
							 local count_med_taken = v.count_med_taken +1
							MySQL.query("vRP/update_med",{count_med_taken= count_med_taken, med_last_taken= timestamp,user_id=user_id}, function(rows, effected)
								if effected ~= nil then 
									vRPclient.notify(player,{"Sei un passo piu' vicino alla fine della terapia!"})
								end
							end)
						end
					end
				end
			end
		end 
	end)
end)

-- Handling the player playerSpawn Event
AddEventHandler("vRP:playerSpawn",function(user_id,source)
	--Call the function
	print(user_id)
	local dipendente = CheckDipendenza(source)
	if dipendente == true then
		vRP.addUserGroup(user_id, "Tossico")
	elseif dipendente == false then
		-- if from the check the user is not toxic but have the group we remove it 
		if vRP.hasGroup(user_id,"Tossico") then
			vRP.removeUserGroup(user_id,"Tossico")
		end
	end
end)