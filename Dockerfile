FROM debian:bookworm-slim@sha256:b29f74a267526ae6ea104eed6c46133b0ca70ce812525df8cd5817698f0a624a

LABEL maintainer="Xpotato1024 <321miyuto@xpotato.net>"

ARG PANDOC_VERSION="3.1.13"
ARG PANDOC_DEB_SHA256="b51029afd2e302679aabb9464cd96bda378145d48bb853bd32d93c57b93a293d"
ARG CROSSREF_VERSION="v0.3.17.1"
ARG CROSSREF_TAR_XZ_SHA256="52a21ef8945e664e7ccfea5f40268db3e3ddee4e7ce1f47f24716fea37c2410e"

ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    locales \
    unzip \
    xz-utils \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    lmodern \
    texlive-luatex \
    texlive-lang-japanese \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-pictures \
    texlive-science && \
    sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

# Keep these values in sync with docs/release.md when updating the image.
RUN tlmgr init-usertree && \
    tlmgr option repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2022/tlnet-final/ && \
    tlmgr install chemgreek simplekv chemmacros chemfig genealogytree minted tikzsymbols

RUN curl -fsSLo "pandoc-${PANDOC_VERSION}-1-amd64.deb" \
        "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb" && \
    echo "${PANDOC_DEB_SHA256}  pandoc-${PANDOC_VERSION}-1-amd64.deb" | sha256sum -c - && \
    dpkg -i "pandoc-${PANDOC_VERSION}-1-amd64.deb" && \
    curl -fsSLo "pandoc-crossref-Linux.tar.xz" \
        "https://github.com/lierdakil/pandoc-crossref/releases/download/${CROSSREF_VERSION}/pandoc-crossref-Linux.tar.xz" && \
    echo "${CROSSREF_TAR_XZ_SHA256}  pandoc-crossref-Linux.tar.xz" | sha256sum -c - && \
    tar -xJf pandoc-crossref-Linux.tar.xz -C /usr/local/bin && \
    rm -f "pandoc-${PANDOC_VERSION}-1-amd64.deb" "pandoc-crossref-Linux.tar.xz" && \
    apt-get clean

COPY csl /app/csl
COPY preamble /app/preamble
COPY templates /app/templates

RUN pandoc --version && pandoc-crossref --version && lualatex --version

WORKDIR /data
ENTRYPOINT ["pandoc"]
