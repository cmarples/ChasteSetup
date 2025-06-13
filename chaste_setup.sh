#!/bin/bash

# This script installs Chaste
# Important: if using WSL2, must have a wsl.config file in Windows user directory
# assigning at least 4GB of memory. This is needed for Chaste to successfully compile!

set -e  # Exit on error
cd ~

# Install dependencies
echo "Updating package lists and installing dependencies..."

# Creates/opens the file in 1 and adds the line from 2
# 1) sudo nano /etc/apt/sources.list.d/chaste.list
# 2) deb [signed-by=/usr/share/keyrings/chaste.asc] https://chaste.github.io/ubuntu noble/
echo "deb [signed-by=/usr/share/keyrings/chaste.asc] https://chaste.github.io/ubuntu noble/" | sudo tee /etc/apt/sources.list.d/chaste.list > /dev/null
sudo wget -O /usr/share/keyrings/chaste.asc https://chaste.github.io/chaste.asc

sudo apt update
sudo apt install chaste-dependencies

# Create directories
echo "Creating directory structure"
mkdir Chaste
mkdir Chaste/build
mkdir Chaste/output
mkdir Chaste/output/unit_tests

# Set Chaste output directory
EXPORT_LINE='export CHASTE_TEST_OUTPUT=~/Chaste/output'
if ! grep -Fxq "$EXPORT_LINE" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Set Chaste test output directory" >> ~/.bashrc
    echo "$EXPORT_LINE" >> ~/.bashrc
    echo "Added CHASTE_TEST_OUTPUT export to ~/.bashrc"
else
    echo "CHASTE_TEST_OUTPUT export already exists in ~/.bashrc"
fi

# General output directory
export CHASTE_TEST_OUTPUT=~/Chaste/output

# Temporary output directory for the Chaste unit tests
export CHASTE_TEST_OUTPUT="$CHASTE_TEST_OUTPUT/unit_tests"

# Clone Chaste source code
cd Chaste
git clone -b 2024.2 https://github.com/Chaste/Chaste.git

# Build Chaste (this will take a long time!)
echo "Starting build..."
cd build
cmake ../Chaste
make -j4 Continuous
echo "Chaste build complete!"

# Run unit tests
echo "Running unit tests — output will go to $CHASTE_TEST_OUTPUT"
ctest -j4 -L Continuous

# Once tests are done, revert to general output directory
export CHASTE_TEST_OUTPUT=~/Chaste/output
echo "CHASTE_TEST_OUTPUT reset to $CHASTE_TEST_OUTPUT"

echo "Congratulations! You have just installed Chaste!"