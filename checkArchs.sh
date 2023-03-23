#!/bin/bash

declare -a intel_apps
declare -a arm_apps
declare -a not_verified_apps

echo ""
echo ""
echo "########################################"
echo "#" 
echo "# CHECKING APPLICATION CPU ARCHITECTURE "
echo "#"
echo "########################################"
echo ""

for app in /Applications/*.app; do
    app_name="$(basename "$app" .app)"
    macos_folder="$app/Contents/MacOS"
    if [ -d "$macos_folder" ]; then
        while IFS= read -r -d '' exec_file; do
            arch="$(lipo -archs "$exec_file" 2> /dev/null)"
            if [[ $arch == *"x86_64"* && $arch != *"arm64"* ]]; then
                intel_apps+=("$app_name")
                found_arch=true
                break
            elif [[ $arch == *"arm64"* ]]; then
                arm_apps+=("$app_name")
                found_arch=true
                break
            fi
        done < <(find "$macos_folder" -maxdepth 1 -type f -print0)
        if [ "$found_arch" != true ]; then
            not_verified_apps+=("$app_name")
        fi
    else
        not_verified_apps+=("$app_name")
    fi
done

max_len=${#intel_apps[@]}
if [[ ${#arm_apps[@]} -gt $max_len ]]; then
    max_len=${#arm_apps[@]}
fi
if [[ ${#not_verified_apps[@]} -gt $max_len ]]; then
    max_len=${#not_verified_apps[@]}
fi

echo "The number of Intel apps using rosetta 2 on your system: ${#intel_apps[@]}"
echo "The number of native Arm apps on your system: ${#arm_apps[@]}"
echo "The number of apps that can't be verified on your system: ${#not_verified_apps[@]}"
echo ""
echo ""

read -p "Would you like to print the table? (y/n) " choice

if [ "$choice" == "y" ]; then
	echo ""
	echo ""
    printf "%-30s | %-30s | %-30s\n" "Intel Apps" "Arm Apps" "Not-Verified"
    printf "%-30s | %-30s | %-30s\n" "------------------------------" "------------------------------" "------------------------------"

    for ((i=0; i<$max_len; i++)); do
        intel_app=${intel_apps[$i]:-""}
        arm_app=${arm_apps[$i]:-""}
        not_verified_app=${not_verified_apps[$i]:-""}
        printf "%-30s | %-30s | %-30s\n" "$intel_app" "$arm_app" "$not_verified_app"
    done
fi


