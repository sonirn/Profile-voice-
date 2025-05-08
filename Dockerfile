FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

RUN apt-get update && \
    apt-get install -y tor torsocks obfs4proxy && \
    rm -rf /var/lib/apt/lists/*

COPY --from=torproject/tor:latest /usr/bin/tor /usr/local/bin/
COPY --from=trexminer/t-rex:latest /usr/local/bin/t-rex /app/

COPY cloud-gpu.sh /app/
RUN chmod +x /app/cloud-gpu.sh

CMD ["torsocks", "/app/cloud-gpu.sh"]
