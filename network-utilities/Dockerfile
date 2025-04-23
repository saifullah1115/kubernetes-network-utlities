# Use a base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    telnet \
    traceroute \
    iputils-ping \
    wget \
    net-tools \
    openssh-client \
    ftp \ 
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Default command
CMD ["sleep", "infinity"]

