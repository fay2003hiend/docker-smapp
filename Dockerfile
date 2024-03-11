# Pull base image
FROM fedora:39

# SMAPP Debian Package
ARG SMAPP_APP=Spacemesh.AppImage

# Define software download URLs
ARG SMAPP_URL=https://smapp.spacemesh.network/dist/v1.3.12/Spacemesh-1.3.12.AppImage

# root Home
ARG ROOT_HOME=/root

# noVNC Home
ARG NOVNC_HOME=${ROOT_HOME}/noVNC

# Install Fluxbox, noVNC and download SMAPP
RUN dnf check-update || true
RUN dnf install -y ca-certificates
RUN dnf install -y \
        ca-certificates \
        curl \
        eterm \
        firefox \
        fluxbox \
        openssl \
        mesa-libgbm-devel \
        libnotify-devel \
        libnss-mysql \
        libsecret \
        supervisor \
        x11vnc \
        xdg-utils \
        git \
        xorg-x11-server-Xvfb
RUN git clone --depth 1 https://github.com/novnc/noVNC ${NOVNC_HOME} && \
    git clone --depth 1 https://github.com/novnc/websockify ${NOVNC_HOME}/utils/websockify && \
    curl -# -L -o ${SMAPP_APP} ${SMAPP_URL} && \
    chmod +x ${SMAPP_APP} && \
    mkdir -p ${ROOT_HOME}/.fluxbox && \
    rm -rf ${NOVNC_HOME}/.git && \
    rm -rf ${NOVNC_HOME}/utils/websockify/.git

RUN ./${SMAPP_APP} --appimage-extract && mv squashfs-root /SpacemeshApp && rm ${SMAPP_APP}
# RUN apt update && apt install -y libssl3 libcups2 libatk1.0-0 libatk-bridge2.0-0
# RUN apt install -y libgtk-3-0
RUN dnf install -y mesa-libOpenCL

# AMD YES
RUN dnf install -y rocm-opencl rocm-smi

# Copy Supervisor Daemon configuration 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy Spacemesh wallpaper
COPY spacemesh-wallpaper.png /usr/share/images/fluxbox/spacemesh-wallpaper.png

# Copy Fluxbox configurations
ADD ./fluxbox ${ROOT_HOME}/.fluxbox

# Expose the noVNC port
EXPOSE 8080

# Expose the SMAPP node port
EXPOSE 7513/tcp
EXPOSE 7513/udp

# Setup environment variables
ENV HOME=${ROOT_HOME} \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1440 \
    DISPLAY_HEIGHT=900

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
