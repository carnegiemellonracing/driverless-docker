FROM osrf/ros:humble-desktop-full

ARG GITHUB_USERNAME
RUN --mount=type=secret,id=github_pat \
            echo "Secret is: $(cat /run/secrets/github_pat)"

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

# run with gtsam for path planning built
# RUN /setup.sh -p  

# run without gtsam built
RUN --mount=type=secret,id=github_pat /setup.sh  
