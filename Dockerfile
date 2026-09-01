# Canonical's official Ubuntu OCI image uses a minimal, container-tailored rootfs.
FROM ubuntu:24.04

ARG USER_UID=1000
ARG USER_GID=1000
ARG IMAGE_VARIANT=default
ENV USER_UID=${USER_UID}
ENV USER_GID=${USER_GID}
ENV IMAGE_VARIANT=${IMAGE_VARIANT}

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV SCREEN_RESOLUTION=1920x1080x24
ENV XDG_RUNTIME_DIR=/run/user/${USER_UID}
ENV GTK_IM_MODULE=fcitx
ENV QT_IM_MODULE=fcitx
ENV XMODIFIERS=@im=fcitx
ENV SDL_IM_MODULE=fcitx
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Layer 1: Set up software sources
RUN apt-get update && \
    apt-get install -y software-properties-common ca-certificates curl && \
    add-apt-repository -y universe && \
    add-apt-repository -y ppa:xtradeb/apps && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

# Layer 2: Install all packages
RUN apt-get update && \
    apt-get install -y \
    # System utilities
    build-essential \
    copyq \
    dbus \
    dbus-x11 \
    dnsutils \
    dos2unix \
    git \
    gh \
    golang \
    htop \
    iputils-ping \
    jq \
    locales \
    libx11-dev \
    libxext-dev \
    libxtst-dev \
    net-tools \
    ripgrep \
    scrot \
    socat \
    sudo \
    supervisor \
    unzip \
    vim \
    wget \
    xclip \
    xdotool \
    # GUI and VNC
    chromium \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-terminal \
    # Runtimes
    nodejs \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python-is-python3 \
    && if [ "${IMAGE_VARIANT}" = "zh" ]; then \
        apt-get install -y \
        # Fonts and locales
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        fonts-wqy-zenhei \
        language-pack-zh-hans \
        language-pack-zh-hant \
        # Input method tooling
        fcitx5 \
        fcitx5-chinese-addons \
        fcitx5-frontend-gtk3 \
        fcitx5-frontend-qt5 \
        fcitx5-config-qt \
        im-config \
        ; \
    fi && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure en_US locale exists for all variants
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Noble's official base reserves UID/GID 1000 for its ubuntu account. This
# image's public runtime identity is vncuser, so remove the superseded base
# account before applying the configured vncuser UID/GID.
RUN if getent passwd ubuntu >/dev/null; then userdel --remove ubuntu; fi && \
    if getent group ubuntu >/dev/null; then groupdel ubuntu; fi && \
    groupadd -g ${USER_GID} vncuser && \
    useradd -u ${USER_UID} -g ${USER_GID} -m -s /bin/bash vncuser && \
    usermod -aG sudo vncuser && \
    echo "vncuser:vncuser" | chpasswd && \
    echo "vncuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vncuser && \
    chmod 0440 /etc/sudoers.d/vncuser && \
    touch /home/vncuser/.xprofile && \
    chown ${USER_UID}:${USER_GID} /home/vncuser/.xprofile && \
    chmod 644 /home/vncuser/.xprofile

# Layer 2.5: Configure Chinese locale/input when requested
RUN if [ "${IMAGE_VARIANT}" = "zh" ]; then \
        locale-gen en_US.UTF-8 zh_CN.UTF-8 zh_TW.UTF-8 && \
        update-locale LANG=en_US.UTF-8 && \
        su - vncuser -c "im-config -n fcitx5" && \
        su - vncuser -c "mkdir -p ~/.config/fcitx5/conf ~/.config/autostart" && \
        printf '%s\n' \
'export GTK_IM_MODULE=fcitx' \
'export QT_IM_MODULE=fcitx' \
'export XMODIFIERS=@im=fcitx' \
'export SDL_IM_MODULE=fcitx' \
        >> /home/vncuser/.xprofile && \
        printf '%s\n' \
'[Groups]' \
'0=Default' \
'Number=1' \
'' \
'[Groups/0]' \
'Name=Default' \
'Default Layout=us' \
'' \
'[Groups/0/Items/0]' \
'Name=keyboard-us' \
'Layout=us' \
'Default=True' \
'' \
'[Groups/0/Items/1]' \
'Name=pinyin' \
        > /home/vncuser/.config/fcitx5/profile && \
        chown -R vncuser:vncuser /home/vncuser/.config/fcitx5; \
    fi

