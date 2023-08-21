#!/bin/bash

# Lan computer setup and maintenance script (Lan Made Easy)
# by Kazi Hossain <kazi.h@nyu.edu>
# License: GNU GPLv3

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Check if the computer is running macOS or not
if [[ $(uname) == "Darwin" ]]; then
    mac=true
else
    mac=false
fi

# Display the ASCII art banner
cat << "EOF"
                         ______                     
 _________        .---"""      """---.              
:______.-':      :  .--------------.  :             
| ______  |      | :                : |             
|:______B:|      | |  FAS Computing | |             
|:______B:|      | |                | |             
|:______B:|      | |  connection    | |             
|         |      | |  complete.     | |             
|:_____:  |      | |                | |             
|    ==   |      | :                : |             
|       O |      :  '--------------'  :             
|       o |      :'---...______...---'              
|       o |-._.-i___/'             \._              
|'-.____o_|   '-.   '-...______...-'  `-._          
:_________:      `.____________________   `-.___.-. 
                 .'.eeeeeeeeeeeeeeeeee.'.      :___:
               .'.eeeeeeeeeeeeeeeeeeeeee.'.         
              :____________________________:"
EOF

echo "  " 
echo "  " 
echo "  " 

# Display main menu
while true; do
    echo "  " 
    echo "Lan Made Easy - Main Menu"
    echo "1) Check computer info"
    echo "2) Check for updates"
    echo "3) Install new software"
    echo "4) Send host-master"
    echo "0) Exit"
    echo "  " 

    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo "Computer Name : $(hostname)"
            echo "Manufacturer : Apple"
            echo "Serial Number : $(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')"
            echo "Operating System : $(sw_vers -productName) $(sw_vers -productVersion)"
            echo "Mac Address : $(ifconfig en0 | awk '/ether/{print $2}')"
            echo "Computer Model : $(sysctl -n hw.model)"
            echo "RAM : $(sysctl -n hw.memsize | awk '{print $0/1024/1024/1024 " GB"}')"
            echo "Disk : $(df -h / | awk '/\// {print $2}')"
            teamviewer_id=$(teamviewer --info 2>/dev/null | awk '/TeamViewer ID:/{print $NF}')
            if [ -n "$teamviewer_id" ]; then
                echo "Teamviewer ID : $teamviewer_id"
            else
                echo "Teamviewer ID : Not installed or corrupted"
            fi
            ;;
        2)
    echo "Checking for updates..."
    
    if [ "$mac" = true ]; then
        # Check for updates
        update_output=$(softwareupdate -l 2>&1)
        
        # Check if already up-to-date
        if [[ $update_output == *"No new software available"* ]]; then
            echo "Your macOS is already up to date."
        else
            echo "Updating macOS..."
            echo " "
            echo "Now go to Settings -> General -> Software Update "
            softwareupdate -i -a
            echo "Update completed."
            # Display current macOS version
            echo "Current macOS version: $(sw_vers -productName) $(sw_vers -productVersion)"
        fi
    else
        echo "This feature is available only on macOS."
    fi
    ;;

      
    3)
            echo "Installing new software..."
            # Add software installation logic here
            ;;
    4)
            echo "Sending host-master..."

            # Read form_url from config.txt
            config_file="config.txt"
            if [ -f "$config_file" ]; then
                form_url=$(jq -r '.form_url' "$config_file")
            else
                echo "Config file 'config.txt' not found or malformed."
                exit 1
            fi

        # Collecting information
            computer_name=$(hostname)
            manufacturer="Apple"
            serial_number=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
            os=$(sw_vers -productName) $(sw_vers -productVersion)
            mac_address=$(ifconfig en0 | awk '/ether/{print $2}')
            computer_model=$(sysctl -n hw.model)
            ram=$(sysctl -n hw.memsize | awk '{print $0/1024/1024/1024 " GB"}')
            disk=$(df -h / | awk '/\// {print $2}')
            teamviewer_id=$(teamviewer --info 2>/dev/null | awk '/TeamViewer ID:/{print $NF}')
            if [ -n "$teamviewer_id" ]; then
                teamviewer_info="Teamviewer ID : $teamviewer_id"
            else
                teamviewer_info="Teamviewer ID : Not installed or corrupted"
            fi
            
            # Constructing data for the Google Form
            data="entry.699254382=$computer_name&entry.2138566546=$manufacturer&entry.-1849484556=$serial_number&entry.1348721493=$os&entry.-1168987738=$mac_address&entry.2105787087=$computer_model&entry.-537334872=$ram&entry.819986346=$disk&entry.2009743612=$teamviewer_info"
            
            # Sending data using curl
            curl -s -d "$data" "$form_url" > /dev/null
            
            echo "Host-master data sent successfully!"
                ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
    echo
done
