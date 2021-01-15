ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Text               = {}
local lastduree          = ""
local lasttarget         = ""
local ac_banlist            = {}
local ac_banlistHistory     = {}
local test = true
local ac_banlistHistoryLoad = false
Text = Config.TextEn

AddEventHandler(
  "onMySQLReady",
  function()
	loadac_banlist()
  end
)

CreateThread(function()
	while Config.MultiServerSync do
		Wait(1000*60*10)
		MySQL.Async.fetchAll(
		'SELECT * FROM ac_banlist',
		{},
		function (data)
			if #data ~= #ac_banlist then
			  ac_banlist = {}

			  for i=1, #data, 1 do
				table.insert(ac_banlist, {
					name 	   = data[i].targetplayername,
					identifier = data[i].identifier,
					license    = data[i].license,
					liveid     = data[i].liveid,
					xblid      = data[i].xblid,
					discord    = data[i].discord,
					playerip   = data[i].playerip,
					reason     = data[i].reason,
					added      = data[i].added,
					expiration = data[i].expiration,
					permanent  = data[i].permanent
				  })
			  end
			-- loadac_banlistHistory()
			TriggerClientEvent('BanSql:Respond', -1)
			end
		end
		)
	end
end)

TriggerEvent('es:addAdminCommand', 'banreload', 13, function (source)
	loadac_banlist()
	TriggerEvent('bansql:sendMessage', source, Text.ac_banlistloaded)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM ', 'Insufficient Permissions.' } })
end, {help = Text.reload})

TriggerEvent('es:addAdminCommand', 'unban', 11, function (source, args, user)
	if args[1] and string.find(args[1], "steam:") == 1 then
		local steamHex = args[1]
		MySQL.Async.fetchAll('SELECT * FROM ac_banlist WHERE identifier = @steamHex',
		{
			['@steamHex'] = steamHex
		}, function(result)
			if result ~= nil then
				local data = result[1] 
				deletebanned(steamHex)
				TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban', ' ^2' .. data.targetplayername .. ' ^0Ba Movafaqiyat Unban Shod' } })
				if Config.EnableDiscordLink then
					local sourceplayername = GetPlayerName(source)
					local message = (data.targetplayername .. _U('was_unbanned') .." ".. _U('by') .." ".. sourceplayername)
					sendToDiscord(Config.webhookunban, "BanSql", message, Config.green)
				end
			else
				TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban', ' In Player Dar Database Mojod Nemibashad' } })
			end
		end)
	else
		TriggerEvent('bansql:sendMessage', source, 'Lotfan Steam Hex ra Kamel vared konid (Example: steam:11000013c89a949')
	end
end, {help = 'UnBan Kardan' ,params = {{name = "steamid", help = 'Steam HEX Taraf'}}})

