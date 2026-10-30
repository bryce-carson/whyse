# Compiling the literate document with knoweb seems to require TeXLive 2020 on
# Debian, specifically. Other combinations of operating system and TeXLive
# distribution seem to result in document errors with knoweb (which is a vast
# improvement over the vanilla noweb.sty). First update the installed Debian
# packages and then install build dependencies for noweb, including GNU AWK.
FROM ghcr.io/xu-cheng/texlive-historic-debian:2020 AS texlive
FROM texlive AS noweb-builder
RUN apt-get update && \
    apt-get install -y make gcc git curl wget build-essential && \
    apt-get clean



# Build a more recent GNU AWK than what's provided with the base image of Debian.
ENV GAWK_VERSION="5.3.0"
WORKDIR /opt
RUN wget --quiet https://ftp.gnu.org/gnu/gawk/gawk-${GAWK_VERSION}.tar.gz && \
    tar -xzf gawk-${GAWK_VERSION}.tar.gz
WORKDIR /opt/gawk-${GAWK_VERSION}
RUN ./configure && make && make install
RUN update-alternatives --remove-all awk || true && \
    update-alternatives --install /usr/bin/awk awk /usr/local/bin/gawk 10

# Set environment variables for installation locations
WORKDIR /opt
RUN git clone https://github.com/bryce-carson/noweb.git
ENV NOWEB_BIN=/usr/local/bin \
    NOWEB_LIB=/usr/local/share/noweb \
    NOWEB_MAN=/usr/local/share/man \
    NOWEB_TEXINPUTS=/usr/local/share/texmf/tex/latex/knoweb \
    KNOWEB_SRC=/opt/knoweb \
    KNOWEB_STYLE_DEST=/usr/local/share/texmf/tex/latex/knoweb \
    TEXINPUTS="/usr/local/share/texmf/tex/latex//:" \
    NOWEB_SRC=/opt/noweb/src
WORKDIR ${NOWEB_SRC}
RUN ./awkname gawk

## Dry run, with detail, to help debugging.
ARG GITHUB_CI_BUILD="false"
RUN <<ETX
if [ "$GITHUB_CI_BUILD" = "true" ]; then
    echo "Running in GitHub CI!";
    touch ${NOWEB_SRC}/c/*.c ${NOWEB_SRC}/c/*.h;
    cd c && make -j1 -nd markup;
    make -j1 -n -d CC="gcc" CFLAGS="-Wall" \
    BIN=$NOWEB_BIN \
    LIB=$NOWEB_LIB \
    MAN=$NOWEB_MAN \
    TEXINPUTS=$NOWEB_TEXINPUTS \
    all;
fi
ETX

# Build noweb with the desired paths.
RUN <<ETX
    make -j1 CC="gcc" CFLAGS="-Wall" \
    BIN=$NOWEB_BIN \
    LIB=$NOWEB_LIB \
    MAN=$NOWEB_MAN \
    TEXINPUTS=$NOWEB_TEXINPUTS
ETX
# Install noweb to the desired paths.
RUN <<ETX
    make install -j1 CC="gcc" CFLAGS="-Wall" \
    BIN=$NOWEB_BIN \
    LIB=$NOWEB_LIB \
    MAN=$NOWEB_MAN \
    TEXINPUTS=$NOWEB_TEXINPUTS
ETX




# Build WHYSE
FROM noweb-builder AS whyse-builder
COPY . /workspace
WORKDIR /workspace
RUN make NOWEB_BIN="${NOWEB_BIN}" NOWEB_LIB="${NOWEB_LIB}" SRC="/workspace/src" BUILD="/workspace/build" TEST="/workspace/test"
RUN make NOWEB_BIN="${NOWEB_BIN}" NOWEB_LIB="${NOWEB_LIB}" SRC="/workspace/src" BUILD="/workspace/build" TEST="/workspace/test" whyse.pdf





# I think debian:stable-slim is the base image of xu-cheng/texlive-historic-debian:2020.
FROM debian:stable-slim AS output
COPY --from=whyse-builder /workspace/build /build
VOLUME ["/build"]
