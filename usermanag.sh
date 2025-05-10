#!/bin/bash
# Main script 
# Ensure the script is executed as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Source the functions file (assumed to be in the same directory)
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/user_functions.sh"

# Function: Display the menu
display_menu() {
    echo "-----------------------------------------"
    echo "         User Management System          "
    echo "-----------------------------------------"
    echo "1) Show System Information"
    echo "2) List Users with /bin/bash Shell"
    echo "3) Search for a User"
    echo "4) Add User"
    echo "5) Delete User (with Home Backup)"
    echo "6) Show User Details"
    echo "7) Change User Password"
    echo "8) Lock User"
    echo "9) Unlock User"
    echo "10) Exit"
    echo "-----------------------------------------"
    read -p "Enter your choice [1-10]: " choice
    echo ""
}


# Interactive menu loop
while true; do
    display_menu
        case "$choice" in
        1) show_system_info ;;
        2) list_bash_users ;;
        3) 
            read -p "Enter username to search: " username
            search_user "$username"
            ;;
        4) 
            read -p "Enter username to add: " username
            add_user "$username"
            ;;
        5) 
            read -p "Enter username to delete: " username
            delete_user "$username"
            ;;
        6) 
            read -p "Enter username to show details: " username
            show_user_details "$username"
            ;;
        7) 
            read -p "Enter username to change password: " username
            change_user_password "$username"
            ;;
        8) 
            read -p "Enter username to lock: " username
            lock_user "$username"
            ;;
        9) 
            read -p "Enter username to unlock: " username
            unlock_user "$username"
            ;;
        10)
            echo "Exiting User Management. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a number between 1 and 10."
            ;;
    esac

    echo ""
    read -p "Press Enter to continue..." pause
    echo ""
done
