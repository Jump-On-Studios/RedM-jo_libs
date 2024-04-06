author "JUMP ON studios : shop.jumpon-studios.com"
documentation 'https://docs.kaddarem.com'
version '1.0.1'
package_id '1'

fx_version "adamant"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game "rdr3"
lua54 'yes'

server_scripts {
  "server/versionChecker.lua"
}

files {
  "client/**.lua",
  "server/**.lua",
	"html/dist/**.html",
	"html/dist/**.js",
	"html/dist/**.css",
	"html/dist/**.ttf",
	"html/dist/**.png",
	"html/dist/**.mp3",
	"html/dist/**.gif",
}