FROM madharjan/docker-base:16.04
LABEL maintainer="Madhav Raj Maharjan <madhav.maharjan@gmail.com>"

ARG VCS_REF
ARG GITEA_VERSION
ARG DEBUG=false

LABEL description="Docker container for Gitea Server" os_version="Ubuntu ${UBUNTU_VERSION}" \
      org.label-schema.vcs-ref=${VCS_REF} org.label-schema.vcs-url="https://github.com/madharjan/docker-gitea"

ENV GITEA_VERSION ${GITEA_VERSION}

RUN mkdir -p /build
COPY . /build

RUN chmod 755 /build/scripts/*.sh && /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/gitea", "/var/lib/gitea", "/var/log/gitea"]

CMD ["/sbin/my_init"]

EXPOSE 3000