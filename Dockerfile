FROM ruby:2.7
ARG UNAME=app
ARG UID=1000
ARG GID=1000

# COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app
#
ENV BUNDLE_PATH /gems
#
RUN gem install bundler
#
# COPY . /usr/src/app
