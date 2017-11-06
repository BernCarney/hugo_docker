# ---- Import parent image ---- #
# I chose Alpine Linux because it is a barebones linux distro (~5MB) with package management
# To prevent unforseen problems I decided not to use 'latest' to be able to test new changes without it being automatically pulled
# ---- #
FROM alpine:3.6

# ---- Set label(s) ---- #
LABEL maintainer="Bern Carney"

# ---- Install required packages &  virtual dependencies to build the docker image ---- #
# Required packages that will remain after image is built
#   -git
#   -tzdata
# Virtual dependencies that will not remain after image is built
#   -curl
# ---- #
RUN apk add --no-cache git tzdata \
  && apk add --no-cache --virtual build_deps curl

# ---- Setup environmental variables ---- #
# official gohugo releases for linux-64bit
#  -https://github.com/gohugoio/hugo/releases/download/v0.XX.X/hugo_0.XX.X_Linux-64bit.tar.gz
# ---- #
ENV VERSION 0.30.2
ENV BINARY hugo_${VERSION}_Linux-64bit
ENV HUGO_USER hugo
ENV HUGO_HOME /src
ENV TZ UTC

# ---- Get Hugo, create user/group, and cleanup afterwards ---- #
RUN mkdir -p /usr/local/src \
  && cd /usr/local/src \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${BINARY}.tar.gz > /tmp/${BINARY}.tar.gz \
  && tar -xzf /tmp/${BINARY}.tar.gz \
  && mv hugo /usr/local/bin/hugo \
  && addgroup -Sg 1231 hugo \
  && adduser -SG $HUGO_USER -u 1231 -h $HUGO_HOME $HUGO_USER \
  && chown -R $HUGO_USER:$HUGO_USER $HUGO_HOME \
  && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
  && rm /tmp/${BINARY}.tar.gz /usr/local/src/LICENSE.md /usr/local/src/README.md \
  && apk del build_deps

# ---- Set working directory ---- #
WORKDIR $HUGO_HOME

# ---- Set user ---- #
USER $HUGO_USER

# ---- Set intended image port and volume ---- #
EXPOSE 1313
VOLUME $HUGO_HOME

# ---- Create entrypoint so that default command is hugo <args> --- #
ENTRYPOINT ["hugo"]
