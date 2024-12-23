if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
else
    ESX = exports['es_extended']:getSharedObject()
end

local function getPlayerObject(src) -- Get the player object
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(src)
    end
end

function DebugPrint(...)
    if Config.DebugMode then
        print(...)
    end
end

local function TakeMoney(playerObject, method, amount) -- Take money from the player
    amount = tonumber(amount)

    if Config.Framework == 'qb' then
        return playerObject.Functions.RemoveMoney(method, amount)
    elseif Config.Framework == 'esx' then
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
    end

    return false
end

local function giveItem(src, playerObject, item, amount) -- Give the item to the player
    if Config.Framework == 'qb' then
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
    elseif Config.Framework == 'esx' then
        if Config.Inventory == 'qs' then
            exports['qs-inventory']:AddItem(src, item.name, amount)
        elseif Config.Inventory == 'ox' then
            exports.ox_inventory:AddItem(src, item.name, amount)
        else
            playerObject.addInventoryItem(item.name, amount)
        end
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
        TriggerClientEvent('muhaddil-machines:Notify', src, '', 'No tienes suficiente dinero.', 'error')
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

RegisterNetEvent('muhaddil-machines:buy', function(sourceType, sourceName, itemName, cantidad) -- Event for buying the item
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
        TriggerClientEvent('muhaddil-machines:Notify', src, '', 'El tipo de origen no es válido.', 'error')
        return
    end

    local item = findItemInSource(sourceData, itemName)
    if item then
        local totalPrice = item.price * cantidad
        handlePurchase(src, player, item, sourceName, totalPrice, cantidad)
    else
        TriggerClientEvent('muhaddil-machines:Notify', src, '', 'El artículo no está disponible', 'error')
    end
end)

RegisterServerEvent('muhaddil-machines:RemoveThirst') -- Event for the watercoolers to remove thirst
AddEventHandler('muhaddil-machines:RemoveThirst', function()
    local src = source
    
    if Config.Framework == 'qb' then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            local currentThirst = player.PlayerData.metadata['thirst'] or 0
            if currentThirst < 100 then
                local newThirst = math.min(currentThirst + Config.ThirstRemoval, 100)
                player.Functions.SetMetaData('thirst', newThirst)
                
                TriggerClientEvent('hud:client:UpdateNeeds', src, player.PlayerData.metadata.hunger or 50, newThirst)
            else
                print("[Info] El jugador " .. src .. " ya tiene la sed máxima (100).")
            end
        else
            print("[Error] No se pudo obtener el jugador para src: " .. tostring(src))
        end

    elseif Config.Framework == 'esx' then
        TriggerClientEvent('esx_status:add', src, 'thirst', Config.ThirstRemoval)
    else
        print("[Error] Configuración de framework no válida.")
    end
end)
