#!/bin/bash
echo "---Checking for 'runtime' folder---"
if [ ! -d ${DATA_DIR}/runtime ]; then
	echo "---'runtime' folder not found, creating...---"
	mkdir ${DATA_DIR}/runtime
else
	echo "---'runtime' folder found---"
fi

echo "---Checking if Runtime is installed---"
if [ -z "$(find ${DATA_DIR}/runtime -name jre*)" ]; then
    if [ "${RUNTIME_NAME}" == "jre1.8.0_211" ]; then
    	echo "---Downloading and installing Runtime---"
		cd ${DATA_DIR}/runtime
		wget -qi ${RUNTIME_NAME} https://github.com/ich777/docker-minecraft-basic-server/raw/master/runtime/8u211.tar.gz
        tar --directory ${DATA_DIR}/runtime -xvzf ${DATA_DIR}/runtime/8u211.tar.gz
        rm -R ${DATA_DIR}/runtime/8u211.tar.gz
    else
    	if [ ! -d ${DATA_DIR}/runtime/${RUNTIME_NAME} ]; then
        	echo "---------------------------------------------------------------------------------------------"
        	echo "---Runtime not found in folder 'runtime' please check again! Putting server in sleep mode!---"
        	echo "---------------------------------------------------------------------------------------------"
        	sleep infinity
        fi
    fi
else
	echo "---Runtime found---"
fi

echo "---Checking for 'jDownloader.jar'---"
if [ ! -f ${DATA_DIR}/jDownloader.jar ]; then
	echo "---'jDownloader.jar' not found, downloading...---"
	cd ${DATA_DIR}
    wget -qi jDownloader.jar https://github.com/ich777/docker-jdownloader2/raw/master/JD/JDownloader.jar
	if [ ! -f ${DATA_DIR}/jDownloader.jar ]; then
		echo "-----------------------------------------------------------------------------------------"
		echo "---Something went wrong can't download 'jDownloader.jar' Putting server in sleep mode!---"
		echo "-----------------------------------------------------------------------------------------"
		sleep infinity
	fi
else
	echo "---'jDownloader.jar' folder found---"
fi

echo "---Preparing Server---"
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
find /tmp -name ".X99*" -exec rm -f {} \;
chmod -R 770 ${DATA_DIR}

echo "---Starting Xvfb server---"
screen -S Xvfb -L -Logfile ${DATA_DIR}/XvfbLog.0 -d -m /opt/scripts/start-Xvfb.sh
sleep 5
echo "---Starting x11vnc server---"
screen -S x11vnc -L -Logfile ${DATA_DIR}/x11vncLog.0 -d -m /opt/scripts/start-x11.sh
sleep 5
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 8080 localhost:5900
sleep 5

echo "---Starting jDownloader2---"
export DISPLAY=:99
${DATA_DIR}/runtime/${RUNTIME_NAME}/bin/java -jar ${DATA_DIR}/jDownloader.jar
fi