# Layer 3: Post-installation configuration
# Keep Python-installed image tooling out of Noble's externally managed system
# environment. The public commands use the isolated environment while python3
# and python continue to resolve to Ubuntu's native Python 3.12 interpreter.
RUN python3 -m venv /opt/browser-tools && \
    /opt/browser-tools/bin/python -m pip install --upgrade pip wheel setuptools && \
    /opt/browser-tools/bin/python -m pip install websockify uv && \
    ln -s /opt/browser-tools/bin/websockify /usr/local/bin/websockify && \
    ln -s /opt/browser-tools/bin/uv /usr/local/bin/uv && \
    WEBSOCKIFY_PACKAGE_DIR="$(/opt/browser-tools/bin/python -c 'from pathlib import Path; import websockify; print(Path(websockify.__file__).parent)')" && \
    ln -s "${WEBSOCKIFY_PACKAGE_DIR}" /usr/local/share/websockify && \
    npm install -g yarn

# Configure npm and yarn for the vncuser to use a local directory for global packages.
# This is a standard practice to avoid permission errors without using sudo.
RUN mkdir -p /home/vncuser/.local/bin && \
    chown -R vncuser:vncuser /home/vncuser/.local && \
    # Configure yarn's global install location
    su - vncuser -c "yarn config set prefix /home/vncuser/.local" && \
    # Add environment variables to .bashrc for npm and for the PATH
    echo '' >> /home/vncuser/.bashrc && \
    echo '# Configure npm, yarn, and other tools to use a local directory for user installs' >> /home/vncuser/.bashrc && \
    echo 'export NPM_CONFIG_PREFIX=/home/vncuser/.local' >> /home/vncuser/.bashrc && \
    echo 'export PATH="/home/vncuser/.local/bin:$PATH"' >> /home/vncuser/.bashrc

# Setup supervisor with correct permissions
RUN mkdir -p /var/log/supervisor /etc/supervisor/conf.d && \
    chown -R vncuser:vncuser /var/log/supervisor && \
    chmod 755 /var/log/supervisor

# Create .vnc directory (no password file created)
RUN mkdir -p /home/vncuser/.vnc && \
    chown -R ${USER_UID}:${USER_GID} /home/vncuser/.vnc && \
    chmod 700 /home/vncuser/.vnc

# Setup X11 and shared memory permissions
RUN mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    mkdir -p /dev/shm && \
    chmod 1777 /dev/shm && \
    chown -R ${USER_UID}:${USER_GID} /tmp/.X11-unix

# Setup DBus directories and permissions
RUN mkdir -p /run/dbus && \
    chown messagebus:messagebus /run/dbus && \
    dbus-uuidgen > /etc/machine-id

# Setup Xauthority with secure permissions
RUN touch /home/vncuser/.Xauthority && \
    chown ${USER_UID}:${USER_GID} /home/vncuser/.Xauthority && \
    chmod 600 /home/vncuser/.Xauthority

# Create runtime directory with dynamic UID
RUN mkdir -p ${XDG_RUNTIME_DIR} && \
    chown -R ${USER_UID}:${USER_GID} ${XDG_RUNTIME_DIR} && \
    chmod 700 ${XDG_RUNTIME_DIR}

# Create workspace directory
RUN mkdir -p /home/vncuser/workspace && \
    chown -R ${USER_UID}:${USER_GID} /home/vncuser/workspace

WORKDIR /home/vncuser/workspace

# Create a dedicated log file for CopyQ and set permissions
RUN touch /home/vncuser/copyq.log && chown ${USER_UID}:${USER_GID} /home/vncuser/copyq.log

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY base.conf /etc/supervisor/conf.d/base.conf
COPY entrypoint.sh /entrypoint.sh
COPY start-vnc.sh /usr/local/bin/start-vnc.sh
COPY start-chrome.sh /usr/local/bin/start-chrome.sh
COPY disable-screensaver.sh /home/vncuser/disable-screensaver.sh

RUN dos2unix /entrypoint.sh /usr/local/bin/start-vnc.sh /usr/local/bin/start-chrome.sh /home/vncuser/disable-screensaver.sh && \
    chmod +x /entrypoint.sh /usr/local/bin/start-vnc.sh /usr/local/bin/start-chrome.sh /home/vncuser/disable-screensaver.sh && \
    chown vncuser:vncuser /entrypoint.sh /usr/local/bin/start-vnc.sh /usr/local/bin/start-chrome.sh /home/vncuser/disable-screensaver.sh

EXPOSE 5900 6080 9223

ENTRYPOINT ["/entrypoint.sh"]
