FROM ubuntu:22.04

# Éviter les prompts interactifs (timezone, etc.)
ENV DEBIAN_FRONTEND=noninteractive

# Version de Flutter à installer (dernier patch de la branche stable 3.44)
ENV FLUTTER_VERSION=3.44.9

# Dépendances nécessaires
RUN apt update && apt --yes upgrade && \
    apt install --yes \
        curl \
        xz-utils \
        git \
        unzip \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Répertoire d'installation
WORKDIR /root/development

# Téléchargement et extraction du SDK Flutter
RUN curl -sL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        --output flutter.tar.xz && \
    tar xf flutter.tar.xz && \
    rm flutter.tar.xz

# Autoriser le répertoire git (nécessaire pour flutter en root/Docker)
RUN git config --global --add safe.directory /root/development/flutter

# Ajout de Flutter au PATH
ENV PATH="/root/development/flutter/bin:${PATH}"

# Pré-téléchargement des artefacts Flutter
RUN flutter precache

# Vérification de l'installation (facultatif mais utile pour le build)
RUN flutter doctor -v

WORKDIR /app

CMD ["flutter", "--version"]