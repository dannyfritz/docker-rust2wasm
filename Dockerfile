FROM ubuntu
MAINTAINER Danny Fritz <dannyfritz@gmail.com>

# Install Rust
ENV RUST_VERSION=1.13.0
ENV RUST_ARCHIVE=rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz
ENV RUST_DOWNLOAD_URL=https://static.rust-lang.org/dist/$RUST_ARCHIVE
# Required by cargo
ENV USER root
RUN apt-get update -y \
  &&  apt-get install -qqy --no-install-recommends \
        ca-certificates curl gcc libc6-dev \
  &&  curl -fsOSL $RUST_DOWNLOAD_URL \
  &&  curl -s $RUST_DOWNLOAD_URL.sha256 | sha256sum -c - \
  &&  mkdir /rust \
  &&  tar -C /rust -xzf $RUST_ARCHIVE --strip-components=1 \
  &&  rm $RUST_ARCHIVE \
  &&  cd /rust \
  &&  ./install.sh --without=rust-docs \
  &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  &&  apt-get -y --purge remove curl gcc libc6-dev \
  &&  apt-get -y clean \
  &&  apt-get -y autoclean \
  &&  apt-get -y autoremove \
  &&  echo "RUST BUILD FINISHED"

# Install Incoming Emscripten
ENV EMSCRIPTEN_ARCHIVE=emsdk-portable.tar.gz
ENV EMSCRIPTEN_DOWNLOAD_URL=https://s3.amazonaws.com/mozilla-games/emscripten/releases/$EMSCRIPTEN_ARCHIVE
ENV EMSCRIPTEN_ARCH=incoming-64bit
RUN apt-get update -y && apt-get install -qqy --no-install-recommends \
        curl git ca-certificates build-essential python cmake \
  &&  curl $EMSCRIPTEN_DOWNLOAD_URL -o $EMSCRIPTEN_ARCHIVE \
  &&  mkdir /emscripten \
  &&  tar -C /emscripten -xzf $EMSCRIPTEN_ARCHIVE --strip-components=1 \
  &&  rm $EMSCRIPTEN_ARCHIVE \
  &&  cd /emscripten \
  &&  rm -rf bin \
  &&  ./emsdk update \
  &&  ./emsdk install clang-$EMSCRIPTEN_ARCH emscripten-$EMSCRIPTEN_ARCH sdk-$EMSCRIPTEN_ARCH \
  &&  ./emsdk activate clang-incoming-64bit emscripten-$EMSCRIPTEN_ARCH sdk-$EMSCRIPTEN_ARCH \
  &&  /bin/bash -c "source ./emsdk_env.sh" \
  &&  rm -rf ~/emsdk_portable/clang/tag-*/src  \
  &&  find . -name "*.o" -exec rm {} \; \
  &&  find . -name "*.a" -exec rm {} \; \
  &&  find . -name "*.tmp" -exec rm {} \; \
  &&  find . -type d -name ".git" -prune -exec rm -rf {} \; \
  &&  apt-get -y --purge remove curl git \
  &&  apt-get -y clean \
  &&  apt-get -y autoclean \
  &&  apt-get -y autoremove \
  &&  echo "EMSCRIPTEN BUILD FINISHED"

VOLUME ["/source"]
WORKDIR /source

CMD ["/bin/bash"]