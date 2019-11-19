FROM ruby:2.5.7

# Define locale
ENV LANG C.UTF-8

# Configure bundler
RUN \
  bundle config --global frozen 1 && \
  bundle config --global build.nokogiri --use-system-libraries

# Install node.js
ENV NODE_VERSION=8.16.2
ENV NODE_SHASUM256=722d07291a8886384388c6795a747ec2055073f83dc73c0a97efba0022cc23ff
RUN \
  cd /usr/local && \
  curl -sfLO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz && \
  echo "${NODE_SHASUM256}  node-v$NODE_VERSION-linux-x64.tar.gz" | sha256sum -c - &&\
  tar --strip-components 1 -xzf node-v$NODE_VERSION-linux-x64.tar.gz node-v$NODE_VERSION-linux-x64/bin node-v$NODE_VERSION-linux-x64/include node-v$NODE_VERSION-linux-x64/lib && \
  rm node-v$NODE_VERSION-linux-x64.tar.gz

# Install yarn
RUN apt-get update && apt-get install -y apt-transport-https
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

# Set the working directory
ONBUILD RUN mkdir -p /usr/src/app
ONBUILD WORKDIR /usr/src/app

# Copy dependency spec files
ONBUILD COPY package.json* yarn.lock* .npmrc* Gemfile* /usr/src/app/

# Install NPMs
ONBUILD RUN if [ -f package.json ]; then \
    yarn install || { echo "\033[0;31mMake sure you have run 'npm login' and have an ~/.npmrc file" && exit 1; }; \
    rm -f .npmrc; \
    fi;

# Install gems
ONBUILD COPY vendor /usr/src/app/vendor
ONBUILD RUN bundle install --local --jobs `nproc`

# Copy the rest of the application source
ONBUILD COPY . /usr/src/app

# Run the requirejs optimizer if the badcom gem is included and precompile assets.
ONBUILD RUN \
  ! gem list -i badcom > /dev/null || RAILS_ENV=production RAILS_ASSETS_COMPILE=true rake badcom:requirejs:optimize_all && \
  RAILS_ENV=production RAILS_ASSETS_COMPILE=true rake assets:precompile

# Run the server
ONBUILD EXPOSE 3000
ONBUILD CMD ["puma", "-t", "8:8", "-p", "3000"]
