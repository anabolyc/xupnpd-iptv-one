FROM debian:buster-slim as build

ENV DEBIAN_FRONTEND noninteractive

RUN  apt-get update && \
     apt-get install -y wget apt-transport-https ca-certificates locales git build-essential uuid-dev psmisc && \
     apt-get update

# RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
#     locale-gen en_US.UTF-8 && \
#     dpkg-reconfigure locales && \
#     /usr/sbin/update-locale LANG=en_US.UTF-8
# ENV LC_ALL en_US.UTF-8

RUN cd / && git clone https://github.com/clark15b/xupnpd2
RUN cd /xupnpd2 && make --file Makefile.linux

FROM debian:buster-slim as run

RUN  apt-get update && \
     apt-get install -y wget && \
     rm -rf /var/lib/apt/lists/*

COPY --from=build /xupnpd2 /xupnpd2
WORKDIR /xupnpd2
RUN rm /xupnpd2/media/*
ADD start.sh .
RUN useradd -ms /bin/bash xupnpd
RUN chown xupnpd /xupnpd2 -R
USER xupnpd

ENV M3U_URL http://iptvm3u.ru/onelist.m3u
# ENV FRONTEND_NAME IPTV-ONE
# ENV FRONTEND_PORT 4044
# ENV NETWORK_IFCE eth0
# ENV BACKEND_GUID 0aa71114-13e5-4239-8a1a-b50910fc8609
# ENV DEBUG_LEVEL 1

# EXPOSE 4040-4050

CMD ["/bin/bash", "./start.sh"]