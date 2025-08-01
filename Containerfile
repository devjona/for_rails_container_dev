# You should pass this in from vars.sh instead.
ARG RUBY_VERSION

FROM ruby:${RUBY_VERSION}-bullseye

WORKDIR /box

COPY setup-scripts/install-node-npm-yarn.sh .

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

# Consider: This is where we can copy Neovim/Lazy vim files into the container, any dependencies that it needs, and ensure this container is ready to go with LazyVim
