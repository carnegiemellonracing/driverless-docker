FROM nvcr.io/nvidia/pytorch:25.08-py3

WORKDIR /root

COPY ml_requirements.txt .
COPY setup.sh .

RUN chmod +x setup.sh && ./setup.sh