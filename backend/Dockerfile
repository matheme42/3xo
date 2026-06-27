# Étape 1 : Build de l'application Dart avec le SDK officiel
FROM dart:stable AS build

WORKDIR /app

# Copie d'abord les specs pour optimiser le cache des dépendances
COPY pubspec.yaml ./
RUN dart pub get

# /!\ ATTENTION : Si tu utilises le package partagé 'shared_models', 
# tu dois t'assurer que Docker y a accès. 
# Si 'shared_models' est un dossier parent, copie-le également :
# COPY ../shared_models /shared_models

COPY . .
RUN dart pub get

# Compilation en binaire natif ultra-léger et rapide
RUN dart compile exe bin/server.dart -o bin/server

# Étape 2 : Runtime minimaliste pour l'exécution (Conteneur final très léger)
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server

# Expose le port interne du conteneur
EXPOSE 8080

# Exécute le serveur
CMD ["/app/bin/server"]
