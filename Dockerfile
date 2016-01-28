FROM ruby:2.3.0

# Configure bundler
RUN \
  bundle config --global frozen 1 && \
  bundle config --global build.nokogiri --use-system-libraries 

# Install cmake
ENV CMAKE_MAJOR=3.4
ENV CMAKE_VERSION=3.4.3
ENV CMAKE_SHASUM256=66b8d315c852908be9f79e1a18b8778714659fce4ddb2d041af8680a239202fc
RUN \
  cd /usr/local && \
  curl -sfLO https://cmake.org/files/v$CMAKE_MAJOR/cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz && \
  echo "${CMAKE_SHASUM256}  cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz" | sha256sum -c - &&\
  tar --strip-components 1 -xzf cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz cmake-$CMAKE_VERSION-Linux-x86_64/bin/cmake cmake-$CMAKE_VERSION-Linux-x86_64/share/cmake-$CMAKE_MAJOR/Modules cmake-$CMAKE_VERSION-Linux-x86_64/share/cmake-$CMAKE_MAJOR/Templates && \
  rm cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz

# Install libssh2 from source
ENV LIBSSH2_VERSION=1.6.0
RUN gpg --keyserver pgp.mit.edu --recv-keys 279D5C91 
RUN \
  cd /usr/local && \
  curl -sfLO http://www.libssh2.org/download/libssh2-$LIBSSH2_VERSION.tar.gz && \
  curl -sfLO http://www.libssh2.org/download/libssh2-$LIBSSH2_VERSION.tar.gz.asc && \
  gpg --verify libssh2-$LIBSSH2_VERSION.tar.gz.asc && \
  tar -xzf libssh2-$LIBSSH2_VERSION.tar.gz && \
  cd libssh2-$LIBSSH2_VERSION && \
  ./configure --with-openssl --without-libgcrypt --with-libz && \
  make install && \
  cd .. && \
  rm -r libssh2-$LIBSSH2_VERSION libssh2-$LIBSSH2_VERSION.* share/man/man3/libssh2_*

# Install node.js
ENV NODE_VERSION=5.5.0
ENV NODE_SHASUM256=3e593d91b6d2ad871efaaf8e9a17b3608ca98904959bcfb7c42e6acce89e80f4
RUN \
  cd /usr/local && \
  curl -sfLO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz && \
  echo "${NODE_SHASUM256}  node-v$NODE_VERSION-linux-x64.tar.gz" | sha256sum -c - &&\
  tar --strip-components 1 -xzf node-v$NODE_VERSION-linux-x64.tar.gz node-v$NODE_VERSION-linux-x64/bin node-v$NODE_VERSION-linux-x64/include node-v$NODE_VERSION-linux-x64/lib && \
  rm node-v$NODE_VERSION-linux-x64.tar.gz

# Install kubernetes-secret-env
ENV KUBERNETES_SECRET_ENV_VERSION=0.0.1-rc0
RUN \
  mkdir -p /etc/secret-volume && \
  cd /usr/local/bin && \
  curl -sfLO https://github.com/buth/kubernetes-secret-env/releases/download/v$KUBERNETES_SECRET_ENV_VERSION/kubernetes-secret-env && \
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
ONBUILD ENTRYPOINT ["kubernetes-secret-env"]
ONBUILD CMD ["puma", "-t", "16:16", "-p", "3000"]
