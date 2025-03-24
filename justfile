set positional-arguments
set shell := ["bash", "-cue"]

root_dir := `git rev-parse --show-toplevel`


# Default recipe to list all recipes.
[private]
default:
    just --list --no-aliases

alias fmt := format
# Format the whole repository.
format *args:
    treefmt {{args}}

# Clean up external and generated manifests.
clean:
    @echo "Cleaning up..."
    rm -rf external/{helm,ytt}/**
    rm -rf src/**/{ytt,helm}/out

# Fetch manifest dependencies
fetch:
  vendir sync -f vendir.yaml --chdir external

# Render Helm charts [intermediate step before rendering ytt manifests]
[private]
render-helm:
  # render external helm charts with our values into src/<service>/helm/out
  cd {{root_dir}} && \
    fd '^helm$' src/ \
      -x sh -c 'helm template $(basename {//}) external/helm/$(basename {//}) -f {}/values.yaml --output-dir {}/out'

# Render ytt manifests
[private]
render-ytt:
  # render external ytt templates with our values into src/<service>/ytt/out
  cd {{root_dir}} && \
    fd '^ytt$' src/ \
      -x sh -c 'ytt -f {}/values.yaml -f external/ytt/$(basename {//}) --output-files {}/out'

# Render manifests
render:
  cd {{root_dir}} && \
    just clean && \
    just fetch && \
    just render-helm && \
    just render-ytt && \
    just format

alias apply := deploy
# Apply manifests to the cluster.
deploy dir="./src/":
    @cd "{{root_dir}}" && \
    kubectl apply --kustomize {{dir}}

alias dev := develop
# Enter a Nix development shell.
develop *args:
    @echo "Starting nix developer shell in './tools/nix/flake.nix'."
    @cd "{{root_dir}}" && \
    cmd=("$@") && \
    { [ -n "${cmd:-}" ] || cmd=("zsh"); } && \
    nix develop ./tools/nix#default --accept-flake-config --command "${cmd[@]}"

# Manage secrets. Run `just secrets` for more info
mod secrets 'tools/just/secrets.just'
