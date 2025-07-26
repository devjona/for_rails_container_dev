ARG RUBY_VERSION="3.4.5"

FROM ruby:${RUBY_VERSION}-bullseye

WORKDIR /box

COPY install-node-npm-yarn.sh .

RUN echo "Installing dependencies that Rails will need…" && \
    apt update && \
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
    postgresql-client 

RUN chmod +x install-node-npm-yarn.sh && ./install-node-npm-yarn.sh

# Update gem system
RUN gem update --system && \
    gem install bundler && \
    gem install rails
