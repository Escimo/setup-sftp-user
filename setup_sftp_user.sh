#!/bin/bash
#####################################
#                                   #
# Fossa Software LLC                #
# Developer: Fossa Software LLC     #
# Contact: +380672240067            #
# Support: support@fossa.software   #
#                                   #
#####################################

# Check if username is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME=$1
SFTP_DIR="/your/real/website/dir" # PATH TO SITE DIR
GROUP="www-data"
DIR1="$SFTP_DIR/DIR1"
DIR2="$SFTP_DIR/DIR2"
DIR3="$SFTP_DIR/DIR3"

# 0. Check if the setfacl command is available and install the acl package if not installed
echo "Checking if acl package is installed"
if ! command -v setfacl &> /dev/null; then
    echo "Acl package is not installed. Installing."
    sudo apt update
    sudo apt install acl -y
else
    echo "Acl package is already installed."
fi

# 1. Check and create the user if they do not exist
grep "$USERNAME:" /etc/passwd >/dev/null
if [ $? -ne 0 ]; then
    echo "User $USERNAME not found, creating new user."
    sudo adduser --disabled-password --gecos "" $USERNAME
    echo "Creating .ssh directory for the user $USERNAME"
    sudo mkdir /home/$USERNAME/.ssh
    sudo chmod 700 /home/$USERNAME/.ssh
    sudo touch /home/$USERNAME/.ssh/authorized_keys
    sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
    sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
else
    echo "User $USERNAME already exists."
fi

# 2. Add user to www-data group
if groups $USERNAME | grep -q "\b$GROUP\b"; then
    echo "User $USERNAME is already in the group $GROUP."
else
    echo "Adding user $USERNAME to group $GROUP"
    sudo usermod -aG $GROUP $USERNAME
fi

# 3. Set SGID on the directory
if [ -d "$SFTP_DIR" ]; then
    if [ $(stat -c "%A" $SFTP_DIR | cut -c5) == "s" ]; then
        echo "SGID is already set on the directory $SFTP_DIR."
    else
        echo "Setting SGID on the directory $SFTP_DIR"
        sudo chown -R www-data:www-data $SFTP_DIR
        sudo chmod g+s $SFTP_DIR
    fi
else
    echo "Directory $SFTP_DIR does not exist."
    exit 1
fi

# 4. Set umask for the user
if sudo grep -q "umask 002" /home/$USERNAME/.bashrc; then
    echo "umask is already set for user $USERNAME."
else
    echo "Setting umask for user $USERNAME"
    echo "umask 002" | sudo tee -a /home/$USERNAME/.bashrc
fi

# 5. Set ACL for ava, ava2, and ava3 directories
if [ -d "$DIR1" ]; then
    if sudo getfacl $DIR1 | grep -q "$USERNAME:---"; then
        echo "ACL is already set for $DIR1"
    else
        echo "Setting ACL for directory $DIR1"
        sudo setfacl -m u:$USERNAME:--- $DIR1
    fi
else
    echo "Directory $DIR1 not found."
fi

if [ -d "$DIR2" ]; then
    if sudo getfacl $DIR2 | grep -q "$USERNAME:---"; then
        echo "ACL is already set for $DIR2"
    else
        echo "Setting ACL for directory $DIR2"
        sudo setfacl -m u:$USERNAME:--- $DIR2
    fi
else
    echo "Directory $DIR2 not found."
fi

if [ -d "$DIR3" ]; then
    if sudo getfacl $DIR3 | grep -q "$USERNAME:---"; then
        echo "ACL is already set for $DIR3"
    else
        echo "Setting ACL for directory $DIR3"
        sudo setfacl -m u:$USERNAME:--- $DIR3
    fi
else
    echo "Directory $DIR3 not found."
fi

# 6. Set permissions for intermediate directories (for proper site access). Example for "/your/real/website/dir"
echo "Setting permissions for intermediate directories for site access"
sudo setfacl -m u:$USERNAME:--x /your
sudo setfacl -m u:$USERNAME:--x /your/real
sudo setfacl -m u:$USERNAME:--x /your/real/website

# 7. Configure SSH for the user with ForceCommand to specify the site directory
SSH_CONFIG="/etc/ssh/sshd_config"
if grep -q "Match User $USERNAME" $SSH_CONFIG; then
    echo "SSH configuration is already set for user $USERNAME."
else
    echo "Adding SFTP configuration for user $USERNAME"
    sudo bash -c "echo '
Match User $USERNAME
    ForceCommand internal-sftp -d $SFTP_DIR
    PasswordAuthentication no
    PermitTunnel no
    AllowAgentForwarding no
    AllowTcpForwarding no
    X11Forwarding no
' >> $SSH_CONFIG"
fi

# 8. Restart SSH
echo "Restarting SSH"
sudo systemctl restart ssh

echo "User $USERNAME setup is complete."
