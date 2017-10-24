# ---- Import parent image ---- #
# I chose Alpine Linux because it is a barebones linux distro (~5MB) with package management
FROM apline

# ---- Set label(s) ---- #
LABEL maintainer="Bern Carney"

# ---- Install required packages &  virtual dependencies to build the docker image ---- #
# required packages will remain after image is built, virtual dependencies will not
RUN apk --no-cache add git \
  && apk --no-cache add --virtual build_deps curl

# ---- Setup environmental variables ---- #
# official gohugo releases https://github.com/gohugoio/hugo/releases/download/v0.30.2/hugo_0.30.2_Linux-64bit.tar.gz
ENV VERSION 0.30.2
ENV BINARY hugo_${VERSION}_Linux-64bit

# ---- Get Hugo, create user/group, and cleanup afterwards ---- #
RUN mkdir -p /usr/local/src \
  && cd /usr/local/src \

  && curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${BINARY}.tar.gz > /tmp/${BINARY}.tar.gz \
  && tar -xzf /tmp/${BINARY}.tar.gz \
  && mv hugo /usr/local/bin/hugo \

  && addgroup -Sg 1231 hugo \
  && adduser -SG hugo -u 1231 -h /src hugo \

  && rm /tmp/${BINARY}.tar.gz /usr/local/src/LICENSE.md /usr/local/src/README.md \
  && apk del build_deps

# ---- Set working directory ---- #
WORKDIR /src

# ---- Set intended image port ---- #
EXPOSE 4040
