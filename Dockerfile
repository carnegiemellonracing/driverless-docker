FROM osrf/ros:humble-desktop-full

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

RUN /setup.sh  
