#!/bin/bash
#
# Copyright (C) 2019-2023 crDroid Android Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#$1=TARGET_DEVICE, $2=PRODUCT_OUT, $3=FILE_NAME
output=$2/$1.json

# Cleanup old file
if [ -f "$output" ]; then
	rm "$output"
fi

echo "Generating JSON file data for OTA support..."

# Check if filename contains "UNOFFICIAL" and exit if true
if [[ "$3" == *"UNOFFICIAL"* ]]; then
    echo "Skipping JSON generation as the build is marked UNOFFICIAL."
    exit 0
fi

# Set romtype to OFFICIAL since we’ve confirmed it’s not UNOFFICIAL
romtype="OFFICIAL"

# Generate JSON data
buildprop="$2/system/build.prop"
linenr=`grep -n "ro.build.date.utc" "$buildprop" | cut -d':' -f1`
datetime=`sed -n "$linenr"p < "$buildprop" | cut -d'=' -f2`
filename="$3"
id=`sha256sum "$2/$3" | cut -d' ' -f1`
size=`stat -c "%s" "$2/$3"`

# Create JSON output
echo '{
  "response": [
    {
      "datetime": '"$datetime"',
      "filename": "'"$filename"'",
      "id": "'"$id"'",
      "romtype": "'"$romtype"'",
      "size": '"$size"',
      "url": "https://sourceforge.net/projects/aospb-project/files/'"$1"'/'"$3"'/download",
    }
  ]
}' >> "$output"

echo "JSON file generated successfully at $output"
