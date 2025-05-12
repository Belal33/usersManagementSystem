# Function: show_system_info
show_system_info() {
    echo "===== System Information ====="
    echo "Hostname      : $(hostname)"
    echo "Operating System : $(uname -o)"
    echo "Kernel Version   : $(uname -r)"
    echo "Architecture     : $(uname -m)"
    echo "Uptime           : $(uptime -p)"
    echo "Current Users    : $(who | wc -l)"
    echo "=============================="
}
# Function: list_bash_users
list_bash_users() {
    echo "===== Users with /bin/bash shell ====="
    awk -F: '$7 == "/bin/bash" { print $1 }' /etc/passwd
    echo "======================================"
}
# Function: search_user
search_user() {
    local username="$1"
    if id "$username" &>/dev/null; then
        echo "✅ User '$username' exists on the system."
    else
        echo "❌ User '$username' does not exist."
    fi
}
# Function: add_user
add_user() {
    local username="$1"
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "❌ User '$username' already exists."
        return 1
    fi

    # Create user with home directory
    if useradd -m "$username"; then
        echo "✅ User '$username' added successfully."
        # Optionally, set a default password (you can prompt if preferred)
        echo "$username:1234" | chpasswd
        echo "ℹ️  Default password '1234' has been set. Please change it."
    else
        echo "❌ Failed to add user '$username'."
        return 1
    fi
}
# Function: delete_user
delete_user() {
    local username="$1"
    local home_dir="/home/$username"
    local backup_dir="/backup"

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "❌ User '$username' does not exist."
        return 1
    fi

    # Check if home directory exists
    if [ ! -d "$home_dir" ]; then
        echo "⚠️  Home directory $home_dir not found. Proceeding without backup."
    else
        # Ensure backup directory exists
        mkdir -p "$backup_dir"

        # Backup the home directory
        tar czf "$backup_dir/${username}_home_backup.tar.gz" "$home_dir"
        if [ $? -eq 0 ]; then
            echo "✅ Home directory backed up to $backup_dir/${username}_home_backup.tar.gz"
        else
            echo "❌ Failed to create backup. Aborting delete."
            return 1
        fi
    fi

    # Delete user and their home directory
    userdel -r "$username"
    if [ $? -eq 0 ]; then
        echo "✅ User '$username' deleted successfully."
    else
        echo "❌ Failed to delete user '$username'."
        return 1
    fi
}
# Function: show_user_details
show_user_details() {
    local username="$1"
    
    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "❌ User '$username' does not exist."
        return 1
    fi

    # Display user details
    echo "===== User Details for '$username' ====="
    getent passwd "$username"
    echo "========================================="
}
# Function: change_user_password
change_user_password() {
    local username="$1"
    
    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "❌ User '$username' does not exist."
        return 1
    fi

    # Prompt for new password
    read -sp "Enter new password for '$username': " new_password
    echo ""
    
    # Change the password
    echo "$username:$new_password" | chpasswd
    if [ $? -eq 0 ]; then
        echo "✅ Password for '$username' changed successfully."
    else
        echo "❌ Failed to change password for '$username'."
        return 1
    fi
}
# Function: lock_user
lock_user() {
    local username="$1"
    
    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "❌ User '$username' does not exist."
        return 1
    fi

    # Lock the user account
    usermod -L "$username"
    if [ $? -eq 0 ]; then
        echo "✅ User '$username' locked successfully."
    else
        echo "❌ Failed to lock user '$username'."
        return 1
    fi
}
# Function: unlock_user
unlock_user() {
    local username="$1"
    
    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "❌ User '$username' does not exist."
        return 1
    fi

    # Unlock the user account
    usermod -U "$username"
    if [ $? -eq 0 ]; then
        echo "✅ User '$username' unlocked successfully."
    else
        echo "❌ Failed to unlock user '$username'."
        return 1
    fi
}
# Function: exit_program
exit_program() {
    echo "Exiting User Management. Goodbye!"
    exit 0
}
