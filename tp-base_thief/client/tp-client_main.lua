ESX = nil
local OpenedStealMenu = false

local currentSourceTarget = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	TriggerServerEvent('tp-base_thief:removePlayer')
end)

function IsAbleToSteal(targetSID, err)
	ESX.TriggerServerCallback('tp-base_thief:getValue', function(result)
		local result = result
		if result.value then
			err(false)
		else
			err(Locales['no_hands_up'])
		end
	end, targetSID)
end

function OpenStealMenu(target_id)
	ESX.UI.Menu.CloseAll()

	currentSourceTarget = target_id

	ESX.TriggerServerCallback('tp-base_thief:getThiefPlace', function(occupied)
		if occupied then
			TriggerEvent('tp-base:sendNotification', Locale['another_player'], "error")
		else

			ESX.TriggerServerCallback("tp-base_thief:getPlayerInventory",function(data)

				items = {}
				inventory = data.inventory
				money = data.money
				black_money     = data.black_money

				weapons = data.weapons
				DisableControlAction(0, 57)
				
				if money ~= nil and money > 0 then
					moneyData = {
						label = "Cash",
						name = "cash",
						type = "item_money",
						count = money,
						usable = false,
						rare = false,
						limit = -1,
						canRemove = true
					}
	
					table.insert(items, moneyData)
				end

				if black_money > 0 then

					blackMoneyData = {
						label = "Black Money",
						name = "black_money",
						type = "item_black_money",
						count = black_money,
						usable = false,
						rare = false,
						limit = -1,
						canRemove = true
					}
			
					table.insert(items, blackMoneyData)
				end
	
				if inventory ~= nil then
					for key, value in pairs(inventory) do
						if inventory[key].count <= 0 then
							inventory[key] = nil
						else
							inventory[key].type = "item_standard"
							table.insert(items, inventory[key])
						end
					end
				end
	
				if weapons ~= nil then
					for key, value in pairs(weapons) do
						local weaponHash = GetHashKey(weapons[key].name)
						local playerPed = PlayerPedId()
						-- if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= "WEAPON_UNARMED" then
						if weapons[key].name ~= "WEAPON_UNARMED" then
							local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
	
							local weaponLabel = weapons[key].label
	
							if Config.WeaponLabelNames[weapons[key].name] then
								weaponLabel = Config.WeaponLabelNames[weapons[key].name]
							end
	
							table.insert(
								items,
								{
									label = weaponLabel,
									count = ammo,
									limit = -1,
									type = "item_weapon",
									name = weapons[key].name,
									usable = false,
									rare = false,
									canRemove = true
								}
							)
						end
					end
				end

				TriggerEvent("tp-base:openSecondInventory", "thief", items, "Second Player Inventory", true, target_id)

			end, target_id)

		end

	end, target_id)
end


RegisterNetEvent("tp-base_thief:onThiefInventoryUpdate")
AddEventHandler("tp-base_thief:onThiefInventoryUpdate", function()

	ESX.TriggerServerCallback("tp-base_thief:getPlayerInventory",function(data)

		items = {}
		inventory = data.inventory
		money = data.money
		black_money     = data.black_money

		weapons = data.weapons
		DisableControlAction(0, 57)
		
		if money ~= nil and money > 0 then
			moneyData = {
				label = "Cash",
				name = "cash",
				type = "item_money",
				count = money,
				usable = false,
				rare = false,
				limit = -1,
				canRemove = true
			}

			table.insert(items, moneyData)
		end

		if black_money > 0 then

			blackMoneyData = {
				label = "Black Money",
				name = "black_money",
				type = "item_black_money",
				count = black_money,
				usable = false,
				rare = false,
				limit = -1,
				canRemove = true
			}
	
			table.insert(items, blackMoneyData)
		end

		if inventory ~= nil then
			for key, value in pairs(inventory) do
				if inventory[key].count <= 0 then
					inventory[key] = nil
				else
					inventory[key].type = "item_standard"
					table.insert(items, inventory[key])
				end
			end
		end

		if weapons ~= nil then
			for key, value in pairs(weapons) do
				local weaponHash = GetHashKey(weapons[key].name)
				local playerPed = PlayerPedId()
				-- if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= "WEAPON_UNARMED" then
				if weapons[key].name ~= "WEAPON_UNARMED" then
					local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

					local weaponLabel = weapons[key].label

					if Config.WeaponLabelNames[weapons[key].name] then
						weaponLabel = Config.WeaponLabelNames[weapons[key].name]
					end

					table.insert(
						items,
						{
							label = weaponLabel,
							count = ammo,
							limit = -1,
							type = "item_weapon",
							name = weapons[key].name,
							usable = false,
							rare = false,
							canRemove = true
						}
					)
				end
			end
		end

		TriggerEvent('tp-base:refreshSecondInventory', "thief", items, "Second Player Inventory", true, currentSourceTarget)

	end, currentSourceTarget)


end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local ped = PlayerPedId()

		if IsPedArmed(ped, 7) and not IsEntityDead(ped) and IsPedOnFoot(ped) then

			if IsControlJustPressed(0, 74) then
				local target, distance = ESX.Game.GetClosestPlayer()
	
				if target ~= -1 and distance ~= -1 and distance <= 2.0 then
					local target_id = GetPlayerServerId(target)
					
					IsAbleToSteal(target_id, function(err)
						if(not err)then
	
							OpenStealMenu(target_id)
						else
							TriggerEvent('tp-base:sendNotification', err, "error")
						end
					end)
				elseif distance < 20 and distance > 2.0 then
					TriggerEvent('tp-base:sendNotification', Locales['too_far'], "error")
				end
			end
		else
			Citizen.Wait(1000)
		end
	end
end)
