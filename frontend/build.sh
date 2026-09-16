#!/usr/bin/env bash
# Build & run le conteneur Flutter web wasm.
# Compatible macOS / Linux nativement, et Windows via Git Bash ou WSL.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGE_NAME="flutter-3.44-devenv"
DOCKERFILE_DIR="${SCRIPT_DIR}/../dev-tools"

if [[ -z "$(docker images -q "${IMAGE_NAME}" 2>/dev/null)" ]]; then
    echo "Image '${IMAGE_NAME}' introuvable, construction en cours depuis ${DOCKERFILE_DIR}..."

    if [[ ! -f "${DOCKERFILE_DIR}/Dockerfile" ]]; then
        echo "Erreur : aucun Dockerfile trouvé dans ${DOCKERFILE_DIR}" >&2
        exit 1
    fi

    docker build -t "${IMAGE_NAME}" "${DOCKERFILE_DIR}"
else
    echo "Image '${IMAGE_NAME}' déjà présente, on continue."
fi

docker run -it -v "${SCRIPT_DIR}":/app "${IMAGE_NAME}" bash -c "flutter build web --wasm"