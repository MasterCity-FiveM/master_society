fx_version 'adamant'

game 'gta5'

description 'ESX Society'

version '1.0.4'

ui_page 'html/ui.html'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/br.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/sv.lua',
    'locales/pl.lua',
    'locales/nl.lua',
    'locales/cs.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'client/*.lua',
}

files {
	'html/ui.html',
	'html/css/*.css',
	'html/js/*.js',
	'html/datatables/*.js',
	'html/datatables/*.css',
	'html/datatables/DataTables-1.10.24/css/*.css',
	'html/datatables/DataTables-1.10.24/images/*.png',
	'html/datatables/DataTables-1.10.24/js/*.js',
}

dependencies {
    'es_extended',
    'cron',
    'esx_addonaccount'
}
