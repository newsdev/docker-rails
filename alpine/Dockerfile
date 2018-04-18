FROM ruby:2.5-alpine3.7

# Define locale
ENV LANG C.UTF-8

# Configure bundler
RUN \
  bundle config --global frozen 1 && \
  bundle config --global build.nokogiri --use-system-libraries 

# Set the working directory
ONBUILD RUN mkdir -p /usr/src/app
ONBUILD WORKDIR /usr/src/app

# Install gems and node modules, using specified apk packages
ONBUILD ARG BUILD_DEPENDENCIES
ONBUILD ARG RUNTIME_DEPENDENCIES
ONBUILD ARG BUNDLE_INSTALL_FLAGS

ONBUILD COPY Gemfile Gemfile.lock package.json* yarn.lock* .npmrc* .yarn* /usr/src/app/
ONBUILD COPY vendor /usr/src/app/vendor

ONBUILD RUN apk --update add --virtual .build-deps \
          build-base cmake $BUILD_DEPENDENCIES \
        && apk add yarn --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        && apk add --no-cache \
          curl curl-dev nodejs libxml2 libxslt-dev openssl \
          $RUNTIME_DEPENDENCIES \
        && bundle install --without test development --jobs `grep -c '^processor' /proc/cpuinfo` $BUNDLE_INSTALL_FLAGS \
        && yarn install --production \
        && apk del .build-deps

# Copy the rest of the application source
ONBUILD COPY . /usr/src/app

# Run the requirejs optimizer if the badcom gem is included and precompile assets.
ONBUILD RUN \
  ! gem list -i badcom > /dev/null || RAILS_ENV=production RAILS_ASSETS_COMPILE=true rake badcom:requirejs:optimize_all && \
  RAILS_ASSETS_COMPILE=true RAILS_ENV=production rake assets:precompile

# Run the server
ONBUILD EXPOSE 3000
ONBUILD CMD ["puma", "-t", "8:8", "-p", "3000"]
