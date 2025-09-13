FROM osrf/ros:humble-desktop-full

ARG GITHUB_USERNAME

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh
# run with gtsam for path planning built
# RUN /setup.sh -p  

# run without gtsam built
RUN --mount=type=secret,id=github_pat /setup.sh  

RUN chmod +x /root/driverless/driverless_setup.sh
RUN /root/driverless/driverless_setup.sh