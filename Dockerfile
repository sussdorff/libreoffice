FROM ubuntu:20.04 as base

WORKDIR "/app"

FROM base AS build-arm64
RUN     DEBIAN_FRONTEND=noninteractive \
        apt-get update && apt-get clean && apt-get install -y -f curl \
        && curl -O https://dl.google.com/go/go1.13.6.linux-arm64.tar.gz \
        && tar -C /usr/local -xzf go1.13.6.linux-arm64.tar.gz \
        && rm -rf ./go1.13.6.linux-arm64.tar.gz

# amd64-specific stage
FROM base AS build-amd64
RUN     DEBIAN_FRONTEND=noninteractive \
        apt-get update && apt-get clean && apt-get install -y -f curl \
        && curl -O https://dl.google.com/go/go1.13.6.linux-amd64.tar.gz \
        && tar -C /usr/local -xzf go1.13.6.linux-amd64.tar.gz \
        && rm -rf ./go1.13.6.linux-amd64.tar.gz

FROM build-${TARGETARCH} AS build

RUN     DEBIAN_FRONTEND=noninteractive \
        apt-get install -y -f --force-yes \
        	libreoffice \
                libreofficekit-dev && \
        apt-get install --no-install-recommends -y -f --force-yes \
        	libvips \
                libvips-dev \
                curl && \
        echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
        apt-get install ttf-mscorefonts-installer && \
        apt-get install --no-install-recommends -y -f gcc && \
        dpkg-reconfigure fontconfig && \
        fc-cache -vr && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/

COPY *.go *.mod *.sum /app/
COPY fonts /app/fonts/
COPY opentype /usr/share/fonts/opentype/plutosans

RUN     export PATH=$PATH:/usr/local/go/bin && \
        go build -tags extralibs


ENV PATH="${PATH}:/usr/local/go/bin"

CMD ./preview

