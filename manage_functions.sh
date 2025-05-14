# Function: show_system_info

show_system_info() {
    echo "╔══════════════════════ System Information ══════════════════════╗"
    # Display the system's hostname
    printf "║ %-20s: %-40s ║\n" "Hostname" "$(hostname)"
    # Show the operating system name and version from os-release file
    printf "║ %-20s: %-40s ║\n" "OS Details" "$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    # Display the Linux kernel version
    printf "║ %-20s: %-40s ║\n" "Kernel Version" "$(uname -r)"
    # Show the system's CPU architecture (32/64 bit)
    printf "║ %-20s: %-40s ║\n" "Architecture" "$(uname -m)"
    # Display how long the system has been running
    printf "║ %-20s: %-40s ║\n" "System Uptime" "$(uptime -p | cut -c4-)"
    # Count the number of users currently logged into the system
    printf "║ %-20s: %-40s ║\n" "Active Users" "$(who | wc -l) users"
    # Show current memory usage (used/total)
    printf "║ %-20s: %-40s ║\n" "Memory Usage" "$(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    # Display root partition disk usage (used/total and percentage)
    printf "║ %-20s: %-40s ║\n" "Disk Usage" "$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    # Show system load averages for the past 1, 5, and 15 minutes
    printf "║ %-20s: %-40s ║\n" "CPU Load" "$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')"
    # Display the date and time of the last system boot
    printf "║ %-20s: %-40s ║\n" "Last Boot" "$(who -b | awk '{print $3, $4}')"
    echo "╚════════════════════════════════════════════════════════════════╝"
    return 0
}

# Function: list_bash_users
list_bash_users() {
    echo "╔══════════════ Users with /bin/bash shell ══════════════╗"
    echo "║ USERNAME       UID        HOME DIRECTORY               ║"
    echo "╠════════════════════════════════════════════════════════╣"
    awk -F: '$7 == "/bin/bash" {
        printf "║ %-14s %-10s %-28s ║\n", $1, $3, $6
    }' /etc/passwd
    echo "╚════════════════════════════════════════════════════════╝"
    
    # Show total count
    local total=$(awk -F: 'BEGIN {count=0} $7 == "/bin/bash" {count++} END {print count}' /etc/passwd)
    echo "Total bash users: $total"
    return 0
}

# Function: search_user
search_user() {
    local username=""

    # Prompt for username
    read -p "Enter username to search: " username

    # Check if input is empty
    if [ -z "$username" ]; then
        echo "Error: Username cannot be empty."
    fi

    # Check if username contains invalid characters
    if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: Username contains invalid characters."
    fi



    # Get user info from passwd file
    local user_info=$(cat /etc/passwd | grep "^$username:")

    # Check if user exists
    if [ -z "$user_info" ]; then
        echo "Error: User '$username' not found."
        return 1
    fi


    echo "╔════════════════ User Information ═══════════════╗"
    printf "║ %-15s: %-30s ║\n" "Username" "$username"
    printf "║ %-15s: %-30s ║\n" "User ID" "$(echo "$user_info" | cut -d: -f3)"
    
    echo "╚═════════════════════════════════════════════════╝"
    return 0
}


