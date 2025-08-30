FROM nvcr.io/nvidia/pytorch:25.08-py3

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

RUN /setup.sh