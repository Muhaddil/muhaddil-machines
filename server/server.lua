if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
else
    ESX = exports['es_extended']:getSharedObject()
end

local function getPlayerObject(src)
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

local function TakeMoney(playerObject, method, amount)
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

local function giveItem(src, playerObject, item, amount)
    if Config.Framework == 'qb' then
        return playerObject.Functions.AddItem(item.name, amount, false)
    elseif Config.Framework == 'esx' then
        DebugPrint('Give item ' .. item.name .. ' to player ' .. src)
        return exports.ox_inventory:AddItem(src, item.name, amount)
    end
end

local function handlePurchase(src, player, item, machineName, totalPrice, cantidad)
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

local function findItemInSource(sourceData, itemName)
    for _, item in ipairs(sourceData.items) do
        if item.name == itemName then
            return item
        end
    end
    return nil
end

RegisterNetEvent('muhaddil-machines:buy', function(sourceType, sourceName, itemName, cantidad)
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

RegisterServerEvent('muhaddil-machines:RemoveThirst')
AddEventHandler('muhaddil-machines:RemoveThirst', function()
	TriggerClientEvent('esx_status:add', source, 'thirst', Config.ThirstRemoval)
end)