TriggerEvent('es:addAdminCommand', 'ban', 7, function (source, args, user)
 local xPlayer = ESX.GetPlayerFromId(source)
 if xPlayer.permission_level >= 2 and xPlayer.admin then

	local identifier
	local license
	local liveid    = "no info"
	local xblid     = "no info"
	local discord   = "no info"
	local playerip
	local target    = tonumber(args[1])
	local duree     = tonumber(args[2])
	local reason    = table.concat(args, " ",3)
 if ESX.GetPlayerFromId(target).permission_level > xPlayer.permission_level then TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban System :', '^2 Admin Rank Balataro Ban Mikoni? Bayad Bokhorish :|' } }) return end
	if args[1] then		
		if reason == "" then
			reason = 'Shoma Ban Shodid, Baray Bar\'resi Elat Ban Be Discord IR.Spring Morajee Konid | Discord : discord.gg/zR7XKF4'
		end
		if target and target > 0 then
			local ping = GetPlayerPing(target)
        
			if ping and ping > 0 then
				if duree and duree < 365 then
					local sourceplayername = GetPlayerName(source)
					local targetplayername = GetPlayerName(target)
					local targeticname	   = ESX.GetPlayerFromId(target).name
						for k,v in ipairs(GetPlayerIdentifiers(target))do
							if string.sub(v, 1, string.len("steam:")) == "steam:" then
								identifier = v
							elseif string.sub(v, 1, string.len("license:")) == "license:" then
								license = v
							elseif string.sub(v, 1, string.len("live:")) == "live:" then
								liveid = v
							elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
								xblid  = v
							elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
								discord = v
							elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
								playerip = v
							end
						end
				
					if duree > 0 then
						ban(source,identifier,license,liveid,xblid,discord,playerip,targeticname,sourceplayername,duree,reason,0)
						DropPlayer(target, 'Shoma Be Dalil (' .. reason .. ') Ban Shodid, Tavasot : '.. sourceplayername .. " | "..tostring(os.time()))
						TriggerClientEvent('chatMessage', -1, "[BAN]", {255, 0, 0}, "^1" .. targetplayername .. " ^0Tavasot ^2" .. sourceplayername .. " ^0Ban Shod Be Modat ^8" .. duree .. " ^0Rooz Be Dalile: ^3" .. reason )
						TriggerEvent('DiscordBot:ToDiscord', 'banp', 'BanSystem', "```css\n[Player Banned]\nSteam Name : "..targetplayername.."\nSteam Hex : " .. identifier .."\nRockstar License : "..license.."\nIP : "..playerip.."\nDiscord : ".. discord .."\n Time : "..duree.."\nReason : "..reason.."\nBy : "..sourceplayername  .."\n```",'user', true, source, false)
					else
						ban(source,identifier,license,liveid,xblid,discord,playerip,targeticname,sourceplayername,duree,reason,1)
						DropPlayer(target, Text.yourpermban .. reason)
						TriggerClientEvent('chatMessage', -1, "[BAN]", {255, 0, 0}, "^1" .. targetplayername .. " ^0Tavasot ^2" .. sourceplayername .. " ^0Permanent Ban Shod Be Dalile: ^3" .. reason )
						TriggerEvent('DiscordBot:ToDiscord', 'banp', 'BanSystem', "```css\n[Player Banned]\nSteam Name : "..targetplayername.."\nSteam Hex : " .. identifier .."\nRockstar License : "..license.."\nIP : "..playerip.."\nDiscord : ".. discord .."\nTime : Pearmanet\nReason : "..reason.."\nBy : "..sourceplayername  .."\n```",'user', true, source, false)
					end
					--DropPlayer(source,'Ban Player')
				
				else
					TriggerEvent('bansql:sendMessage', source, '[^8System^7]: Wrong Time Entered!')
				end	
			else
				TriggerEvent('bansql:sendMessage', source, '[^8System^7]: This Player is not Online!')
			end
		else
			TriggerEvent('bansql:sendMessage', source, '[^8System^7]: Wrong Id Entered!')
		end
	else
		TriggerEvent('bansql:sendMessage', source, Text.cmdban)
	end
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM ', 'Insufficient Permissions.' } })
end, {help = Text.ban, params = {{name = "id"}, {name = "day", help = Text.dayhelp}, {name = "reason", help = Text.reason}}})

TriggerEvent('es:addAdminCommand', 'bancheater', 2, function (source, args, user)
--anticheatsendToDisc("test")
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM ', 'Insufficient Permissions.' } })
end, {help = Text.ban, params = {{name = "id"}, {name = "day", help = Text.dayhelp}, {name = "reason", help = Text.reason}}})

TriggerEvent('es:addAdminCommand', 'banoffline', 7, function (source, args, user)
	if args then
		local time   = tonumber(args[2])
		local target = args[1]
		local reason = table.concat(args, " ", 3)
		local sourceplayername = GetPlayerName(source)
		local permanent = 0

		if time then
			if target and string.find(target, "steam:") == 1 then
				for i = 1, #ac_banlist, 1 do
					if ac_banlist[i].identifier == target then
						TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban', ' In Player Dar Hale Hazer Ban Mibashad! Name: '.. ac_banlist[i].name } })
						return
					end
				end
				MySQL.Async.fetchAll('SELECT * FROM ac_baninfo WHERE identifier = @identifier', 
				{
					['@identifier'] = target
				}, function(data)
	
					if data[1] ~= nil then
						if time > 0 then
							ban(source,data[1].identifier,data[1].license,data[1].liveid,data[1].xblid,data[1].discord,data[1].playerip,data[1].playername,sourceplayername,time,reason,permanent)
						else
							local permanent = 1
							ban(source,data[1].identifier,data[1].license,data[1].liveid,data[1].xblid,data[1].discord,data[1].playerip,data[1].playername,sourceplayername,time,reason,permanent)
						end
					else
						TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban', ' Steam Hex varede Dar Database Mojod nist' } })
					end
				end)
			else
				TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban', ' Lotfan Steam Hex ra Kamel vared konid (Example: steam:11000013c89a949)' } })
			end
		else
			TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban', ' Zaman Ban Ra Vared Konid.' } })
		end
	else
		TriggerClientEvent('chat:addMessage', source, { args = { '^1Ban', ' Invalid usage.' } })
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = 'Ban Kardane Yek Playere Offline', params = {{name = "Steam Hex", help = 'steam:11000013c89a949'}, {name = "Days", help = 'Tedad Roze Ban'}, {name = "Reason", help = 'Dalil Ban'}}})

