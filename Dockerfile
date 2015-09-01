FROM ruby:2.2.3

# Install MySQL library files
RUN apt-get update && apt-get install -y \
  libmysqlclient-dev \
  libxml2 \
  libxslt1.1 \
  --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Configure bundler
RUN \
  bundle config --global frozen 1 && \
  bundle config --global build.nokogiri --use-system-libraries 

# Install node.js
ENV NODE_VERSION=0.12.7
RUN \
  cd /usr/local && \
  curl -fLO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz && \
  tar --strip-components 1 -xzf node-v$NODE_VERSION-linux-x64.tar.gz node-v$NODE_VERSION-linux-x64/bin/node && \
  rm node-v$NODE_VERSION-linux-x64.tar.gz

# Install node.js
ENV KUBERNETES_SECRET_ENV_VERSION=0.0.1-rc0
RUN \
  mkdir -p /etc/secret-volume && \
  cd /usr/local/bin && \
  curl -fLO https://github.com/buth/kubernetes-secret-env/releases/download/v$KUBERNETES_SECRET_ENV_VERSION/kubernetes-secret-env && \
  chmod +x kubernetes-secret-env

# Set the working directory
ONBUILD RUN mkdir -p /usr/src/app
ONBUILD WORKDIR /usr/src/app

# Install gems
ONBUILD COPY Gemfile Gemfile.lock /usr/src/app/
ONBUILD COPY vendor /usr/src/app/vendor
ONBUILD RUN bundle install --local --jobs `nproc`

# Copy the rest of the application source
ONBUILD COPY . /usr/src/app

# Run the requirejs optimizer if the badcom gem is included and precompile assets.
ONBUILD RUN \
  ! gem list -i badcom > /dev/null || RAILS_ENV=production rake badcom:requirejs:optimize_all && \
  RAILS_ENV=production rake assets:precompile

# Run the server
ONBUILD EXPOSE 3000
ONBUILD CMD ["kubernetes-secret-env", "puma", "-t", "16:16", "-p", "3000"]
