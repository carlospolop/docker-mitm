# Docker MitM

This is a container prepared with env variables to **proxy HTTP traffic from the container to your burp proxy** to steal the communication occurring inside of it (potentially credentials).

This is useful in environments where:

1. You can configure the Docker image to use
2. Some interesting connections are created from the container and you want to check them

This Docker image is public in **docker.io/carlospolop/docker-mitm:v6** (This would be useless for you as your proxy ad cert will be different).

## Building the environment

### 1. Generating certs

In order to perform the MiTM attack CAs certificates need to be generated. This can be done, by importing MiTMProxy or Burp Suite CA certificates into the Dockerfile.

### MiTMProxy

> :information_source: According to cloud.hacktricks.xyz the version of MiTMProxy9.0.1 has to be used, can be downloaded here: https://mitmproxy.org/downloads/#9.0.1

```bash
pip3 install mitmproxy
mitmproxy
cp ~/.mitmproxy/mitmproxy-ca-cert.pem ./docker-mitm
```

### Burp Suite

```bash
wget http://127.0.0.1:8080/cert -O /tmp/cacert.der
openssl x509 -inform der -in cacert.der -out ./cacert.pem
```



### 2. Start MitM proxy

### mitmproxy

> :warning: It's possible that the binary you are doing a MitM has certificate pinning. This will probably break the binary and won't allow you to continue capturing other requests. In that case use the params `--allow-hosts` (if you know which host you want to attack) or `--ignore-hosts` to ignore the one giving problems.

```bash
# Start listening
mitmproxy --listen-port 8000 [--set block_global=false] [--allow-hosts "github.com"] [--ignore-hosts "169.254.169.254|169.254.170.2|amazonaws.com"]
```

### Burp Suite

Launch burp listening in the interface needed (By default 127.0.0.1:8080)



### 3. Create Docker image

Data to be changed inside the `Dockerfile`.

- `no_proxy`: By default does no proxy AWS specific traffic (adjust it based on cloud environment)
- `https_proxy` & `http_proxy`: IP and port where all the traffic will be forwarded.

> :information_source: You can use `ngrok tcp 8080` to obtain the http IP and port.
>
> :warning: If are using this in cloud, it might be possible that HTTP requests are being done to the metadata service. In that case you potentially DON'T want to set the `http_proxy` environment variable, to avoid doing a MitM to those request

**Build & check the image**

```bash
docker build -t docker-mitm:v1 .
docker run -it docker-mitm curl https://github.com
```

If **curl** works as intended you can proceed with the attack.

**Push the image**

```
docker login 
docker push <your_dockerhub_user>/docker-mitm:v1
```
