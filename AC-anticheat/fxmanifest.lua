fx_version 'adamant'
games {'gta5'}

client_script {
    'client/cl_anticheat.lua',
    'client/cl_ban.lua'
    'config.lua'
}

server_script {
    '@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
    'server/sv_anticheat.lua',
    'server/sv_ban.lua'
    'config.lua'
}

exports {
    'SetPlayerVisible',
    'Whitelist',
}

server_exports {
    'bancheater',
    'adminmsg'
}

dependencies {
	'async'
}

client_script "AC_USDUFHSILFSKOAKQA.lua"
