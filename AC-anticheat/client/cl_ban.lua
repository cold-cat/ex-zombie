RegisterNetEvent('BanSql:Respond')
AddEventHandler('BanSql:Respond', function()
	TriggerServerEvent("BanSql:CheckMe")
end)
--[[RegisterNetEvent('ban:plsban')
AddEventHandler('ban:plsban', function(ress)
	TriggerServerEvent('ban:banserver', ress)
end)]]