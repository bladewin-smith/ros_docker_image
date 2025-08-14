FROM ros:humble

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
ENV QT_QPA_PLATFORM=xcb
ENV QT_DEBUG_PLUGINS=1

RUN echo "deb http://ports.ubuntu.com/ubuntu-ports jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://ports.ubuntu.com/ubuntu-ports jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://ports.ubuntu.com/ubuntu-ports jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://ports.ubuntu.com/ubuntu-ports jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales tzdata \
    build-essential cmake git wget curl vim nano lsb-release \
    python3 python3-pip python3-dev python3-colcon-common-extensions python3-rosdep python3-rosinstall-generator python3-vcstool python3-venv \
    ros-humble-rmw-cyclonedds-cpp ros-humble-ros-base \
    libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libopencv-dev \
    libgl1-mesa-glx libgl1-mesa-dri libx11-xcb1 libxcb-glx0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-shm0 libxcb-sync1 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 libxrender1 libxext6 libxtst6 \
    libpulse0 pulseaudio ffmpeg libavcodec-extra fonts-noto-cjk usbutils v4l-utils lsof libjsoncpp-dev libasound2-dev x11-apps \
    qtbase5-dev qtbase5-dev-tools libqt5gui5 libqt5core5a libqt5widgets5 libqt5x11extras5 \
    && rm -rf /var/lib/apt/lists/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && locale-gen zh_CN.UTF-8

RUN useradd -m -s /bin/bash myuser \
    && echo "myuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/myuser/ros2_ws

USER myuser

RUN pip3 install --upgrade pip \
    && pip3 install pybind11==2.11.0 \
    pybind11-global==2.11.0 \
    opencv-python \
    wheel \
    "numpy<2.0" \
    av \
    pygame \
    pynput \
    protobuf==3.20.3 \
    "psutil>=5.9.0" \
    "ruamel.yaml>=0.17.21" \
    "scipy>=1.9.3" \
    "tqdm>=4.64.1" \
    "opencv-python>=4.5.5.64" \
    "fast-histogram>=0.11" \
    "numpy<=1.26.4" \
    onnx==1.16.1 \
    onnxoptimizer==0.3.8 \
    "onnxruntime>=1.16.0" \
    "torch>=1.13.1,<=2.2.0" \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && rm -rf /home/myuser/.cache/pip

CMD ["/bin/bash", "-c", "source /opt/ros/humble/setup.bash && exec bash"]
