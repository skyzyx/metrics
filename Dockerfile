# Base image
FROM node:24-bookworm-slim

SHELL ["/bin/bash", "-c", "-euo", "pipefail"]

# Copy repository
COPY . /metrics
WORKDIR /metrics

# Setup
# hadolint ignore=DL3008
RUN chmod +x /metrics/source/app/action/index.mjs

# Dependencies for being able to install additional software.
# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
  ca-certificates \
  gnupg \
  libgconf-2-4 \
  wget \
  && rm -rf /var/lib/apt/lists/*

# Install latest chrome dev package, fonts to support major charsets and skip chromium download on puppeteer install
# Based on https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
RUN mkdir -p /etc/apt/keyrings/
RUN wget -q -O /etc/apt/keyrings/google-chrome.asc https://dl-ssl.google.com/linux/linux_signing_key.pub \
  && sh -c 'echo "deb [trusted=yes arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.asc] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
  cmake \
  curl \
  fonts-freefont-ttf \
  fonts-ipafont-gothic \
  fonts-kacst \
  fonts-thai-tlwg \
  fonts-wqy-zenhei \
  g++ \
  git \
  google-chrome-stable \
  libssl-dev \
  libx11-xcb1 \
  libxss1 \
  libxtst6 \
  lsb-release \
  pkg-config \
  python3 \
  ruby-full \
  unzip \
  && rm -rf /var/lib/apt/lists/*

# Install Deno for miscellaneous scripts
RUN wget -q -O- https://deno.land/install.sh | DENO_INSTALL=/usr/local sh \
  # Clean apt/lists
  && rm -rf /var/lib/apt/lists/* \
  # Install node modules and rebuild indexes
  && npm ci \
  && npm run build

# Environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_BROWSER_PATH="google-chrome-stable"

# Execute GitHub action
ENTRYPOINT ["node", "/metrics/source/app/action/index.mjs"]
