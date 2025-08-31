FROM nvcr.io/nvidia/pytorch:25.08-py3

WORKDIR /root

COPY ml_requirements.txt .
COPY ml_setup.sh .

RUN chmod +x ml_setup.sh && ./ml_setup.sh