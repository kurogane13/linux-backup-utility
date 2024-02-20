#!/bin/bash

# Function to print banner
print_banner() {
    echo
    date
    echo
    echo "=================================="
    echo "  LINUX Backup and Restore Utility"
    echo
    echo "DISCLAIMER: USE WITH CAUTION AND"
    echo "AT YOUR OWN RISK"
    echo "=================================="
    echo
}

# Function to display directory sizes
display_directory_sizes() {
    directory="$1"
    size=$(du -sh "$directory" | awk '{print $1}')
    echo "Directory size of $directory: $size"
}

# Backup function
backup() {
    # Display banner
    print_banner

    # Show submenu options
    echo "Backup Menu:"
    echo
    echo "1. Proceed to backup"
    echo "2. Go back to main menu"
    echo

    # Get user choice
    read -p "Enter your choice (1-2): " choice

    case $choice in
        1)
            # Show available directories
            echo "Directories available in the current directory:"
            ls -d */

            # Ask for target directory
            echo
            read -p $'\nEnter the target directory to back up: ' target_directory
            if [ ! -d "$target_directory" ]; then
                echo "Error: Target directory '$target_directory' not found."
                return
            fi

            # Calculate total size of target directory
            echo
            display_directory_sizes "$target_directory"

            # Ask for backup folder
            echo
            read -p $'Enter the backup data folder name: ' backup_folder

            ls "$backup_folder" &> /dev/null
            if [ $? -eq 0 ]; then
                echo
            else
                echo
                read -p "Backup folder '$backup_folder' does not exist. Do you want to create it? (yes/no): " create_backup_folder

                if [ "$create_backup_folder" = "yes" ]; then
                    mkdir -p "$backup_folder" > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        echo "Error: Failed to create backup folder '$backup_folder'. Backup aborted."
                        return
                    fi
                else
                    echo "Backup aborted."
                    return
                fi
            fi

            # Confirm backup
            echo
            echo "WARNING: YOU ARE ABOUT TO RUN A BACKUP ON THIS SYSTEM. PLEASE READ CAREFULLY AND CONFIRM OR DECLINE THE OPERATION."
            echo
            read -p "Back up ALL data in the folder '$target_directory' to the folder '$backup_folder'? (yes/no): " confirm_backup
            if [ "$confirm_backup" != "yes" ]; then
                echo "Backup aborted."
                return
            fi

            # Create datetime-stamped directory for backup
            underscore="_"
            datetime=$(date +"%Y-%m-%d_%H-%M-%S")
            backup_directory=$backup_folder$underscore$datetime
            #Create backup folder with datetime timestamp
            mkdir -p $backup_directory
            # Perform backup
            rsync_output=$(rsync -av "$target_directory/" "$backup_directory" 2>&1)
            #Force delete the backup folder
            rm -r -f "$backup_folder" > /dev/null 2>&1
            echo $rsync_output

            if [ $? -ne 0 ]; then
                echo "Error: Failed to perform backup."
                echo "Debugging information:"
                echo "$rsync_output"
                return
            fi

            # Display backup completion message

            echo "Backup completed successfully."
            display_directory_sizes "$backup_directory"
            ;;
        2)  return
            ;;
        *)
            echo "Invalid choice. Please enter a number from 1 to 2."
            ;;
    esac
}

# Restore function
restore() {
    # Display banner
    print_banner

    # Show submenu options
    echo "Restore Menu:"
    echo
    echo "1. Proceed to restore"
    echo "2. Go back to main menu"
    echo

    # Get user choice
    read -p "Enter your choice (1-2): " choice

    case $choice in
        1)
            # Show available directories
            echo "Directories available in the current directory:"
            ls -d */

            # Ask for backup folder
            read -p $'\nEnter the backed up data folder: ' backup_folder
            if [ ! -d "$backup_folder" ]; then
                echo "Error: Backup folder '$backup_folder' not found."
                return
            fi

            # Calculate total size of backup folder
            echo
            display_directory_sizes "$backup_folder"

            # Ask for restore folder
            echo
            read -p $'Provide a restore existing folder name: ' restore_folder
            ls "$restore_folder" &> /dev/null
            if [ $? -eq 0 ]; then
                echo
            else
                read -p "Restore folder '$restore_folder' does not exist. Do you want to create it? (yes/no): " create_restore_folder
                if [ "$create_restore_folder" = "yes" ]; then
                    mkdir -p "$restore_folder" > /dev/null 2>&1
                else
                    echo "Restore aborted."
                    return
                fi
            fi

            # Confirm restore
            echo
            echo "WARNING: YOU ARE ABOUT TO RUN A RESTORE OPERATION ON THIS SYSTEM. PLEASE READ CAREFULLY AND CONFIRM OR DECLINE THE OPERATION. THE RESTORATION WOUN´T DELETE THE DATA FROM THE SOURCE BACKUP FOLDER: $backup_folder"
            echo
            read -p "Restore ALL data from the '$backup_folder' to the '$restore_folder'? (yes/no): " confirm_restore
            if [ "$confirm_restore" != "yes" ]; then
                echo "Restore aborted."
                return
            fi

            # Create datetime-stamped directory for restored
            underscore="_"
            datetime=$(date +"%Y-%m-%d_%H-%M-%S")
            restored_directory=$restore_folder$underscore$datetime
            #Create backup folder with datetime timestamp
            mkdir -p $restored_directory

            # Perform restore
            rsync -av "$backup_folder/" "$restored_directory"

            rsync_output=$(rsync -av "$backup_folder/" "$restored_directory" 2>&1)
            #Force delete the restore folder
            rm -r -f "$restore_folder" > /dev/null 2>&1
            echo $rsync_output

            if [ $? -ne 0 ]; then
                echo "Error: Failed to perform restore."
                echo "Debugging information:"
                echo "$rsync_output"
                return
            fi

            # Display restore completion message
            echo "Restore completed successfully."
            display_directory_sizes "$restored_directory"
            ;;
        2)
            return
            ;;
        *)
            echo "Invalid choice. Please enter a number from 1 to 2."
            ;;
    esac
}

# Main menu
main_menu() {
    while true; do
        print_banner

        # Display options
        echo "Main Menu:"
        echo
        echo "1. Backup"
        echo "2. Restore"
        echo "3. Exit"
        echo

        # Get user choice
        read -p "Enter your choice (1-3): " choice

        # Perform actions based on choice
        case $choice in
            1) backup ;;
            2) restore ;;
            3) exit ;;
            *) echo "Invalid choice. Please enter a number from 1 to 3."
               read -p "Press Enter to return to the main menu..." ;;
        esac
    done
}

# Start the script by displaying the main menu
main_menu
