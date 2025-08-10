# THIS DOCKERFILE IS TANGLED FROM DOCKERFILE.NW. Read the woven version, DOCKERFILE.PDF in doc/Dockerfile.pdf.
# EDIT Dockerfile.nw to make editions.
FROM ghcr.io/xu-cheng/texlive-historic-debian:2020 AS texlive
FROM texlive AS noweb-builder
RUN apt-get update && \
    apt-get install -y make gcc git curl wget build-essential && \
    apt-get clean
ENV GAWK_VERSION="5.3.0"
WORKDIR /opt
RUN wget --quiet https://ftp.gnu.org/gnu/gawk/gawk-${GAWK_VERSION}.tar.gz && \
    tar -xzf gawk-${GAWK_VERSION}.tar.gz
WORKDIR /opt/gawk-${GAWK_VERSION}
RUN ./configure && make && make install
RUN update-alternatives --remove-all awk || true && \
    update-alternatives --install /usr/bin/awk awk /usr/local/bin/gawk 10
# Set environment variables for installation locations
ENV NOWEB_BIN=/usr/local/bin \
    NOWEB_LIB=/usr/local/share/noweb \
    NOWEB_MAN=/usr/local/share/man \
    NOWEB_TEXINPUTS=/usr/local/share/texmf/tex/latex/knoweb \
    KNOWEB_SRC=/opt/knoweb \
    KNOWEB_STYLE_DEST=/usr/local/share/texmf/tex/latex/knoweb \
    TEXINPUTS="/usr/local/share/texmf/tex/latex//:" \
    NOWEB_SRC=/opt/noweb/src
WORKDIR /opt
RUN git clone https://github.com/bryce-carson/noweb.git
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

RUN <<ETX
    make -j1 CC="gcc" CFLAGS="-Wall" \
    BIN=$NOWEB_BIN \
    LIB=$NOWEB_LIB \
    MAN=$NOWEB_MAN \
    TEXINPUTS=$NOWEB_TEXINPUTS \
    all install
ETX
WORKDIR /opt
RUN make knoweb
FROM noweb-builder AS whyse-builder
COPY . /workspace
WORKDIR /workspace
RUN make NOWEB_LIB="${NOWEB_LIB}" SRC="/workspace/src" BUILD="/workspace/build" TEST="/workspace/test" pdf
FROM debian:stable-slim AS output
COPY --from=whyse-builder /workspace/build /build
VOLUME ["/build"]
