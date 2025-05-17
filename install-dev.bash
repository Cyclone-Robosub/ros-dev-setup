#!/usr/bin/env bash
set -e

# List of standard Ubuntu packages to check/install
PACKAGES=(
  python3
  build-essential
  ninja-build
  cmake
  ros-dev-tools
)

# Function to check if a package is installed
is_installed() {
  dpkg -s "$1" &> /dev/null
}

# Update apt cache once at start
sudo apt update

# Install any missing standard packages
for pkg in "${PACKAGES[@]}"; do
  if ! is_installed "$pkg"; then
    echo "Installing missing package: $pkg"
    sudo apt install -y "$pkg"
  else
    echo "Package '$pkg' is already installed"
  fi
done

# Check/install ROS 2 Desktop (ros-jazzy-desktop)
if ! is_installed ros-jazzy-desktop; then
  echo "ros-jazzy-desktop not found; setting up ROS 2 Jazzy repositories and keys"

  # Ensure Universe repo is enabled (required by ROS docs)
  sudo apt install -y software-properties-common          # :contentReference[oaicite:7]{index=7}
  sudo add-apt-repository universe                         # :contentReference[oaicite:8]{index=8}

  # Add ROS 2 GPG key and repository
  sudo apt install -y curl                                 # :contentReference[oaicite:9]{index=9}
  sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg         # :contentReference[oaicite:10]{index=10}

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu \
    $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null  # :contentReference[oaicite:11]{index=11}

  # Update and install ROS desktop
  sudo apt update                                          # :contentReference[oaicite:12]{index=12}
  sudo apt install -y ros-jazzy-desktop                    # :contentReference[oaicite:13]{index=13}
else
  echo "ros-jazzy-desktop is already installed"
fi

# Ensure ROS setup is sourced in ~/.bashrc
SETUP_LINE="source /opt/ros/jazzy/setup.bash"
if ! grep -Fxq "$SETUP_LINE" ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo "# Source ROS 2 Jazzy setup" >> ~/.bashrc
  echo "$SETUP_LINE"        >> ~/.bashrc                  # :contentReference[oaicite:14]{index=14}
  echo "Appended ROS setup to ~/.bashrc"
else
  echo "ROS setup already present in ~/.bashrc"
fi

echo "All done! Please restart your terminal or run '$SETUP_LINE' to begin using ROS 2 Jazzy."
