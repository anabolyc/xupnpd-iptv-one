#!/bin/bash

function update_data {
	wget $M3U_URL -O ./playlist.m3u && \
	grep -E 'EXTM3U|,Discovery' ./playlist.m3u -A 1 > ./media/Discovery.m3u
	grep -E 'EXTM3U|,Nat' ./playlist.m3u -A 1 > ./media/Nat\ Geo.m3u
	cp ./playlist.m3u ./media/ONE.m3u
	return 0
}

# patch config
if [ ! -f ./.xupnpd.lua.patched ]; then
	echo "Patching configuration file"
	# sed -e "s/UPnP-IPTV/${FRONTEND_NAME}/" \
    #         -e "s/4044/${FRONTEND_PORT}/" \
    #         -e "s/60bd2fb3-dabe-cb14-c766-0e319b54c29a/${BACKEND_GUID}/" \
    #         -e "s/cfg.debug=1/cfg.debug=${DEBUG_LEVEL}/" \
	# 		-e "s/cfg.ssdp_interface='lo'/cfg.ssdp_interface='${NETWORK_IFCE}'/" \
	# 		-e "s/cfg.proxy=2/cfg.proxy=0/" \
    #         -i ./xupnpd.lua 
	# sed -e "s/xupnpd/${BACKEND_GUID}/" -i ./www/dev.xml
	touch ./.xupnpd.lua.patched
else
	echo "Config file appears to be patched already"
fi

# update data
echo "Starting data update from $M3U_URL every 600 seconds"
while true
do
	sleep 600 && update_data
	#timeout -sHUP 1m wget $M3U_URL -O ./playlists/playlist.m3u
done &

update_data 
./xupnpd

