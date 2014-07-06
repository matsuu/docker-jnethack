FROM centos

RUN yum install -y bison bzip2 flex gcc glibc-headers make ncurses-devel patch tar wget

# for locale issue
RUN yum reinstall -y glibc glibc-common
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8

RUN wget \
  http://sourceforge.net/projects/nethack/files/nethack/3.4.3/nethack-343-src.tgz \
  http://jaist.dl.sourceforge.jp/jnethack/58545/jnethack-3.4.3-0.11.diff.gz \
  http://elbereth.up.seesaa.net/nethack/jnethack-3.4.3-0.10-utf8-2.patch.bz2

RUN tar zxf nethack-343-src.tgz && \
  cd nethack-3.4.3 && \
  gzip -dc ../jnethack-3.4.3-0.11.diff.gz | patch -p1 && \
  bzip2 -dc ../jnethack-3.4.3-0.10-utf8-2.patch.bz2 | patch -p1 && \
  sh sys/unix/setup.sh x && \
  sed -i -e "/^CFLAGS/s/-O/-O2 -fomit-frame-pointer/" sys/unix/Makefile.{src,utl} && \
  sed -i -e "/rmdir \.\/-p/d" sys/unix/Makefile.top && \
  sed -i -e "/# define XI18N/d" include/config.h && \
  sed -i -e "/XI18N/i #include <locale.h>" sys/unix/unixmain.c && \ 
  sed -i -e "s:/\* \(#define LINUX\) \*/:\1:" include/unixconf.h && \
  make all && \
  make install

ENV LANG ja_JP.UTF-8

# for backup
VOLUME /usr/games/lib/jnethackdir

CMD ["/usr/games/jnethack"]
