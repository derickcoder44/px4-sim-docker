# PX4 SITL + Gazebo Docker

Docker image for PX4 SITL (Software-In-The-Loop) simulation with Gazebo Garden.

## Overview

This image builds on top of [`ros-px4-bridge-docker`](https://github.com/derickcoder44/ros-px4-bridge-docker) and adds:
- PX4-Autopilot SITL build
- Gazebo Garden simulator
- All required dependencies for simulation

## Usage

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/derickcoder44/px4-sim-docker:latest
```

### Run Simulation

```bash
docker run -it --rm \
  ghcr.io/derickcoder44/px4-sim-docker:latest \
  bash
```

Inside the container, start the simulation:

```bash
# Start DDS Agent in background
MicroXRCEAgent udp4 -p 8888 &

# Run PX4 SITL with Gazebo
cd /root/workspace/PX4-Autopilot
make px4_sitl gz_x500
```

### Build Locally

```bash
git clone --recursive https://github.com/derickcoder44/px4-sim-docker.git
cd px4-sim-docker
docker build -t px4-sim-docker .
```

## Architecture

This image is part of a layered Docker architecture:

1. **ros-px4-bridge-docker** (base) - ROS2 + DDS Agent + PX4 ROS packages
2. **px4-sim-docker** (this repo) - Adds PX4 SITL + Gazebo
3. **px4-flight-test-docker** - Adds flight test scripts

## Environment Variables

- `PX4_VERSION=release/1.14` - PX4 version
- `GZ_SIM_RESOURCE_PATH` - Gazebo model path
- `GZ_SIM_SYSTEM_PLUGIN_PATH` - Gazebo plugin path
- `PX4_NO_HELP=1` - Disable PX4 help messages
- `PX4_SIM_SPEED_FACTOR=2` - Simulation speed multiplier
- `PX4_GZ_MODEL=x500` - Default drone model
- `HEADLESS=1` - Run without GUI

## License

MIT
