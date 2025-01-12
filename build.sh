#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <device_codename>"
    exit 1
fi

DEVICE="$1"
LOG_FILE="build/error.log"

GREEN='\033[1;32m'    
RED='\033[0;31m'      
NC='\033[0m'          

echo "Building ROM for $DEVICE..."
source build/envsetup.sh
make installclean
breakfast $DEVICE
brunch $DEVICE 2>&1 | tee $LOG_FILE

OUT="$(pwd)/out/target/product/$DEVICE"

ZIP_FILE=$(ls "$OUT"/aosPB_*.zip | head -n -1)
RECOVERY_IMG=$(ls "$OUT"/*recovery.img | tail -n -1)

if [[ -f "$ZIP_FILE" && -f "$RECOVERY_IMG" ]]; then
    echo -e "${GREEN}Build successful! Uploading files...${NC}"
    
    #Searching for servers in Go File
    SERVER=$(curl -s https://api.gofile.io/servers | jq -r '.data.servers[0].name')
    echo -e "Uploading ZIP file to the server: $SERVER"
    
    #Uploading the Zip & Recovery
    ZIP_URL=$(curl -# -F "file=@$ZIP_FILE" "https://${SERVER}.gofile.io/uploadFile" | jq -r '.data|.downloadPage') 2>&1
    RECOVERY_URL=$(curl -# -F "file=@$RECOVERY_IMG" "https://${SERVER}.gofile.io/uploadFile" | jq -r '.data|.downloadPage') 2>&1

    echo -e "${GREEN}Build uploaded successfully.${NC}"
    echo "ZIP URL: $ZIP_URL"
    echo "Recovery Image URL: $RECOVERY_URL"
else
    echo -e "${RED}Build failed. Uploading error log...${NC}"
    ERROR_LOG_URL=$(curl -F "content=<${LOG_FILE}" https://dpaste.com/api/v2/)

    echo -e "${RED}Build failed. Error log URL: $ERROR_LOG_URL${NC}"
fi
