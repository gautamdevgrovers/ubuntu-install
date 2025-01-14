#!/bin/bash
nmcli device wifi connect "daffodilsez_5gz" password RockOn4321
firefox https://172.18.1.1:8090

echo "Script started."

# Pause for 10 seconds
#sleep 18

#echo "Resuming script after 18 seconds."

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Update package list
echo "Updating package list..."
sudo apt update
sudo apt install wget curl -y

# Install Google Chrome
if ! command_exists google-chrome; then
    echo "Installing Google Chrome..."
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt update
    sudo apt install -y google-chrome-stable
    sudo apt install -f
else
    echo "Google Chrome is already installed."
fi

# Install AnyDesk
ANYDESK_DOWNLOAD_PAGE="https://anydesk.com/en/downloads/linux"
DEB_FILE="anydesk_latest_amd64.deb"

# Update system packages
echo "Updating system packages..."
sudo apt update -y

# Fetch the latest .deb file URL
echo "Fetching the latest AnyDesk download link..."
LATEST_URL=$(curl -s $ANYDESK_DOWNLOAD_PAGE | grep -oP 'https://download\.anydesk\.com/linux/anydesk_.*?amd64\.deb' | head -1)

if [ -z "$LATEST_URL" ]; then
    echo "Failed to fetch the latest AnyDesk download link. Please check the website."
    exit 1
fi

echo "Latest AnyDesk URL: $LATEST_URL"

# Download the latest AnyDesk .deb package
echo "Downloading AnyDesk..."
wget -O $DEB_FILE $LATEST_URL

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download AnyDesk. Please check the URL."
    exit 1
fi

# Install the .deb package
echo "Installing AnyDesk..."
sudo dpkg -i $DEB_FILE

# Fix any dependency issues
echo "Fixing dependencies..."
sudo apt-get install -f -y

# Verify installation
echo "Verifying AnyDesk installation..."
if command -v anydesk &> /dev/null; then
    echo "AnyDesk has been installed successfully!"
else
    echo "AnyDesk installation failed. Please check for errors."
    exit 1
fi
# Install Git
if ! command_exists git; then
    echo "Installing Git..."
    sudo apt install -y git
else
    echo "Git is already installed."
fi

# Install Visual Studio Code
if ! command_exists code; then
    echo "Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode-keyring.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update
    sudo apt install -y code
    sudo apt install -f
else
    echo "Visual Studio Code is already installed."
fi
serial_number=$(sudo dmidecode -t system | grep "Serial Number" | awk '{print $3}')

if [ -z "$serial_number" ]; then
    echo "Failed to retrieve the serial number."
    exit 1
fi
# Set the hostname to the serial number
new_hostname="$serial_number"
# Update the hostname in the /etc/hostname file
echo "$new_hostname" | sudo tee /etc/hostname
# Update the hostname in the current session
sudo hostnamectl set-hostname "$new_hostname"
# Update the /etc/hosts file with the new hostname
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/g" /etc/hosts
echo "Hostname has been changed to $new_hostname"
#echo "v2.locomo.io"
#echo "172.18.1.1:8090"
#echo "https://sites.google.com/a/daffodilsw.com/hr-policies/home"
#google-chrome https://v2.locomo.io https://172.18.1.1:8090 https://sites.google.com/a/daffodilsw.com/hr-policies/home


# Clean up
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo "Installation completed!"
