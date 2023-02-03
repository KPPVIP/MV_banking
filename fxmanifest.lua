---Double L Leaks---
fx_version 'adamant'

game 'gta5'

description 'Double L Leaks'

version '0.0.1'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}

ui_page 'html/ui.html'
files {
  'html/*.png',
  'html/*.css', 
  'html/*.js', 
  'html/*.ttf',
  'html/*.otf',
  'html/**/*.ttf',
  'html/**/*.otf',
  'html/ui.html'
}


dependencies {
	'es_extended'
}


