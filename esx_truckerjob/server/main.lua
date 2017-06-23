RegisterServerEvent('esx_truckerjob:requestPlayerData')
AddEventHandler('esx_truckerjob:requestPlayerData', function(reason)
	TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)
		TriggerEvent('esx_skin:requestPlayerSkinInfosCb', source, function(skin, jobSkin)

			local data = {
				job       = xPlayer.job,
				inventory = xPlayer.inventory,
				skin      = skin
			}

			TriggerClientEvent('esx_truckerjob:responsePlayerData', source, data, reason)
		end)
	end)
end)

RegisterServerEvent('esx_truckerjob:pay')
AddEventHandler('esx_truckerjob:pay', function(amount)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		user:addMoney((amount))
	end)
end)
