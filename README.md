# SFTP User Setup Script

This script automates the process of setting up an SFTP user with limited access to specific web-site directories on a server.
It configures the necessary permissions, ACLs, and SSH settings to ensure the user can only access the specified directory and cannot access restricted folders.

> [!IMPORTANT]  
> Note that you must manually add your generated SSH Public Key for the user.

## Features
- Creates a new SFTP user (if not already created).
- Adds the user to the `www-data` group.
- Configures SGID on the site directory so that files inherit the correct group ownership.
- Sets a custom `umask` for the user, ensuring the proper file permissions are applied.
- Uses `setfacl` to restrict access to specific directories (`DIR1`, `DIR2`, `DIR3`).
- Ensures the user has appropriate permissions to "pass through" intermediate directories to the site directory.
- Configures SFTP in the SSH settings, specifying the user's root directory with `ForceCommand internal-sftp`.

## Prerequisites
- Ubuntu or Debian-based server.
- SSH access with `sudo` privileges.
- `acl` package installed (the script will check and install it if necessary).

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/setup_sftp_user.git
   cd setup_sftp_user
   ```

2. **Make the script executable:**
   ```bash
   chmod +x setup_sftp_user.sh
   ```

3. **Run the script with the desired username:**
   ```bash
   ./setup_sftp_user.sh <username>
   ```

4. **After running the script:**
   - The user will be able to connect to the server via SFTP.
   - The user will automatically be placed in the site directory upon login.
   - Access to certain directories (like `DIR1`, `DIR2`, `DIR3`) will be restricted.

## Script Breakdown

- **User creation:** 
  The script creates a new user and sets up an `.ssh` directory for public key authentication.

- **Group assignment:** 
  The user is added to the `www-data` group to allow interaction with the site files.

- **Directory permissions:**
  The script ensures the correct ownership and SGID settings for the site directory, ensuring files created by the user inherit the correct group ownership.

- **Access Control Lists (ACL):**
  ACLs are applied to restrict the user's access to certain directories (`ava`, `ava2`, `ava3`).

- **SSH configuration:**
  The script modifies the SSH configuration to enforce SFTP access and sets the user's home directory to the site folder.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
