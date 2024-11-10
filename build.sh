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
lunch aosp_$DEVICE-ap3a-userdebug
make bacon -j$(nproc) 2>&1 | tee $LOG_FILE

ZIP_FILE=$(find out/target/product/$DEVICE -name "*.zip" | head -n 1)
RECOVERY_IMG=$(find out/target/product/$DEVICE -name "recovery.img" | head -n 1)

if [[ -f "$ZIP_FILE" && -f "$RECOVERY_IMG" ]]; then
    echo -e "${GREEN}Build successful! Uploading files...${NC}"
    ZIP_URL=$(curl --upload-file $ZIP_FILE https://transfer.sh/$(basename $ZIP_FILE))
    RECOVERY_URL=$(curl --upload-file $RECOVERY_IMG https://transfer.sh/$(basename $RECOVERY_IMG))

    echo -e "${GREEN}Build completed successfully.${NC}"
    echo "ZIP URL: $ZIP_URL"
    echo "Recovery Image URL: $RECOVERY_URL"
else
    echo -e "${RED}Build failed. Uploading error log...${NC}"
    ERROR_LOG_URL=$(curl -F "content=<${LOG_FILE}" https://dpaste.com/api/v2/)

    echo -e "${RED}Build failed. Error log URL: $ERROR_LOG_URL${NC}"
fi
