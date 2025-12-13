FROM ubuntu:22.04

# Install dependencies needed for dotfiles
RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    make \
    automake \
    autoconf \
    pkg-config \
    gcc \
    libevent-dev \
    libncurses5-dev \
    libncursesw5-dev \
    yacc \
    sudo \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Create a test user (non-root)
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Copy dotfiles into container (includes .git for submodule support)
COPY --chown=testuser:testuser . /home/testuser/dotfiles

# Set working directory to dotfiles
WORKDIR /home/testuser/dotfiles

# Run installation and verification
CMD ["bash", "-c", "rm -f ~/.bashrc && ./install && source ~/.bashrc && bash tests/verify-install.sh"]