# Function: add_user
add_user() {
    local username
    local password1
    local password2

    # Prompt for username
    read -p "Enter username to add: " username
    # Check if input is empty
    # Check if username is too short
    if [[ ${#username} -lt 3 ]]; then
        echo "Username must be at least 3 characters long."
        return 1
    fi
    # Check if username contains invalid characters
    if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Username contains invalid characters."
        return 1
    fi
    # Check if username is already taken
    if grep -q "^$username:" /etc/passwd; then
        echo "User '$username' already exists."
        return 1
    fi
    

    # Password prompt with confirmation
    while true; do
        read -sp "Enter password for new user (or 'q' to quit): " password1
        echo
        if [[ "$password1" == "q" ]]; then
            echo "Password setup cancelled."
            return 1
        fi
        # Validate password strength
        if [[ ${#password1} -lt 8 ]]; then
            echo "Password must be at least 8 characters long."
            continue
        fi

        read -sp "Confirm password: " password2
        echo
        if [[ "$password2" == "q" ]]; then
            echo "Password setup cancelled."
            return 1
        fi

        
        
        [[ "$password1" == "$password2" ]] && break
        echo "Passwords don't match. Please try again."
    done




    # Create user with home directory and bash shell
    if useradd -m -s /bin/bash "$username"; then
        # Set password
        echo "$username:$password1" | chpasswd
        
        # Force password change on first login
        passwd -e "$username"
        
        
        
        # Display new user details with box drawing characters
        echo "╔════════════════ New User Details ═══════════════╗"
        printf "║ %-15s: %-30s ║\n" "Username" "$username"
        printf "║ %-15s: %-30s ║\n" "Home Directory" "/home/$username"
        printf "║ %-15s: %-30s ║\n" "Shell" "/bin/bash"
        echo "╚═════════════════════════════════════════════════╝"
        echo "User '$username' created successfully!"
        echo "User will be prompted to change password on first login."
    else
        echo "Failed to add user '$username'."
        return 1
    fi
    return 0
}



# Function: delete_user
delete_user() {
    local username
    
    read -p "Enter username to delete: " username

    local home_dir="/home/$username"
    local backup_dir="/backup/users_backups/${username}_$(date +%Y-%m-%d)"

    # Input validation
    if [[ -z "$username" ]]; then
        echo "Error: Username cannot be empty."
        return 1
    fi

    if [[ "$username" == "root" ]]; then
        echo "Error: Cannot delete root user."
        return 1
    fi

    # Check if user exists
    if ! grep -q "^$username:" /etc/passwd; then
        echo "Error: User '$username' does not exist."
        return 1
    fi

    # Check if user is currently logged in
    if who | grep -q "^$username "; then
        echo "Warning: User '$username' is currently logged in."
        read -p "Do you still want to proceed? (y/N): " confirm
        [[ "$confirm" != "y" && "$confirm" != "Y" ]] && return 1
    fi

    # Ask for confirmation
    read -p "Are you sure you want to delete user '$username'? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Create backup directory with date
    if [ -d "$home_dir" ]; then
        mkdir -p "$backup_dir"
        echo "Creating backup in $backup_dir..."
        
        # Create backup with timestamp
        backup_file="$backup_dir/${username}_backup_$(date +%H%M%S).tar.gz"
        if tar czf "$backup_file" "$home_dir" 2>/dev/null; then
            echo "✅ Home directory backed up to $backup_file"
        else
            echo "Backup failed. Aborting deletion."
            return 1
        fi
    else
        echo "No home directory found for $username"
    fi

    # Delete user and their home directory
    if userdel -r "$username" 2>/dev/null; then
        echo " User '$username' and their home directory deleted successfully."
        echo "  Backup location: $backup_file"
    else
        echo "Failed to delete user '$username'."
        return 1
    fi

    return 0
}
# Function: show_user_details

show_user_details() {
    local username=""

    # Prompt for username
    read -p "Enter username to search: " username

    # Check if input is empty
    if [ -z "$username" ]; then
        echo "Error: Username cannot be empty."
    fi

    # Check if username contains invalid characters
    if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: Username contains invalid characters."
    fi



    # Get user info from passwd file
    local user_info=$(cat /etc/passwd | grep "^$username:")

    # Check if user exists
    if [ -z "$user_info" ]; then
        echo "Error: User '$username' not found."
        return 1
    fi

    # get user groups
    # Get group names and IDs as arrays
    local group_names=($(id -Gn "$username"))
    local group_ids=($(id -G "$username"))

    echo "╔════════════════ User Groups ════════════════╗"
    echo "║ GROUP NAME         GROUP ID                 ║"
    echo "╠═════════════════════════════════════════════╣"
    # Loop through arrays to print each pair
    for i in "${!group_names[@]}"; do
        printf "║ %-18s %-24s ║\n" "${group_names[$i]}" "${group_ids[$i]}"
    done
    echo "╚═════════════════════════════════════════════╝"


    echo "╔════════════════ User Information ═══════════════╗"
    printf "║ %-15s: %-30s ║\n" "Username" "$username"
    printf "║ %-15s: %-30s ║\n" "User ID" "$(echo "$user_info" | cut -d: -f3)"
    printf "║ %-15s: %-30s ║\n" "Main Group ID" "$(echo "$user_info" | cut -d: -f4)"
    printf "║ %-15s: %-30s ║\n" "Home Directory" "$(echo "$user_info" | cut -d: -f6)"
    printf "║ %-15s: %-30s ║\n" "Shell" "$(echo "$user_info" | cut -d: -f7)"
    # printf "║ %-15s: %-30s ║\n" "Groups" "$group_names"

    # Check if account is locked
    if passwd -S "$username" | grep -q "L"; then
        printf "║ %-15s: %-30s ║\n" "Status" "Locked"
    else
        printf "║ %-15s: %-30s ║\n" "Status" "Active"
    fi
    echo "╚═════════════════════════════════════════════════╝"

    
    return 0
}

# Function: change_user_password
change_user_password() {
    local username
    # Prompt for username
    read -p "Enter username to change password: " username

    # Check if input is empty
    if [[ -z "$username" ]]; then
        echo "Error: Username cannot be empty."
        return 1
    fi
    # Check if user exists
    if ! grep -q "^$username:" /etc/passwd; then
        echo "User '$username' does not exist."
        return 1
    fi


    # Password prompt with confirmation
    while true; do
        read -sp "Enter password for new user (or 'q' to quit): " password1
        echo
        if [[ "$password1" == "q" ]]; then
            echo "Password setup cancelled."
            return 1
        fi
        # Validate password strength
        if [[ ${#password1} -lt 8 ]]; then
            echo "Password must be at least 8 characters long."
            continue
        fi

        read -sp "Confirm password: " password2
        echo
        if [[ "$password2" == "q" ]]; then
            echo "Password setup cancelled."
            return 1
        fi

        
        
        [[ "$password1" == "$password2" ]] && break
        echo "Passwords don't match. Please try again."
    done
    # Change user password
    echo "$username:$password1" | chpasswd
    if [ $? -eq 0 ]; then
        echo "Password for user '$username' changed successfully."
    else
        echo "Failed to change password for user '$username'."
        return 1
    fi

}


# Function: lock_user
lock_user() {
    local username

    # Prompt for username
    read -p "Enter username to lock: " username

    # Input validation
    if [[ -z "$username" ]]; then
        echo "Error: Username cannot be empty."
        return 1
    fi

    if [[ "$username" == "root" ]]; then
        echo "Error: Cannot lock root user account."
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist."
        return 1
    fi

    # Check if user is already locked
    if passwd -S "$username" | grep -q "L"; then
        echo "User '$username' is already locked."
        return 0
    fi

    # Check if user is currently logged in
    if who | grep -q "^$username "; then
        echo "Warning: User '$username' is currently logged in."
        read -p "Do you still want to proceed with locking? (y/N): " confirm
        [[ "$confirm" != [yY] ]] && return 1
    fi

    # Lock the user account
    if usermod -L "$username" 2>/dev/null; then
        echo "╔═════════════════ Account Locked ════════════════╗"
        printf "║ %-15s: %-30s ║\n" "Username" "$username"
        printf "║ %-15s: %-30s ║\n" "Status" "$(passwd -S "$username" | awk '{print $2}')"
        echo "╚═════════════════════════════════════════════════╝"
        echo "User cannot log in with password authentication"
    else
        echo "Failed to lock user '$username'. Please check your permissions."
        return 1
    fi

    return 0
}
# Function: unlock_user
unlock_user() {
    local username

    # Prompt for username
    read -p "Enter username to unlock: " username

    # Input validation
    if [[ -z "$username" ]]; then
        echo "Error: Username cannot be empty."
        return 1
    fi

    if [[ "$username" == "root" ]]; then
        echo "Error: Cannot modify root user account."
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist."
        return 1
    fi

    # Check if account is already unlocked
    if passwd -S "$username" | grep -q "P"; then
        echo "User '$username' is already unlocked."
        return 0
    fi

    # Unlock the user account
    if usermod -U "$username" 2>/dev/null; then
        echo "╔════════════════ Account Unlocked ═══════════════╗"
        printf "║ %-15s: %-30s ║\n" "Username" "$username"
        printf "║ %-15s: %-30s ║\n" "Status" "$(passwd -S "$username" | awk '{print $2}')"
        echo "╚═════════════════════════════════════════════════╝"
        echo "User can log in with password authentication"
    else
        echo "Failed to unlock user '$username'. Please check your permissions."
        return 1
    fi

    return 0
}
# Function: exit_program
exit_program() {
    echo "Exiting User Management. Goodbye!"
    exit 0
}
