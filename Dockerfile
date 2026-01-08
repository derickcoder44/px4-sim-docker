FROM ghcr.io/derickcoder44/ros-px4-bridge-docker:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PX4_VERSION=release/1.14

# Install PX4 and Gazebo dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    python-is-python3 \
    ninja-build \
    protobuf-compiler \
    libeigen3-dev \
    libopencv-dev \
    wget \
    lsb-release \
    gnupg \
    gdb \
    valgrind \
    astyle \
    lcov \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    rsync \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Install PX4 Python dependencies
RUN pip3 install \
    kconfiglib \
    empy==3.3.4 \
    jinja2 \
    packaging \
    jsonschema \
    future \
    pyyaml \
    pyserial \
    toml \
    numpy \
    pandas

# Install Gazebo Garden
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] \
    http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && \
    apt-get install -y gz-garden && \
    rm -rf /var/lib/apt/lists/*

# Clone and build PX4-Autopilot
WORKDIR /root/workspace
RUN git clone -b ${PX4_VERSION} https://github.com/PX4/PX4-Autopilot.git --recursive

# Configure ccache
ENV CCACHE_DIR=/root/.ccache
ENV CCACHE_MAXSIZE=400M
ENV CCACHE_COMPRESS=1
ENV CCACHE_COMPRESSLEVEL=6
ENV PATH="/usr/lib/ccache:$PATH"

# Build PX4 SITL
ENV GZ_SIM_RESOURCE_PATH=/root/workspace/PX4-Autopilot/Tools/simulation/gz/models
RUN cd PX4-Autopilot && \
    make px4_sitl_default

# Set up Gazebo environment
ENV GZ_SIM_SYSTEM_PLUGIN_PATH=/root/workspace/PX4-Autopilot/build/px4_sitl_default/build_gz-garden
ENV PX4_NO_HELP=1
ENV PX4_SIM_SPEED_FACTOR=2
ENV PX4_GZ_MODEL=x500
ENV PX4_UXRCE_DDS_NS=fmu
ENV HEADLESS=1

# Update entrypoint to source ROS2 workspace
RUN echo '#!/bin/bash\n\
set -e\n\
source /opt/ros/humble/setup.bash\n\
source /root/workspace/ros2_ws/install/setup.bash\n\
exec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
