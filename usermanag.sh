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
    echo "---------------------------------"
    echo "         User Management         "
    echo "---------------------------------"
    echo "1) Add User"
    echo "2) Delete User"
    echo "3) Update User"
    echo "4) List Users"
    echo "5) Exit"
    echo "---------------------------------"
    read -p "Enter your choice [1-5]: " choice
    echo ""
}

# Interactive menu loop
while true; do
    display_menu
    case "$choice" in
        1)
            read -p "Enter username to add: " username
            add_user "$username"
            ;;
        2)
            read -p "Enter username to delete: " username
            delete_user "$username"
            ;;
        3)
            read -p "Enter username to update: " username
            read -p "Enter new shell (e.g., /bin/bash): " new_shell
            update_user "$username" "$new_shell"
            ;;
        4)
            list_users
            ;;
        5)
            echo "Exiting User Management. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a number between 1 and 5."
            ;;
    esac
    echo ""
    read -p "Press Enter to continue..." pause
    echo ""
done