-- console / rcon can also utilize es:command events, but breaks since the source isn't a connected player, ending up in error messages
AddEventHandler('bansql:sendMessage', function(source, message)
	if source ~= 0 then
		TriggerClientEvent('chat:addMessage', source, { args = { '^1ac_banlist ', message } } )
	else
		print('SqlBan: ' .. message)
	end
end)

AddEventHandler('playerConnecting', function (playerName,setKickReason)
	local steamID  = "empty"
	local license  = "empty"
	local liveid   = "empty"
	local xblid    = "empty"
	local discord  = "empty"
	local playerip = "empty"

	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamID = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			liveid = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			xblid  = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			discord = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			playerip = v
		end
	end

	--Si ac_banlist pas chargée
	if (ac_banlist == {}) then
		Citizen.Wait(1000)
	end

	for i = 1, #ac_banlist, 1 do
		if 
			((tostring(ac_banlist[i].identifier)) == tostring(steamID) 
			or (tostring(ac_banlist[i].license)) == tostring(license) 
			or (tostring(ac_banlist[i].liveid)) == tostring(liveid) 
			or (tostring(ac_banlist[i].xblid)) == tostring(xblid) 
			or (tostring(ac_banlist[i].discord)) == tostring(discord))
		then

			if (tonumber(ac_banlist[i].permanent)) == 1 then

				setKickReason(Text.yourpermban .. ac_banlist[i].reason)
				CancelEvent()
				break

			elseif (tonumber(ac_banlist[i].expiration)) > os.time() then

				local tempsrestant     = (((tonumber(ac_banlist[i].expiration)) - os.time())/60)
				if tempsrestant >= 1440 then
					local day        = (tempsrestant / 60) / 24
					local hrs        = (day - math.floor(day)) * 24
					local minutes    = (hrs - math.floor(hrs)) * 60
					local txtday     = math.floor(day)
					local txthrs     = math.floor(hrs)
					local txtminutes = math.ceil(minutes)
						setKickReason(Text.yourban .. ac_banlist[i].reason .. Text.timeleft .. txtday .. Text.day ..txthrs .. Text.hour ..txtminutes .. Text.minute)
						CancelEvent()
						break
				elseif tempsrestant >= 60 and tempsrestant < 1440 then
					local day        = (tempsrestant / 60) / 24
					local hrs        = tempsrestant / 60
					local minutes    = (hrs - math.floor(hrs)) * 60
					local txtday     = math.floor(day)
					local txthrs     = math.floor(hrs)
					local txtminutes = math.ceil(minutes)
						setKickReason(Text.yourban .. ac_banlist[i].reason .. Text.timeleft .. txtday .. Text.day .. txthrs .. Text.hour .. txtminutes .. Text.minute)
						CancelEvent()
						break
				elseif tempsrestant < 60 then
					local txtday     = 0
					local txthrs     = 0
					local txtminutes = math.ceil(tempsrestant)
						setKickReason(Text.yourban .. ac_banlist[i].reason .. Text.timeleft .. txtday .. Text.day .. txthrs .. Text.hour .. txtminutes .. Text.minute)
						CancelEvent()
						break
				end

			elseif (tonumber(ac_banlist[i].expiration)) < os.time() and (tonumber(ac_banlist[i].permanent)) == 0 then

				deletebanned(steamID)
				break

			end
		end

	end

end)

