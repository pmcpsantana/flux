FROM alpine:3.6

# These are pretty static
LABEL maintainer="Weaveworks <help@weave.works>" \
      org.opencontainers.image.title="flux" \
      org.opencontainers.image.description="The Flux daemon, for synchronising your cluster with a git repo, and deploying new images" \
      org.opencontainers.image.url="https://github.com/weaveworks/flux" \
      org.opencontainers.image.source="git@github.com:weaveworks/flux" \
      org.opencontainers.image.vendor="Weaveworks" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="flux" \
      org.label-schema.description="The Flux daemon, for synchronising your cluster with a git repo, and deploying new images" \
      org.label-schema.url="https://github.com/weaveworks/flux" \
      org.label-schema.vcs-url="git@github.com:weaveworks/flux" \
      org.label-schema.vendor="Weaveworks"

WORKDIR /home/flux
ENTRYPOINT [ "/sbin/tini", "--", "fluxd" ]
RUN apk add --no-cache openssh ca-certificates tini 'git>=2.3.0'

# Get the kubeyaml binary (files) and put them on the path
COPY --from=quay.io/squaremo/kubeyaml:0.3.1 /usr/lib/kubeyaml /usr/lib/kubeyaml/
ENV PATH=/bin:/usr/bin:/usr/local/bin:/usr/lib/kubeyaml

# Add git hosts to known hosts file so we can use
# StrickHostKeyChecking with git+ssh
RUN ssh-keyscan github.com gitlab.com bitbucket.org >> /etc/ssh/ssh_known_hosts
# Add default SSH config, which points at the private key we'll mount
COPY ./ssh_config /etc/ssh/ssh_config

COPY ./kubectl /usr/local/bin/
COPY ./fluxd /usr/local/bin/

ARG BUILD_DATE
ARG VCS_REF

# These will change for every build
LABEL org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE"
