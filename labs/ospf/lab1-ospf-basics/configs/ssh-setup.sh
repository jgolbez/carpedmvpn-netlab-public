#!/bin/bash
# SSH setup script for FRR containers
# Enables SSH access for students with direct vtysh access

# Update and install required packages
apt-get update
apt-get install -y openssh-server sudo bash nano

# Create SSH run directory
mkdir -p /run/sshd

# Enable password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create user with bash as default shell
useradd -m -s /bin/bash demo
echo 'demo:demo' | chpasswd

# Add to sudo group for privileged operations
usermod -aG sudo demo

# Add to frrvty group for direct vtysh access (no sudo needed)
usermod -aG frrvty demo

# Create a basic .bashrc file for demo user
cat > /home/demo/.bashrc << 'EOF'
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
chown demo:demo /home/demo/.bashrc

# Start SSH daemon
/usr/sbin/sshd -D &
