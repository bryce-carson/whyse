# --- Base: TeXLive on Debian ---
FROM ghcr.io/xu-cheng/texlive-historic-debian:2020 AS texlive

# --- Layer 2: Build Noweb ---
FROM texlive AS noweb-builder

# Install build tools (cached unless changed)
RUN apt-get update && apt-get install -y \
    make gcc git curl \
    && apt-get clean

# --- Step 1: Clone and build noweb ---
WORKDIR /opt
RUN git clone https://github.com/bryce-carson/noweb.git

# Set environment variables for installation locations
ENV NOWEB_BIN=/usr/local/bin \
    NOWEB_LIB=/usr/local/share/noweb \
    NOWEB_MAN=/usr/local/share/man \
    NOWEB_TEXINPUTS=/usr/local/share/texmf/tex/latex/noweb \
    KNOWEB_SRC=/opt/knoweb \
    KNOWEB_STYLE_DEST=/usr/local/share/texmf/tex/latex/noweb

# Build and install Noweb into /usr/local
# Build and install Noweb using shell arguments instead of editing Makefile
WORKDIR /opt/noweb
RUN make CC=gcc CFLAGS="-Wall" \
BIN=$NOWEB_BIN \
    LIB=$NOWEB_LIB \
    MAN=$NOWEB_MAN \
    TEXINPUTS=$NOWEB_TEXINPUTS \
    all install

# --- Step 2: Clone and build JoeRiel/knoweb ---
WORKDIR /opt
RUN git clone https://github.com/JoeRiel/knoweb.git

# --- Step 3: Use notangle and noweave to generate knoweb.sty ---
WORKDIR /opt/knoweb
RUN $NOWEB_BIN/notangle -Rknoweb.sty knoweb.nw > knoweb.sty && \
    mkdir -p $KNOWEB_STYLE_DEST && \
    cp knoweb.sty $KNOWEB_STYLE_DEST

# --- Step 4: Refresh TeX file database so TeXLive finds knoweb.sty ---
RUN mktexlsr /usr/local/share/texmf

# --- Final Layer: Build your Whyse project ---
FROM noweb-builder AS whyse-builder

# --- Step 5: Copy the whyse sources into the container and build the PDF, Emacs package, and other artifacts. ---
COPY . /workspace
WORKDIR /workspace
RUN ./docker-build.sh
RUN make \
    NOWEB_LIB=/usr/local/share/noweb \
    SRC=/workspace/src \
    BUILD=/workspace/build \
    TEST=/workspace/test \
    pdf
# --- Final output stage (optional): expose only artifacts ---
FROM debian:stable-slim AS output
COPY --from=whyse-builder /workspace/build /build

# Optional: expose as volume or artifact directory
VOLUME ["/build"]
