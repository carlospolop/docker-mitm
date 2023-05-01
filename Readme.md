# Docker MitM

This is a container prepared with env variables to **proxy HTTP traffic from the container to your burp proxy** to steal the communication occurring inside of it (potentially credentials).

This is useful in environments where:

1. You can configure the Docker image to use
2. Some interesting connections are created from the contair and you want to check what

This Docker image is public in **docker.io/carlospolop/docker-mitm:v4**

### Start MitM proxy

```bash
# Install proxy
pip3 install mitmproxy

# Get CA certificate
cat ~/.mitmproxy/mitmproxy-ca-cert.pem

# Start listening
mitmproxy --listen-port 8000 --set block_global=false [--allow-hosts "github.com"] [--ignore-hosts "169.254.169.254|169.254.170.2|amazonaws.com"]
```

### Create Docker image

**REMEMBER TO SET THE MITMPROXY CERTIFICATE & CHANGE THE VALUES OF `https_proxy` and `http_proxy` in the `Dockerfile` with the hostname and port where the proxy will be listening**

**Important**: It's possible that the binary you are doing a MitM has certificate pinning. This will probably break the binary and won't allow you to continue capturing other requests. In that case use the params `--allow-hosts` (if you know which host you want to attack) or `--ignore-hosts` to ignore the one giving problems.

**Important2**: If are using this in cloud, it might be possible that HTTP requests are being done to the metadata service. In that case you potentially DON'T want to set the `http_proxy` environment variable, to avoid doing a MitM to those requests (or maybe you could just use `--ignore-hosts`).



```bash
# Build
docker build -t docker-mitm . 

# Just running apt-get update you should start capturing traffic
docker run -it docker-mitm apt-get update
# Or accessing github.com via https
docker run -it docker-mitm curl https://github.com

# Upload to docker hub 
docker login
docker tag docker-mitm carlospolop/docker-mitm:vX # Change X
docker push carlospolop/docker-mitm:vX # Change X
```
