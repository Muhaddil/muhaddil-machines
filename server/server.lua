local framework = Config.Framework

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

function InitFramework()
    if framework == "auto" then
        if exports['es_extended'] then
            DebugPrint('ESX Loaded')
            framework = "esx"
        elseif exports['qb-core'] then
            DebugPrint('QB Loaded')
            framework = "qb"
        elseif pcall(require, '@ox_core.lib.init') then
            DebugPrint('OX Loaded')
            framework = "ox"
        else
            DebugPrint('Fallback Loaded')
            framework = "esx"
        end
    end

    if framework == "esx" then
        ESX = exports['es_extended']:getSharedObject()
    elseif framework == "qb" then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif framework == "ox" then
        Ox = require '@ox_core.lib.init'
    else
        ESX = exports['es_extended']:getSharedObject() -- fallback
    end

    return framework
end

InitFramework()

local function getPlayerObject(src) -- Get the player object
    if framework == 'qb' then
        return QBCore.Functions.GetPlayer(src)
    elseif framework == 'esx' then
        return ESX.GetPlayerFromId(src)
    elseif framework == 'ox' then
        return Ox.GetPlayer(src)
    end
end

lib.locale()

local function TakeMoney(playerObject, method, amount) -- Take money from the player
    amount = tonumber(amount)

    if framework == 'qb' then
        return playerObject.Functions.RemoveMoney(method, amount)
    elseif framework == 'esx' then
        if method == 'cash' then
            if playerObject.getMoney() >= amount then
                playerObject.removeMoney(amount)
                return true
            end
        elseif method == 'bank' then
            if playerObject.getAccount('bank').money >= amount then
                playerObject.removeAccountMoney('bank', amount)
                return true
            end
        end
    elseif framework == 'ox' then
        if exports.ox_inventory:GetItemCount(source, 'money') >= amount then
            exports.ox_inventory:RemoveItem(source, 'money', amount)
            return true
        end
    end

    return false
end

local function giveItem(src, playerObject, item, amount) -- Give the item to the player
    if framework == 'qb' then
        if Config.Inventory == 'qs' then
            exports['qs-inventory']:AddItem(src, item.name, amount)
        elseif Config.Inventory == 'ox' then
            exports.ox_inventory:AddItem(src, item.name, amount)
        else
            if Config.NewQBInventory then
                exports['qb-inventory']:AddItem(source, item.name, amount, false, false, 'Machines')
            else
                playerObject.Functions.AddItem(item.name, amount)
            end
        end
    elseif framework == 'esx' then
        if Config.Inventory == 'qs' then
            exports['qs-inventory']:AddItem(src, item.name, amount)
        elseif Config.Inventory == 'ox' then
            exports.ox_inventory:AddItem(src, item.name, amount)
        else
            playerObject.addInventoryItem(item.name, amount)
        end
    elseif framework == 'ox' then
        exports.ox_inventory:AddItem(source, item.name, amount)
    end
end

local function handlePurchase(src, player, item, machineName, totalPrice, cantidad) -- Handle the purchase
    local success = false

    if TakeMoney(player, 'cash', totalPrice) then
        success = true
    elseif TakeMoney(player, 'bank', totalPrice) then
        success = true
    end

    if success then
        giveItem(src, player, item, cantidad)
    else
        TriggerClientEvent('muhaddil-machines:Notify', src, '', locale('no_money'), 'error')
    end
end

local function findItemInSource(sourceData, itemName) -- Find the item in the source data
    for _, item in ipairs(sourceData.items) do
        if item.name == itemName then
            return item
        end
    end
    return nil
end

RegisterNetEvent('muhaddil-machines:buy',
    function(sourceType, sourceName, itemName, cantidad) -- Event for buying the item
        local src = source
        local player = getPlayerObject(src)

        local sourceData
        if sourceType == 'machine' then
            sourceData = Config.machines[sourceName]
        elseif sourceType == 'stand' then
            sourceData = Config.Stands[sourceName]
        elseif sourceType == 'news' then
            sourceData = Config.NewsSellers[sourceName]
        else
            TriggerClientEvent('muhaddil-machines:Notify', src, '', locale('invalid_source_type'), 'error')
            return
        end

        local item = findItemInSource(sourceData, itemName)
        if item then
            local totalPrice = item.price * cantidad
            handlePurchase(src, player, item, sourceName, totalPrice, cantidad)
        else
            TriggerClientEvent('muhaddil-machines:Notify', src, '', locale('item_not_available'), 'error')
        end
    end)

RegisterServerEvent('muhaddil-machines:RemoveThirst') -- Event for the watercoolers to remove thirst
AddEventHandler('muhaddil-machines:RemoveThirst', function()
    local src = source

    if framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            local currentThirst = player.PlayerData.metadata['thirst'] or 0
            if currentThirst < 100 then
                local newThirst = math.min(currentThirst + Config.ThirstRemoval, 100)
                player.Functions.SetMetaData('thirst', newThirst)

                TriggerClientEvent('hud:client:UpdateNeeds', src, player.PlayerData.metadata.hunger or 50, newThirst)
            else
                print(locale('player_max_thirst', src))
            end
        else
            print(locale('player_not_found', tostring(src)))
        end
    elseif framework == 'esx' then
        TriggerClientEvent('esx_status:add', src, 'thirst', Config.ThirstRemoval)
    elseif framework == 'ox' then
        local player = Ox.GetPlayer(src)
        local beforeStatus = player.getStatus('thirst')
        player.removeStatus('thirst', Config.ThirstRemoval)
        local afterStatus = player.getStatus('thirst')
        DebugPrint(locale('player_thirst_info', src, beforeStatus, afterStatus))
        local statuses = player.getStatuses()
        DebugPrint(locale('player_statuses', src, json.encode(statuses)))
    else
        print(locale('invalid_framework'))
    end
end)