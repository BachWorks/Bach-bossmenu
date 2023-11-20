fx_version      'cerulean'
game            'gta5'
author          'BachWorks'
version         'WIP'
lua54           'yes'
ui_page         'html/build/index.html'
server_script   '@oxmysql/lib/MySQL.lua'

client_scripts {
  "client/**/*",
}

server_scripts {
  "server/**/*",
}

shared_scripts {
	"@qb-core/shared/locale.lua",
	"@ox_lib/init.lua",
	"locales/en.lua",
	"locales/*.lua",
  "config.lua"
}

files {
  'html/build/index.html',
  'html/build/**/*',
}
