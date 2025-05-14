#!/bin/bash
#1 chech if the script is run as root
if [[ $UID -ne 0 ]];
then
	echo "This command must be run as root"
	exit 1
fi



#2 chich if the functions script is exist
FUNCSCRIPT="manage_functions.sh"
if [[ ! -f $FUNCSCRIPT ]];
then 
	echo "cant find the main file"
	exit 1
fi

#3 load the functions
source $FUNCSCRIPT

#4 Start the display options
PS3=$'\nSelect an option: '

options=( 
			"Show System Information" 
			"List Users with /bin/bash Shell" 
			"Search for a User" 
			"Add User" 
			"Delete User (with Home Backup)" 
			"Show User Details" 
			"Change User Password" 
			"Lock User" 
			"Unlock User" 
			"Exit"
		)



clear
echo "=============================================="
echo "||          Linux Users Manager             ||"
echo "=============================================="
echo "||                                         ||"
echo "|| System: $(uname -s)                     "
echo "|| Hostname: $(hostname)                   "
echo "|| Date: $(date '+%Y-%m-%d %H:%M:%S')     "
echo "||                                         ||"
echo "=============================================="
echo "Please select an operation from the menu below:"
echo "=============================================="


while true; 
do  

    select option in "${options[@]}";

    do
        if [[ $REPLY -ne 10 ]]; then
            clear
            
        fi
        echo "You selected option $REPLY: $option"
        echo "============================================"
        
        case $REPLY in
            1) 
                
                show_system_info
                break
            ;;
            2) 
                
                list_bash_users
                break
            ;;
            3) 
                
                search_user
                break
            ;;
            4) 
                
                add_user
                break
            ;;
            5) 
                
                delete_user
                break
            ;;
            6) 
                
                show_user_details
                break
            ;;
            7) 
                
                change_user_password
                break
            ;;
            8) 
                
                lock_user
                break
            ;;
            9) 
                
                unlock_user
                break
            ;;
            10) 
                exit_program
            ;;
            *) 
                
                echo "'${REPLY}' is Invalid input! Please choose a number between 1 and 10."
                break
            ;;
        esac
    done
    echo '============================================'
done


