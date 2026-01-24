#!/bin/sh
# SSH setup script for FRR containers (Alpine Linux)
# Enables SSH access for students with direct vtysh access

# Update package index and install required packages
apk update
apk add --no-cache openssh sudo bash nano shadow

# Create SSH run directory
mkdir -p /run/sshd

# Generate host keys if they don't exist
ssh-keygen -A

# Enable password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Allow root login for SSH (Alpine default might have this disabled)
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create admin user with bash as default shell
adduser -D -s /bin/bash admin
echo "admin:admin" | chpasswd

# Create sudo group if it doesn't exist and add admin to it
addgroup sudo 2>/dev/null || true
adduser admin sudo

# Add to frrvty group for direct vtysh access (no sudo needed)
adduser admin frrvty

# Configure sudo to allow sudo group without password prompt
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create a basic .bashrc file for admin user
cat > /home/admin/.bashrc << 'EOF'
# Custom prompt with router context
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Useful aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias v='vtysh'

# Welcome message
echo "Welcome to FRR Router Lab"
echo "Type 'vtysh' or 'v' to access router CLI"
EOF

# Set proper ownership
chown admin:admin /home/admin/.bashrc

# Start SSH daemon in background
# Use nohup to keep it running after script exits
nohup /usr/sbin/sshd -D > /var/log/sshd.log 2>&1 &

# Give SSH a moment to start
sleep 2

# Verify it started
if pgrep sshd > /dev/null; then
    echo "SSH daemon started successfully"
else
    echo "WARNING: SSH daemon may not have started"
    cat /var/log/sshd.log
fi
