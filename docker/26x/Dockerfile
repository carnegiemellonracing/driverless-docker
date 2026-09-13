FROM osrf/ros:humble-desktop-full

COPY setup.sh /setup.sh
COPY start.sh /start.sh

RUN chmod +x /setup.sh
# run with gtsam for path planning built
# RUN --mount=type=secret,id=github_pat /setup.sh -p  

# run without gtsam built
RUN --mount=type=secret,id=github_pat /setup.sh  