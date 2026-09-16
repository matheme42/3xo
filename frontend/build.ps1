# Build & run le conteneur Flutter web wasm.
# Pour Windows (PowerShell natif). Équivalent de build.sh.

$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot
$ImageName = "flutter-3.44-devenv"
$DockerfileDir = Join-Path $ScriptDir "..\dev-tools"

$imageExists = docker images -q $ImageName

if ([string]::IsNullOrWhiteSpace($imageExists)) {
    Write-Host "Image '$ImageName' introuvable, construction en cours depuis $DockerfileDir..."

    $dockerfilePath = Join-Path $DockerfileDir "Dockerfile"
    if (-not (Test-Path $dockerfilePath)) {
        Write-Error "Erreur : aucun Dockerfile trouvé dans $DockerfileDir"
        exit 1
    }

    docker build -t $ImageName $DockerfileDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
else {
    Write-Host "Image '$ImageName' déjà présente, on continue."
}

docker run -it -v "${ScriptDir}:/app" $ImageName bash -c "flutter build web --wasm"
exit $LASTEXITCODE