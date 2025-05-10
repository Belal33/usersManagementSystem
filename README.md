# 🛠️ User Management Shell Script Project

This project is a bash-based user management system created as part of a shell scripting course. It provides a menu-driven interface for managing users on a Linux system and includes error handling and permission checks.

## 📋 Features

The script supports the following user management operations:

1. **Show System Information**  
2. **List Users with `/bin/bash` Shell**
3. **Search for a User**
4. **Add a New User**
5. **Delete a User (with Home Directory Backup)**
6. **Show User Details**
7. **Change User Password**
8. **Lock a User Account**
9. **Unlock a User Account**
10. **Exit the Program**

Each operation is handled through individual functions for modularity and clarity.

## 🔄 Menu

- The menu reappears after each operation.
- Users can interactively choose actions from the list.

## ⚠️ Error Handling

The script includes handling for the following edge cases:

- Invalid input detection
- User existence verification
- Backup directory validation
- Permission checks (`sudo`/root requirement)

## 🧱 Project Structure

usersManagementSystem/
│
├── usermanag.sh # Main interactive script
├── manage_functions.sh # All function definitions
├── README.md # Project documentation
├── project_nustructions.png # Project Instructions


## 🔐 Requirements

- Must be run as `root` (UID 0)
- Bash shell environment (tested on Ubuntu)
- Mail utils installed for future enhancements (e.g., user notifications)

## 🚀 How to Run

1. **Clone the repository:**
   git clone https://github.com/yourusername/user-management.git
   cd user-management
Make the scripts executable:
chmod +x main.sh user_functions.sh
Run the main script with root privileges:
sudo ./main.sh


✅ Sample Output
-----------------------------------------
         User Management System          
-----------------------------------------
1) Show System Information
2) List Users with /bin/bash Shell
3) Search for a User
...
10) Exit
-----------------------------------------
Enter your choice [1-10]: 
📌 Notes
Backup files will be stored in a backup/ directory inside the script folder (can be changed).

Ensure proper permissions and disk space for user backups.

📄 License
This project is provided as-is for educational purposes. Feel free to fork and improve it!
