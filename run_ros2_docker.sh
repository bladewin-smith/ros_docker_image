#!/bin/bash


IMAGE_NAME="my_gemini2_camera"  # 镜像名称（请确保和你构建镜像时保持一致）

WORKSPACE_DIR="$HOME/ros2_ws"   # 本地ROS2工作空间路径，如果你要在自己板子上将Docker的工作空间挂载到自己新建的工作空间，请务必修改这个路径


xhost +SI:localuser:$(whoami)  # 允许容器内 myuser 用户访问X服务器（只执行一次）


function cleanup() {
    echo "Restoring X11 access control..."
    xhost -SI:localuser:$(whoami)

}
trap cleanup EXIT

function usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  bash           Run container with bash shell (no GUI)"
    echo "  gui            Run container with X11 GUI support"
    echo "  dev            Run container with GUI and mount local ROS2 workspace"
    echo "  devcam         Run container with GUI, mount workspace and access camera/audio devices"
    echo "  devcamnpu      Run container with GUI, mounted workspace, camera/audio, NPU devices and full USB access"
    echo "  help           Show this help message"
}

function check_workspace() {
    if [ ! -d "$WORKSPACE_DIR" ]; then
        echo "Warning: Workspace directory '$WORKSPACE_DIR' does not exist."
        echo "Please create it or modify WORKSPACE_DIR variable."
        exit 1
    fi
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in
    bash)
        echo "Running ROS2 container with bash shell (no GUI)..."
        docker run -it --rm \
            --user myuser \
            "$IMAGE_NAME"
        ;;
    gui)
        echo "Running ROS2 container with GUI support..."
        docker run -it --rm \
            --net=host \
            --env="DISPLAY" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --user myuser \
            "$IMAGE_NAME"
        ;;
    dev)
        echo "Running ROS2 container with GUI and mounted workspace..."
        check_workspace
        docker run -it --rm \
            --net=host \
            -v "$WORKSPACE_DIR":/home/myuser/ros2_ws \
            --env="DISPLAY" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --user myuser \
            "$IMAGE_NAME"
        ;;
    devcam)
        echo "Running ROS2 container with GUI, mounted workspace, and camera/audio devices..."
        check_workspace
        docker run -it --rm \
            --net=host \
            --device=/dev/video0 \
            --device=/dev/snd \
            -v "$WORKSPACE_DIR":/home/myuser/ros2_ws \
            --env="DISPLAY" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --user myuser \
            "$IMAGE_NAME"
        ;;
    devcamnpu)
        echo "Running ROS2 container with GUI, mounted workspace, camera/audio, NPU devices and full USB access..."
        check_workspace
        docker run -it  \
            --net=host \
            --device=/dev/video0 \
            --device=/dev/snd \
            --device=/dev/dri/card0 \
            --device=/dev/dri/card1 \
            --device=/dev/dri/renderD128 \
            --device=/dev/dri/renderD129 \
            --device=/dev/bus/usb:/dev/bus/usb \
            --privileged \
            -v "$WORKSPACE_DIR":/home/myuser/ros2_ws \
            --env="DISPLAY" \
            --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
            --user myuser \
            "$IMAGE_NAME"
        ;;
    help|*)
        usage
        ;;
esac