AddEventHandler('esx:playerLoaded',function(source)
	CreateThread(function()
	Wait(5000)
		local steamID  = "no info"
		local license  = "no info"
		local liveid   = "no info"
		local xblid    = "no info"
		local discord  = "no info"
		local playerip = "no info"
		local playername = exports.essentialmode:GetPlayerICName(source)

		for k,v in ipairs(GetPlayerIdentifiers(source))do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				steamID = v
			elseif string.sub(v, 1, string.len("license:")) == "license:" then
				license = v
			elseif string.sub(v, 1, string.len("live:")) == "live:" then
				liveid = v
			elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
				xblid  = v
			elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				discord = v
			elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
				playerip = v
			end
		end

		MySQL.Async.fetchAll('SELECT * FROM `ac_baninfo` WHERE `identifier` = @identifier', {
			['@identifier'] = steamID
		}, function(data)
		local found = false
			for i=1, #data, 1 do
				if data[i].identifier == steamID then
					found = true
				end
			end
			if not found then
				MySQL.Async.execute('INSERT INTO ac_baninfo (identifier,license,liveid,xblid,discord,playerip,playername) VALUES (@identifier,@license,@liveid,@xblid,@discord,@playerip,@playername)', 
					{ 
					['@identifier'] = steamID,
					['@license']    = license,
					['@liveid']     = liveid,
					['@xblid']      = xblid,
					['@discord']    = discord,
					['@playerip']   = playerip,
					['@playername'] = playername
					},
					function ()
				end)
			else
				MySQL.Async.execute('UPDATE `ac_baninfo` SET `license` = @license, `liveid` = @liveid, `xblid` = @xblid, `discord` = @discord, `playerip` = @playerip, `playername` = @playername WHERE `identifier` = @identifier', 
					{ 
					['@identifier'] = steamID,
					['@license']    = license,
					['@liveid']     = liveid,
					['@xblid']      = xblid,
					['@discord']    = discord,
					['@playerip']   = playerip,
					['@playername'] = playername
					},
					function ()
				end)
			end
		end)
		if Config.MultiServerSync then
			doublecheck(source)
		end
	end)
end)


RegisterServerEvent('BanSql:CheckMe')
AddEventHandler('BanSql:CheckMe', function()
	doublecheck(source)
end)

RegisterServerEvent('cheat:banme')
AddEventHandler('cheat:banme', function(reason)
	bancheater(source, reason)
end)

--[[AddEventHandler('explosionEvent', function(sender, ev)
	  if ev.explosionType == 29 then    
          bancheater(sender,'EXP')
      end
	 
    
end)]]

