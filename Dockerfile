# ====== Stage 1: ビルド環境の構築と依存パッケージのインストール ======
# ベースイメージ:Debianの軽量版
FROM debian:bookworm-slim

LABEL maintainer="Xpotato1024 <321miyuto@xpotato.net>"

# 環境変数でバージョンを定義
ENV PANDOC_VERSION="3.1.13"
ENV CROSSREF_VERSION="v0.3.17.1"

# ロケールを設定
ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

# パッケージのインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # --- システムの基本ツール ---
    ca-certificates \
    curl \
    git \
    locales \
    unzip \
    wget \
    xz-utils \
    # --- 日本語フォント ---
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    # --- TeX Live (LuaLaTeXと日本語環境) ---
    lmodern \
    texlive-luatex \
    texlive-lang-japanese \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-pictures \
    texlive-science \
    && \
    # --- 日本語ロケールの有効化 ---
    sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
    
    # --- TeX Liveパッケージリポジトリ設定 ---
RUN tlmgr init-usertree && \
    tlmgr option repository https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2022/tlnet-final/ && \
    # --- tex-liveに含まれない必要パッケージをインストール ---
    tlmgr install chemgreek simplekv chemmacros chemfig genealogytree minted tikzsymbols

    # --- Pandocのインストール ---
RUN wget "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb" && \
    dpkg -i "pandoc-${PANDOC_VERSION}-1-amd64.deb" && \
    # --- pandoc-crossrefのインストール ---
    wget "https://github.com/lierdakil/pandoc-crossref/releases/download/${CROSSREF_VERSION}/pandoc-crossref-Linux.tar.xz" && \
    tar -xJf pandoc-crossref-Linux.tar.xz -C /usr/local/bin && \
    # --- 不要になったファイルのクリーンアップ ---
    rm "pandoc-${PANDOC_VERSION}-1-amd64.deb" \
       "pandoc-crossref-Linux.tar.xz" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ====== Stage 2: 最終的な実行環境の設定 ======

# インストールが正しく行われたかを確認
RUN pandoc --version && pandoc-crossref --version && lualatex --version

# 作業ディレクトリとエントリーポイントを設定
WORKDIR /data
ENTRYPOINT ["pandoc"]