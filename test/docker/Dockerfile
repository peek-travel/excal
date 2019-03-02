FROM beardedeagle/alpine-elixir-builder:1.8.1

ENV REFRESHED_AT 2019-03-01
ENV LIBICAL_VERSION v3.0.4

# install builds dependencies for libical
RUN apk --no-cache --update upgrade && \
  apk --no-cache add git make cmake icu-dev perl gcc g++ musl-dev libc-dev

# fetch and install libical from source/master
RUN mkdir /opt/src && \
  cd /opt/src && \
  git clone --branch $LIBICAL_VERSION https://github.com/libical/libical.git && \
  mkdir libical/build && \
  cd libical/build && \
  cmake -DWITH_CXX_BINDINGS=false \
  -DICAL_BUILD_DOCS=false \
  -DICAL_GLIB=false \
  -DCMAKE_RELEASE_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DSHARED_ONLY=true \
  .. && \
  make && \
  make install

WORKDIR /opt/app/
COPY . /opt/app/

ENV MIX_ENV test

RUN mix do deps.get, deps.compile, compile --warnings-as-errors

CMD ["mix", "test"]