function bancheater(source, reason)
	local _source =  source
	local xPlayer  = ESX.GetPlayerFromId(_source)  
	local targetplayername = GetPlayerName(_source)
	if xPlayer ~= nil then
    if xPlayer.permission_level >= 1 then
	
	anticheatadminsendToDiscLOG(targetplayername .. '\n' .. reason)
	print(reason .. ' '.. source )
	else
	local identifier
	local license
	local liveid    = ""
	local xblid     = ""
	local discord   = ""
	local playerip
	local duree = 0
	local targetplayername = GetPlayerName(_source)
	local sourceplayername = 'Anti Cheat'
		reason = "IRSGR | " .. reason
	if reason == "" then
		reason = _U('no_reason')
	end
	
	for k,v in ipairs(GetPlayerIdentifiers(_source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			identifier = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			liveid = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			xblid  = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			discord = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			playerip = v
		end
	end
		local permanent = 1
		local steam = identifier:gsub("steam:", "");
        local steamDec = tostring(tonumber(steam,16));
		local targeticname	   = exports.essentialmode:GetPlayerICName(_source)
		if targeticname == nil then
		targeticname = 'noname'
		end
		local targeticname = targeticname:gsub("_", " ");
        steam = "https://steamcommunity.com/profiles/" .. steamDec;
		anticheatsendToDisc("Reason : Cheat(" .. reason ..")\n"..
		"Ban Time : Permanent\n"..
		"Cheater Steam Name : " .. targetplayername .. "\n" ..
		"Cheater IC Name : " .. targeticname .. "\n" .. 
		"Steam Profile : " .. steam .. "\n" ..
		"Steam Hex : " .. identifier .. "\n" ..
		"Rockstar License: " .. license .. "\n" ..
		"Ip : " .. playerip:gsub("ip:", "") .. "\n" ..
		"Discord UID: " .. discord:gsub('discord:', '') .. "\n");
		anticheatsendToDiscLOG("Reason : Cheat(" .. reason ..")\n"..
		"Ban Time : Permanent\n"..
		"Cheater Steam Name : " .. targetplayername .. "\n" ..
		"Cheater IC Name : " .. targeticname .. "\n" .. 
		"Steam Profile : " .. steam .. "\n" ..
		"Steam Hex : " .. identifier .. "\n" ..
		"Rockstar License: " .. license .. "\n" ..
		"Ip : " .. playerip:gsub("ip:", "") .. "\n" ..
		"Discord UID: " .. discord:gsub('discord:', '') .. "\n");
		--sendToDisc("wtf")
		TriggerClientEvent('chatMessage', -1, "[IR.Spring Guard]", {255, 0, 0}, "^1" .. targetplayername .. " ^0Tavasot ^2" .. sourceplayername .. " ^0Ban Shod(Permanent) Be Dalile: ^3" .. reason )
		ban(_source,identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,'Cheat(' .. reason .. ')',permanent)
		DropPlayer(_source, '❌❌Shoma Be Dalil Cheat('.. reason ..') Tavasot Anti Cheat Permanent Ban Shodid❌❌')
		end
		else
		print('offline player for cheat '.. _source)
		end
end

function ban(source,identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
--calcul total expiration (en secondes)
	local expiration = duree * 86400
	local timeat     = os.time()
	local added      = os.date()
	local message
	
	if expiration < os.time() then
		expiration = os.time()+expiration
	end
	
		table.insert(ac_banlist, {
			identifier = identifier,
			license    = license,
			liveid     = liveid,
			xblid      = xblid,
			discord    = discord,
			playerip   = playerip,
			reason     = reason,
			expiration = expiration,
			permanent  = permanent
          })

		MySQL.Async.execute(
                'INSERT INTO ac_banlist (identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,expiration,timeat,permanent) VALUES (@identifier,@license,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@expiration,@timeat,@permanent)',
                { 
				['@identifier']       = identifier,
				['@license']          = license,
				['@liveid']           = liveid,
				['@xblid']            = xblid,
				['@discord']          = discord,
				['@playerip']         = playerip,
				['@targetplayername'] = targetplayername,
				['@sourceplayername'] = sourceplayername,
				['@reason']           = reason,
				['@expiration']       = expiration,
				['@timeat']           = timeat,
				['@permanent']        = permanent,
				},
				function ()
		end)

		if permanent == 0 then
			TriggerEvent('bansql:sendMessage', source, (Text.youban .. targetplayername .. Text.during .. duree .. Text.forr .. reason))
			message = (targetplayername .. Text.isban .." ".. duree .. Text.forr .. reason .." ".. Text.by .." ".. sourceplayername.."```"..identifier .."\n".. license .."\n".. liveid .."\n".. xblid .."\n".. discord .."\n".. playerip .."```")
		else
			TriggerEvent('bansql:sendMessage', source, (Text.youban .. targetplayername .. Text.permban .. reason))
			message = (targetplayername .. Text.isban .." ".. Text.permban .. reason .." ".. Text.by .." ".. sourceplayername.."```"..identifier .."\n".. license .."\n".. liveid .."\n".. xblid .."\n".. discord .."\n".. playerip .."```")
		end

		MySQL.Async.execute(
                'INSERT INTO ac_banlisthistory (identifier,license,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,added,expiration,timeat,permanent) VALUES (@identifier,@license,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@added,@expiration,@timeat,@permanent)',
                { 
				['@identifier']       = identifier,
				['@license']          = license,
				['@liveid']           = liveid,
				['@xblid']            = xblid,
				['@discord']          = discord,
				['@playerip']         = playerip,
				['@targetplayername'] = targetplayername,
				['@sourceplayername'] = sourceplayername,
				['@reason']           = reason,
				['@added']            = added,
				['@expiration']       = expiration,
				['@timeat']           = timeat,
				['@permanent']        = permanent,
				},
				function ()
		end)
		
		ac_banlistHistoryLoad = false
end

function loadac_banlist()
	MySQL.Async.fetchAll(
		'SELECT * FROM ac_banlist',
		{},
		function (data)
		  ac_banlist = {}

		  for i=1, #data, 1 do
			table.insert(ac_banlist, {
				identifier = data[i].identifier,
				license    = data[i].license,
				liveid     = data[i].liveid,
				xblid      = data[i].xblid,
				discord    = data[i].discord,
				playerip   = data[i].playerip,
				reason     = data[i].reason,
				expiration = data[i].expiration,
				permanent  = data[i].permanent
			  })
		  end
    end)
end

-- function loadac_banlistHistory()
-- 	MySQL.Async.fetchAll(
-- 		'SELECT * FROM ac_banlisthistory',
-- 		{},
-- 		function (data)
-- 		  ac_banlistHistory = {}

-- 		  for i=1, #data, 1 do
-- 			table.insert(ac_banlistHistory, {
-- 				identifier       = data[i].identifier,
-- 				license          = data[i].license,
-- 				liveid           = data[i].liveid,
-- 				xblid            = data[i].xblid,
-- 				discord          = data[i].discord,
-- 				playerip         = data[i].playerip,
-- 				targetplayername = data[i].targetplayername,
-- 				sourceplayername = data[i].sourceplayername,
-- 				reason           = data[i].reason,
-- 				added            = data[i].added,
-- 				expiration       = data[i].expiration,
-- 				permanent        = data[i].permanent,
-- 				timeat           = data[i].timeat
-- 			  })
-- 		  end
--     end)
-- end

function deletebanned(identifier) 
	MySQL.Async.execute(
		'DELETE FROM ac_banlist WHERE identifier=@identifier',
		{
		  ['@identifier']  = identifier
		},
		function ()
			loadac_banlist()
	end)
end

function doublecheck(player)
	if GetPlayerIdentifiers(player) then
		local steamID  = "empty"
		local license  = "empty"
		local liveid   = "empty"
		local xblid    = "empty"
		local discord  = "empty"
		local playerip = "empty"

		for k,v in ipairs(GetPlayerIdentifiers(player))do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				steamID = v
			elseif string.sub(v, 1, string.len("license:")) == "license:" then
				license = v
			elseif string.sub(v, 1, string.len("live:")) == "live:" then
				liveid = v
			elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
				xblid  = v
			elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				discord = v
			elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
				playerip = v
			end
		end

		for i = 1, #ac_banlist, 1 do
			if 
				((tostring(ac_banlist[i].identifier)) == tostring(steamID) 
				or (tostring(ac_banlist[i].license)) == tostring(license) 
				or (tostring(ac_banlist[i].liveid)) == tostring(liveid) 
				or (tostring(ac_banlist[i].xblid)) == tostring(xblid) 
				or (tostring(ac_banlist[i].discord)) == tostring(discord) 
				or (tostring(ac_banlist[i].playerip)) == tostring(playerip)) 
			then

				if (tonumber(ac_banlist[i].permanent)) == 1 then
					DropPlayer(player, Text.yourban .. ac_banlist[i].reason)
					break

				elseif (tonumber(ac_banlist[i].expiration)) > os.time() then

					local tempsrestant     = (((tonumber(ac_banlist[i].expiration)) - os.time())/60)
					if tempsrestant > 0 then
						DropPlayer(player, Text.yourban .. ac_banlist[i].reason)
						break
					end

				elseif (tonumber(ac_banlist[i].expiration)) < os.time() and (tonumber(ac_banlist[i].permanent)) == 0 then

					deletebanned(steamID)
					break

				end
			end
		end
	end
end
function anticheatsendToDisc(footer)
    local embed = {}
    embed = {
        {
            ["color"] = 16711680, -- GREEN = 65280 --- RED = 16711680
            ["title"] = "**Cheater Banned!**",
            ["description"] = "**Bye Bye My Son :)**",
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }
    -- Start
    -- TODO Input Webhook
    PerformHttpRequest('https://discordapp.com/api/webhooks/768689000382595072/gOoBtFlT942xPck3_nlv9PNfrPZZPy9K9zbJX29EoIpT1RQWv5ny0rk53WVGFXOczF7Z', 
    function(err, text, headers) 
	--print(json.encode(text))
	end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end
function anticheatadminsendToDiscLOG(footer)
    local embed = {}
    embed = {
        {
            ["color"] = 65280, -- GREEN = 65280 --- RED = 16711680
            ["title"] = "**Admin Dont Banned!**",
            ["description"] = "**Az Koun Avordi :)**",
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }
    -- Start
    -- TODO Input Webhook
    PerformHttpRequest('https://discordapp.com/api/webhooks/745366781610426530/jk4yoqwOWCWjGlN7qNeTt98qXYduYHtJlb6eHh2iN4eWVPUd6So1dvRBdSikViTZ4f5j', 
    function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end

function anticheatsendToDiscLOG(footer)
    local embed = {}
    embed = {
        {
            ["color"] = 16711680, -- GREEN = 65280 --- RED = 16711680
            ["title"] = "**Cheater Banned!**",
            ["description"] = "**Bye Bye My Son :)**",
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }
    -- Start
    -- TODO Input Webhook
    PerformHttpRequest('https://discordapp.com/api/webhooks/745365793449050208/-PLI9wawWtjrAqpWzP3HxGwf7CaIFwe5CWt7Q-nKlTxSK9YP1u56Vsv9TdOTCahBhDB6', 
    function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end
