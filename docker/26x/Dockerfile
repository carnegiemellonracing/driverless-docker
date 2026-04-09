FROM osrf/ros:humble-desktop-full

ARG GITHUB_USERNAME

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh
# run with gtsam for path planning built
# RUN --mount=type=secret,id=github_pat /setup.sh -p  

# run without gtsam built
RUN --mount=type=secret,id=github_pat /setup.sh  

ENV OPENCV_ROOT=/opt/opencv-current
ENV OpenCV_DIR=${OPENCV_ROOT}/lib/cmake/opencv4
ENV CMAKE_PREFIX_PATH=${OPENCV_ROOT}:${CMAKE_PREFIX_PATH}
ENV PKG_CONFIG_PATH=${OPENCV_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}
ENV LD_LIBRARY_PATH=${OPENCV_ROOT}/lib:${LD_LIBRARY_PATH}

RUN chmod +x /root/driverless/scripts/setup/driverless_setup.sh
RUN /root/driverless/scripts/setup/driverless_setup.sh
