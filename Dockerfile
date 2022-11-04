FROM alpine

ARG NH_VER=3.6.6
ARG JNH_VER=3.6.6-0.6

RUN \
  apk update && \
  apk upgrade && \
  apk add musl-locales ncurses && \
  apk add --virtual .build byacc curl flex gcc groff gnu-libiconv linux-headers make musl-dev ncurses-dev patch util-linux && \
  ln -s libncurses.so /usr/lib/libtinfo.so && \
  curl -sL https://nethack.org/download/${NH_VER}/nethack-${NH_VER//.}-src.tgz | tar zx && \
  ( \
    cd NetHack-NetHack-${NH_VER}_Released && \
    curl -sL https://ja.osdn.net/dl/jnethack/jnethack-${JNH_VER}.diff.gz | gzip -dc | gnu-iconv -f cp932 -t euc-jp -c | patch -p1 && \
    sed -i -e 's/cp -n/cp/g' -e '/^PREFIX/s:=.*:=/usr:' sys/unix/hints/linux && \
    sh sys/unix/setup.sh sys/unix/hints/linux && \
    make all && \
    make install \
  ) && \
  rm -rf NetHack-NetHack-${NH_VER}_Released && \
  apk del --purge .build

ENV LANG en_US.UTF-8
ENV NETHACKOPTIONS kcode:u

# for backup
VOLUME /usr/games/lib/jnethackdir

ENTRYPOINT ["/usr/games/jnethack"]
