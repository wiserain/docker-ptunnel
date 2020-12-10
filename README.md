# docker-ptunnel

[[**p**]ython-proxy](https://github.com/qwj/python-proxy) + [green-[**tunnel**]](https://github.com/SadeghHayeri/GreenTunnel)

## Usage

```yaml
version: '3'

services:
  ptunnel:
    container_name: ptunnel
    image: wiserain/ptunnel:latest
    restart: always
    network_mode: bridge
    ports:
      - "${PORT_TO_EXPOSE}:${PROXY_PORT:-8008}"
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - PROXY_USER=${PROXY_USER}
      - PROXY_PASS=${PROXY_PASS}
```

Up and run your container as above. Then you can access to your password-authenticated proxy server via

```http://${PROXY_USER}:${PROXY_PASS}@${DOCKER_HOST}:${PORT_TO_EXPOSE}```

Python-proxy running at front will forward all your requests to the internally working green-tunnel below

```bash
gt --ip 0.0.0.0 --port ${GT_PORT:-21000} --system-proxy false \
    --dns-type ${GT_DNSTYPE:-https} \
    --dns-server ${GT_DNSSERVER:-https://1.1.1.1/dns-query}
```

## Direct connection to green-tunnel

As green-tunnel is binding to ```0.0.0.0:21000```, you can directly access it independently to the proxy running at front by publishing your container port ```21000```. It is highly recommended exposing the port for internal use only.

## Environment variables

| ENV  | Description  | Default  |
|---|---|---|
| ```PUID``` / ```PGID```  | uid and gid for running an app  | ```911``` / ```911```  |
| ```TZ```  | timezone  | ```Asia/Seoul```  |
| ```PROXY_ENABLED```  | set ```false``` to disable proxy | ```true``` |
| ```PROXY_USER``` / ```PROXY_PASS```  | required both to activate proxy authentication   |  |
| ```PROXY_PORT```  | to run proxy in a different port  | ```8008``` |
| ```PROXY_VERBOSE```  | simple access logging  |  |
| ```GT_ENABLED```  | set ```false``` to disable green-tunnel  | ```true``` |
| ```GT_UPDATE```  | set ```true``` to update green-tunnel on startup  | ```false``` |
| ```GT_PORT```  | to run green-tunnel in different port  | ```21000```  |
| ```GT_VERBOSE```  | set ```true``` to run green-tunnel in verbose mode for the purpose of debugging  |  |
| ```GT_DNSTYPE```  | agrument ```--dns-type``` for [green-tunnel CLI](https://github.com/SadeghHayeri/GreenTunnel#command-line-interface-cli)  | ```https```  |
| ```GT_DNSSERVER```  | agrument ```--dns-server``` for [green-tunnel CLI](https://github.com/SadeghHayeri/GreenTunnel#command-line-interface-cli)  | ```https://1.1.1.1/dns-query```  |
