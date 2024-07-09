#!/bin/bash

# Sample Alert Received
alert_desc="XXXXX : File system (var) is 100% full"
echo "Alert Received: $alert_desc"

# Connect to the CI (assume SSH connection if needed)
# Replace with actual server and user details
server="your_server_address"
user="your_username"
ssh $user@$server << EOF

# Check directories in /var consuming more than 80%
cd /var
dirs_above_80=$(df -h | grep '/var' | awk '{print $5}' | sed 's/%//')

if [ "$dirs_above_80" -gt 80 ]; then
    echo "Directories in /var consuming more than 80% usage:"
    du -sh * | sort -hr | awk '{if ($1 ~ /[0-9]+G/ && $1+0 > 2.0) print $0}'

    # Check sub-folders consuming more than 2.0 GB
    sub_folders=$(du -sh * | sort -hr | awk '{if ($1 ~ /[0-9]+G/ && $1+0 > 2.0) print $2}')

    for sub_folder in $sub_folders; do
        cd $sub_folder
        echo "Checking sub-folder: $sub_folder"

        # Check files in the sub-folder consuming more than 2.0 GB
        large_files=$(find . -type f -size +2G)

        for file in $large_files; do
            file_date=$(stat -c %y "$file" | cut -d' ' -f1)
            current_date=$(date +%F)

            if [ "$file_date" == "$current_date" ]; then
                echo "No action to be taken for file: $file"
                # Resolve the incident and assign to InfraOpsAutomation
                echo "Resolving incident and assigning to InfraOpsAutomation"
            else
                # Zip the file and reassign the ticket to Linux Ops
                zip "${file}.zip" "$file"
                echo "Zipped the file: $file and reassigning the ticket to Linux Ops"
                # Reassign the incident
            fi
        done
        cd ..
    done
else
    echo "No directories in /var are consuming more than 80% usage."
fi

EOF
