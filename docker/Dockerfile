FROM elixir:1.14-alpine

# Set Locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PHOENIX_VERSION 1.6.13
ENV GLIBC_VERSION=2.34-r0

# Add inotify-tools
RUN apk add --no-cache bash inotify-tools

# Install glibc, required by DartSass
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q -O /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    apk add /tmp/glibc.apk && \
    rm -rf /tmp/glibc.apk

# Create required dirs
RUN mkdir /app

# Install hex and rebar
RUN mix local.hex --force
RUN mix local.rebar --force

# Install phoenix
RUN mix archive.install hex phx_new $PHOENIX_VERSION

# Set /app as workdir
WORKDIR /app
