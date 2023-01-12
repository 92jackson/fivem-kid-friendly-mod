fx_version 'cerulean'
game 'gta5'

description 'Inspired by FFFR for GTA5 SP, this mod gives server owners the ability to limit/supress/remove game mechanics not suitable for their target audience, as well as providing features which make the game easier to play for that audience. This mod was originally developed to provide a child-friendly experience for both of my sons.'

author 'Jackson92'
version '0.2.1'

shared_scripts {
	'config.lua',
	'scripts/shared.lua'
}
server_script 'scripts/server.lua'
client_scripts {
	--'@NativeUI/NativeUI.lua', -- Un-comment if you already have NativeUI Lua then comment out next line instead
	'scripts/NativeUI/NativeUI.min.lua', -- Minified version of NativeUI Lua inc with this script, comment out if line above is available
	
	'scripts/client.lua'
}

-- If you don't want to use the built-in loading screen, comment out the following 3 lines
loadscreen 'loadscreen/load.html'
loadscreen_cursor 'yes'
loadscreen_manual_shutdown 'yes'

files {
	'loadscreen/*',
	'loadscreen/assets/*',
	'loadscreen/assets/bg/*',
	'loadscreen/assets/nav/*',
	'loadscreen/assets/scripts/*'
}