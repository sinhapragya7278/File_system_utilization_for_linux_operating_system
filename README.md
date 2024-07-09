# Linux File System Utilization Script

This repository contains a shell script designed to automate the process of checking file system utilization on a Linux server, particularly focusing on the `/var` directory. The script connects to the server, evaluates disk usage, and performs actions based on the file and directory characteristics.

## Alert Scenario
- **Alert Description:** `XXXXX : File system (var) is 100% full`

## Steps Performed by the Script

### 1. Alert Reception
The script simulates the reception of an alert indicating that the `/var` file system is 100% full.

### 2. Connect to the Server
The script connects to the server using SSH. Ensure you have the necessary SSH credentials and access.

### 3. Check Directory Usage
The script checks directories in the `/var` file system to identify those consuming more than 80% usage.

### 4. Check Sub-folders
For directories with usage above 80%, the script lists sub-folders consuming more than 2.0 GB.

### 5. Check Files
Within each sub-folder, the script identifies files consuming more than 2.0 GB and checks their last modification dates.

### 6. Conditional Actions
- **Current Date:** If a file's last modification date is the current date, the script prints "No Action to be taken" and resolves the incident, assigning it to "InfraOpsAutomation".
- **Older Date:** If a file's last modification date is older than the current date, the script zips the file, prints "Zipped the file and hence re-assigning the ticket to the Linux Ops", and assigns the incident to "Linux Ops".

## Script Usage

### Prerequisites
- Ensure you have SSH access to the target server.
- The executing user must have the necessary permissions to check disk usage and manage files.

### Execution
1. Clone this repository to your local machine:
    ```bash
    git clone https://github.com/yourusername/linux-file-system-utilization.git
    cd linux-file-system-utilization
    ```

2. Make the script executable:
    ```bash
    chmod +x file_system_check.sh
    ```

3. Run the script:
    ```bash
    ./file_system_check.sh
    ```

### Script Code

Here is the complete shell script for reference:

```bash
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
dirs_above_80=\$(df -h | grep '/var' | awk '{print \$5}' | sed 's/%//')

if [ "\$dirs_above_80" -gt 80 ]; then
    echo "Directories in /var consuming more than 80% usage:"
    du -sh * | sort -hr | awk '{if (\$1 ~ /[0-9]+G/ && \$1+0 > 2.0) print \$0}'

    # Check sub-folders consuming more than 2.0 GB
    sub_folders=\$(du -sh * | sort -hr | awk '{if (\$1 ~ /[0-9]+G/ && \$1+0 > 2.0) print \$2}')

    for sub_folder in \$sub_folders; do
        cd \$sub_folder
        echo "Checking sub-folder: \$sub_folder"

        # Check files in the sub-folder consuming more than 2.0 GB
        large_files=\$(find . -type f -size +2G)

        for file in \$large_files; do
            file_date=\$(stat -c %y "\$file" | cut -d' ' -f1)
            current_date=\$(date +%F)

            if [ "\$file_date" == "\$current_date" ]; then
                echo "No action to be taken for file: \$file"
                # Resolve the incident and assign to InfraOpsAutomation
                echo "Resolving incident and assigning to InfraOpsAutomation"
            else
                # Zip the file and reassign the ticket to Linux Ops
                zip "\${file}.zip" "\$file"
                echo "Zipped the file: \$file and reassigning the ticket to Linux Ops"
                # Reassign the incident
            fi
        done
        cd ..
    done
else
    echo "No directories in /var are consuming more than 80% usage."
fi

EOF
# This `README.md` file provides a comprehensive explanation of the shell script, its purpose, the steps it performs, and how to use it. Adjust the repository URL, server address, and username as needed.
