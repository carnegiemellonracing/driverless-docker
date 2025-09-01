FROM osrf/ros:humble-desktop-full

RUN groupadd -g 1001 cmr && \
    useradd -u 1001 -g cmr -m 26x

USER 26x
WORKDIR /home/26x/
COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

# run with gtsam for path planning built
# RUN /setup.sh -p  

# run without gtsam built
RUN /setup.sh  
