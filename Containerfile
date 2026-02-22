# You should pass this in from vars.sh instead.
ARG RUBY_VERSION

# 'bookworm' is Debian 12, https://www.debian.org/releases/bookworm/
ARG DEBIAN_RELEASE

FROM ruby:${RUBY_VERSION}-${DEBIAN_RELEASE}

WORKDIR /box

COPY setup-scripts/install-node-npm-yarn.sh .

RUN apt update && \
    apt install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    graphviz \
    imagemagick \
    libpq-dev \
    libvips \
    vim \
    nano \
    pkg-config \
    postgresql-client \
    fzf

RUN chmod +x install-node-npm-yarn.sh && ./install-node-npm-yarn.sh

# Update gem system
RUN gem update --system && \
    gem install bundler && \
    gem install rails
