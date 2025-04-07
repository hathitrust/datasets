FROM ruby:3.4 AS base
LABEL org.opencontainers.image.source="https://github.com/hathitrust/datasets"

ARG UNAME=app

# for rotatelogs
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apache2-utils

# sdrN for volumes and symlinks
RUN bash -c 'for i in $(seq 1 24); do ln -s /sdr/$i /sdr$i; done'

WORKDIR /usr/src/app
ENV BUNDLE_PATH /gems
ENV RUBYLIB /usr/src/app/lib

FROM base AS production

ARG UID=1000
ARG GID=1000
RUN gem install bundler
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d /usr/src/app -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir -p /gems && chown $UID:$GID /gems
USER $UNAME
COPY --chown=$UID:$GID Gemfile* /usr/src/app/
RUN bundle install
COPY --chown=$UID:$GID . /usr/src/app
