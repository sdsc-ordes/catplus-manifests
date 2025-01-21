set positional-arguments
set shell := ["bash", "-cue"]

root_dir := `git rev-parse --show-toplevel`


# Default recipe to list all recipes.
default:
    just --list

# Format manifests.
fmt *args:
    yamlfmt **/*.y{a,}ml


# Apply manifests to the cluster.
deploy *args:
    cd "{{root_dir}}" && \
    kubectl apply --kustomize

# Enter a Nix development shell.
nix-develop *args:
    echo "Starting nix developer shell in './tools/nix/flake.nix'."
    cd "{{root_dir}}" && \
    cmd=("$@") && \
    { [ -n "${cmd:-}" ] || cmd=("zsh"); } && \
    nix develop ./tools/nix#default --accept-flake-config --command "${cmd[@]}"

# Manage secrets. Run `just secrets` for more info
mod secrets 'tools/just/secrets.just'

