FROM nvcr.io/nvidia/pytorch:25.08-py3

WORKDIR /root

RUN apt-get update && apt-get install -y --no-install-recommends \
    gh \
    git \
    vim \
    libgl1 \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/* \
    && ldconfig  # Update library cache


COPY ml_requirements.txt .
RUN pip install --no-cache-dir -r ml_requirements.txt

COPY setup.sh .
RUN chmod +x setup.sh && ./setup.sh
