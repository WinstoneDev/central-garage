ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("garage:getvehs", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll(
		'SELECT * FROM garage WHERE owner = @owner',
		{
			['@owner'] = xPlayer.identifier
		},function(result)
			cb(result)
		end
	)
end)

RegisterNetEvent("garage:updatestate")
AddEventHandler("garage:updatestate", function (state, id)
	MySQL.Sync.execute('UPDATE garage SET stored = @state WHERE id = @id', {
		['@state'] = state,
		['@id'] = id
	})
end)
RegisterNetEvent("garage:updateprops")
AddEventHandler("garage:updateprops", function(id, props)
MySQL.Sync.execute('UPDATE garage SET properties = @properties WHERE id = @id', {
	['@properties'] = props,
	['@id'] = id
})
end)

AddEventHandler('onMySQLReady', function()
	MySQL.Sync.execute("UPDATE garage SET stored=0 WHERE stored=1", {})
end)