# Containerized xupnp iptv daemon

## References

Inspired by [this](https://habr.com/ru/post/517304) article. 
[This](https://iptvm3u.ru/one/) resource is a playlist provider.

## Description

Purpose of this image is to download (and refresh once ina while) playlist from above resource and share it via UPnP/DLNA to local network, so it can be picked up by smart TV and similar devxupnpd.

## How to build

(assuming docker and buildx already installed, see links section below)

### XUPNPD 

* Run `config builder` task first to configure docker buildx.
* Run `docker build` task to build image on current arch
* (Alternatively) Run `docker buildx & export to docker` task to build docker image for current arch and export to docker environment.
* (Alternatively) Run `docker buildx` task to build docker image for all archs. This is currently failing to export image to docker environment due to some bug.
* (Alternatively) Run `docker buildx & push to registry` task to build docker image for all archs and push result to registry.

You should have xupnpd working now, you may test it with `docker run` task to execute xupnpd or `docker run bash` to run bash in target container and perhaps execute `start.sh` yourself

## How to run

### Run as a service (auto start on boot)

Create xupnpd-iptv service using `sudo nano /etc/systemd/system/xupnpd-iptv-docker.service`. Place following contents there
```
[Unit]
Description=dockerized xupnpd-iptv
Requires=docker.service network-online.service
After=docker.service network-online.service

[Service]
ExecStartPre=-/usr/bin/docker rm -f xupnpd-iptv-instance
ExecStartPre=-/usr/bin/docker pull andreymalyshenko/xupnpd-iptv-one
ExecStart=/usr/bin/docker run --name xupnpd-iptv-instance --net=host andreymalyshenko/xupnpd-iptv-one
ExecStartPost=/bin/sh -c 'while ! docker ps | grep xupnpd-iptv-instance ; do sleep 0.2; done'
ExecStop=/usr/bin/docker rm -f xupnpd-iptv-instance
TimeoutSec=0
RemainAfterExit=no
Restart=always

[Install]
WantedBy=multi-user.target
```

Now start service by running 
```
sudo systemctl start xupnpd-iptv-docker.service
```

You should be able to access xupnpd-iptv server UI under http://localhost:4044. If everything works all right, enable autostart by running
```
sudo systemctl enable xupnpd-iptv-docker.service
```

### Docker cleanup service (optional)

Docker tends to take to much space with time, so once in a while you may come and run `docker system prune` to remove unused images and volumes. As an alternative one may setup a service to do it automatically once in a while.

Create a timer file `sudo nano /etc/systemd/system/docker-cleanup.timer` and add following content
```
[Unit]
Description=Docker cleanup timer

[Timer]
OnUnitInactiveSec=12h

[Install]
WantedBy=timers.target
```

Create a servce file `sudo nano /etc/systemd/system/docker-cleanup.service` and add following content
```
[Unit]
Description=Docker cleanup
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=/tmp
User=root
Group=root
ExecStart=/usr/bin/docker system prune -af

[Install]
WantedBy=multi-user.target
```

Now enable service with this command
```
systemctl enable docker-cleanup.timer
```

## Links
* [xupnpd Home](http://xupnpd.org/)
* [Install Docker](https://docs.docker.com/engine/install/ubuntu/)
* [Install Docker BuildX](https://github.com/docker/buildx/)
