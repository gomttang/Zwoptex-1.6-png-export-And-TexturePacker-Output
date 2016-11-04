# TexturePacker reference
# https://www.codeandweb.com/texturepacker/documentation#command-line
#!/bin/sh
# texturePacker License
####################################################################
####################################################################
TEXTURE_PACKER_LISENSE= # Please Input License!!!!!!!!! 
####################################################################
####################################################################
CURRENT_FOLDER_NAME="${PWD##*/}"
SCRIPT_FOLDER=$(pwd)

# zwd 1.6 version file path
OLD_ZWD_FILES_PATH=$SCRIPT_FOLDER"/zwd"
# SUFFIX
ZWD_EXTENSION=".zwd"

# Work folder
WORK_RESULT_PATH=$SCRIPT_FOLDER"/texturePackerWork"
# Output png image path in Work folder
ZWD_IMAGE_EXPORT_PATH=$WORK_RESULT_PATH"/images"
# texturePacker output folder int Work folder
TEXTUREPACKER_EXPORT_PATH=$WORK_RESULT_PATH"/texturePackerOutput"


# mkdir output folder
rm -rf "$WORK_RESULT_PATH"
rm -rf "$ZWD_IMAGE_EXPORT_PATH"
rm -rf "$TEXTUREPACKER_EXPORT_PATH"

mkdir -p "$WORK_RESULT_PATH"
mkdir -p "$ZWD_IMAGE_EXPORT_PATH"
mkdir -p "$TEXTUREPACKER_EXPORT_PATH"


export_zwd_to_files() {
	for fileFullPath in "$OLD_ZWD_FILES_PATH"/*
	do
		# extract file name
		fileName=$(basename "$fileFullPath" .zwd)
		replaceFileName=${fileName//"_hd"/""}
		# export file path
		exportPath="$ZWD_IMAGE_EXPORT_PATH/$replaceFileName"

		rm -rf "$exportPath"
		if [ ! -d "$exportPath" ]; then
			mkdir -p "$exportPath"
			./zwoptex-export "$fileFullPath" "$exportPath"
	fi
	done

	echo "Zwoptex file export success!!!!!"
}

# if you want to use this 
tinyPng() {
	echo "==> Tiny PNG Start...!"
	original_filename=$1
	output_filename=$2

	echo "=> TinyPNG $original_filename"

	JSON=`curl -i --user api:$ApiKey --data-binary @"$original_filename" https://api.tinypng.com/shrink`
	URL=${JSON/*url\":\"/};
	URL=${URL/\"*/};
	imgName=${img#.\/}
	curl -o "$output_filename" "$URL"

	echo "> Saved : ${output_filename}\n"
}

#Texture Packer execute
echo "====>TexturePacker start...!"
texturePacker_func() {
	folder_path=$1
	folderName=$(basename "$folder_path")

	replace=""
	replaceFileName=${folderName//"_hd"/$replace}

	fullPath="$TEXTUREPACKER_EXPORT_PATH/$replaceFileName"

	rm -rf "$fullPath"
	mkdir -p "$fullPath"
	mkdir -p "$fullPath/hd"
	mkdir -p "$fullPath/sd"

	# If you put .16 in file name, it makes atlas as a RGBA4444
	pixelFormat="RGBA8888"
	if [[ $fullPath == *".16"* ]]; then
	  	pixelFormat="RGBA4444"
	  	# echo "pixelFormat RGBA4444"
	fi

	# texture packer excute
	# hd
	texturePacker --data "$fullPath/hd/$replaceFileName.plist" --format cocos2d --sheet "$fullPath/hd/$replaceFileName.png" "$folder_path" --trim-mode "None" --opt "$pixelFormat"
	# sd
	texturePacker --data "$fullPath/sd/$replaceFileName.plist" --format cocos2d --sheet "$fullPath/sd/$replaceFileName.png" "$folder_path" --trim-mode "None" --opt "$pixelFormat" --scale 0.5

	# tinypng 
# if you want to use tinyPng 
	# tinypng "$fullPath/hd/$replaceFileName.png" "$fullPath/hd/$replaceFileName.png"
	# tinypng "$fullPath/sd/$replaceFileName.png" "$fullPath/sd/$replaceFileName.png"
}


# Execute zwd 1.6 to png files 
export_zwd_to_files

# Execute Texture packer 
texturePacker --activate-license "$TEXTURE_PACKER_LISENSE"
for exportImgPath in "$ZWD_IMAGE_EXPORT_PATH"/*
do
	texturePacker_func "$exportImgPath"
done