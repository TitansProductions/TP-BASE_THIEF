ESX = nil
local stealingUsers = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('tp-base_thief:update')
AddEventHandler('tp-base_thief:update', function(bool)
	local _source = source
	stealingUsers[_source] = {value = bool, time = os.time()}
end)

RegisterServerEvent('tp-base_thief:getValue')
AddEventHandler('tp-base_thief:getValue', function(targetSID)
	local _source = source
	if stealingUsers[targetSID] then
		TriggerClientEvent('tp-base_thief:returnValue', _source, stealingUsers[targetSID])
	else
		TriggerClientEvent('tp-base_thief:returnValue', _source, stealingUsers[targetSID])
	end
end)



RegisterServerEvent("tp-base:PutIntoSecondInventory")
AddEventHandler("tp-base:PutIntoSecondInventory", function(inventoryType, hasTargetSource, targetSource, type, itemName, itemCount, clickedItemCount)
	local _source = source

	if inventoryType == "thief" then
	
		local xPlayer = ESX.GetPlayerFromId(_source)
		local targetXPlayer = ESX.GetPlayerFromId(targetSource)

		if type == "item_standard" then
	
			local targetItem = xPlayer.getInventoryItem(itemName)
	
			if itemCount > 0 and clickedItemCount >= itemCount then
	
				xPlayer.removeInventoryItem(itemName, itemCount)
				targetXPlayer.addInventoryItem(itemName, itemCount)
	
				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)

			else
	
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
			end
	
		elseif type == "item_money" then
			if itemCount > 0 and clickedItemCount >= itemCount then
	
				targetXPlayer.addMoney(itemCount)
				xPlayer.removeMoney(itemCount)

				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)

			else
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
	
			end
		elseif type == "item_black_money" then

			if itemCount > 0 and clickedItemCount >= itemCount then
	
				targetXPlayer.addAccountMoney("black_money", itemCount)
				xPlayer.removeAccountMoney("black_money", itemCount)

				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)

			else
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
			end
		elseif type == "item_weapon" then
			if not targetXPlayer.hasWeapon(itemName) then
	
				targetXPlayer.addWeapon(itemName, itemCount)
				xPlayer.removeWeapon(itemName)

				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)
			else
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['already_carrying'], "error")
			end
		end

	end

end)


RegisterServerEvent("tp-base:TakeFromSecondInventory")
AddEventHandler("tp-base:TakeFromSecondInventory", function(inventoryType, hasTargetSource, targetSource, type, itemName, itemCount, clickedItemCount)
	local _source = source

	if inventoryType == "thief" then
	
		local xPlayer = ESX.GetPlayerFromId(_source)
		local targetXPlayer = ESX.GetPlayerFromId(targetSource)

		if type == "item_standard" then
	
			local targetItem = targetXPlayer.getInventoryItem(itemName)
	
			if itemCount > 0 and clickedItemCount >= itemCount then
	
				targetXPlayer.removeInventoryItem(itemName, itemCount)
				xPlayer.addInventoryItem(itemName, itemCount)

				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)
	
			else
	
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
			end
	
		elseif type == "item_money" then
			if itemCount > 0 and clickedItemCount >= itemCount then
	
				targetXPlayer.removeMoney(itemCount)
				xPlayer.addMoney(itemCount)

				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)

			else
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
	
			end
		elseif type == "item_black_money" then

			if itemCount > 0 and clickedItemCount >= itemCount then
	
				targetXPlayer.removeAccountMoney("black_money", itemCount)
				xPlayer.addAccountMoney("black_money", itemCount)

				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)

			else
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['permitted_amount_warning'], "error")
			end
		elseif type == "item_weapon" then
			if not xPlayer.hasWeapon(itemName) then
	
				targetXPlayer.removeWeapon(itemName)
				xPlayer.addWeapon(itemName, itemCount)
	
				TriggerClientEvent("tp-base_thief:onThiefInventoryUpdate", _source)

			else
				TriggerClientEvent('tp-base:sendNotification', _source, Locales['already_carrying'], "error")
			end
		end

	end

end)

ESX.RegisterServerCallback('tp-base_thief:getValue', function(source, cb, targetSID)
	if stealingUsers[targetSID] then
		cb(stealingUsers[targetSID])
	else
		cb({value = false, time = 0})
	end
end)


ESX.RegisterServerCallback('tp-base_thief:getThiefPlace', function(source, cb, id)
	local found = false

	for i=1, #stealingUsers, 1 do
		if stealingUsers[i] == id then
			found = true
		end
	end
	cb(found)
end)

ESX.RegisterServerCallback("tp-base_thief:getPlayerInventory", function(source, cb, target)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if targetXPlayer ~= nil then
		cb({name = GetPlayerName(target), inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), black_money = targetXPlayer.getAccount('black_money').money, weapons = targetXPlayer.loadout})
	else
		cb(nil)
	end
end)