# --- Base: TeXLive on Debian ---
FROM ghcr.io/xu-cheng/texlive-historic-debian:2020 AS texlive

# --- Layer 2: Build Noweb ---
FROM texlive AS noweb-builder

# Install build tools (cached unless changed)
RUN apt-get update && apt-get install -y \
    make gcc git curl wget build-essential \
    && apt-get clean

# Build and install this version of gawk (from upstream)
ENV GAWK_VERSION="5.3.0"
WORKDIR /opt
RUN wget --quiet https://ftp.gnu.org/gnu/gawk/gawk-${GAWK_VERSION}.tar.gz && \
    tar -xzf gawk-${GAWK_VERSION}.tar.gz
WORKDIR /opt/gawk-${GAWK_VERSION}
RUN ./configure && make && make install

RUN update-alternatives --remove-all awk || true && \
    update-alternatives --install /usr/bin/awk awk /usr/local/bin/gawk 10

# --- Step 1: Clone and build noweb ---
WORKDIR /opt
RUN git clone https://github.com/bryce-carson/noweb.git

# Set environment variables for installation locations
ENV NOWEB_BIN=/usr/local/bin \
    NOWEB_LIB=/usr/local/share/noweb \
    NOWEB_MAN=/usr/local/share/man \
    NOWEB_TEXINPUTS=/usr/local/share/texmf/tex/latex/knoweb \
    KNOWEB_SRC=/opt/knoweb \
    KNOWEB_STYLE_DEST=/usr/local/share/texmf/tex/latex/knoweb \
    TEXINPUTS="/usr/local/share/texmf/tex/latex//:" \
    NOWEB_SRC=/opt/noweb/src

# Build and install Noweb into /usr/local/bin
# Build and install Noweb using shell arguments instead of editing Makefile
WORKDIR ${NOWEB_SRC}
RUN ./awkname gawk

## Dry run, with detail, to help debugging.
ARG GITHUB_CI_BUILD="false"
RUN <<ETX
if [ "$GITHUB_CI_BUILD" = "true" ]; then
    RUN touch ${NOWEB_SRC}/c/*.c ${NOWEB_SRC}/c/*.h
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
    all
ETX
RUN make -j1 install

# --- Step 2: Clone and build JoeRiel/knoweb ---
WORKDIR /opt
RUN git clone https://github.com/JoeRiel/knoweb.git

# --- Step 3: Use notangle and noweave to generate knoweb.sty ---
WORKDIR /opt/knoweb
RUN $NOWEB_BIN/notangle -Rknoweb.sty knoweb.nw > knoweb.sty && \
    mkdir -p $KNOWEB_STYLE_DEST && \
    cp -t $KNOWEB_STYLE_DEST knoweb.sty

RUN $NOWEB_BIN/notangle -Rautodefs.elisp autodefs.nw > autodefs.elisp && \
    mkdir -p $NOWEB_LIB && \
    cp -t $NOWEB_LIB autodefs.elisp && \
    sed -i 's,#!/usr/bin/gawk --file,#!/usr/local/bin/gawk --file,' ${NOWEB_LIB}/autodefs.elisp && \
    chmod +x $NOWEB_LIB/autodefs.elisp

# --- Step 4: Refresh TeX file database so TeXLive finds knoweb.sty ---
RUN mktexlsr /usr/local/share/texmf

# --- Final Layer: Build your Whyse project ---
FROM noweb-builder AS whyse-builder

# --- Step 5: Copy the whyse sources into the container and build the PDF, Emacs package, and other artifacts. ---
COPY . /workspace
WORKDIR /workspace
RUN make \
    NOWEB_LIB=$NOWEB_LIB \
    SRC=/workspace/src \
    BUILD=/workspace/build \
    TEST=/workspace/test \
    pdf
# --- Final output stage (optional): expose only artifacts ---
FROM debian:stable-slim AS output
COPY --from=whyse-builder /workspace/build /build

# Optional: expose as volume or artifact directory
VOLUME ["/build"]
