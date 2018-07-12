FROM alpine

ARG NH_VER=3.6.1
ARG JNH_VER=3.6.1-0.1

RUN \
  apk --no-cache add byacc curl flex gcc groff linux-headers make musl-dev ncurses-dev util-linux && \
  apk --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing add gnu-libiconv && \
  curl -sL http://www.nethack.org/download/${NH_VER}/nethack-${NH_VER//.}-src.tgz | tar zxf - && \
  ( \
    cd nethack-${NH_VER} && \
    curl -sL https://ja.osdn.net/dl/jnethack/jnethack-${JNH_VER}.diff.gz | zcat | gnu-iconv -f cp932 -t euc-jp | patch -p2 && \
    sed -i -e 's/cp -n/cp/g' -e '/^PREFIX/s:=.*:=/usr:' sys/unix/hints/linux && \
    sh sys/unix/setup.sh sys/unix/hints/linux && \
    make all && \
    make install \
  ) && \
  rm -rf nethack-${NH_VER}

ENV LANG ja_JP.UTF-8
ENV NETHACKOPTIONS kcode:u

# for backup
VOLUME /usr/games/lib/jnethackdir

ENTRYPOINT ["/usr/games/jnethack"]
