set positional-arguments
set shell := ["bash", "-cue"]

root_dir := `git rev-parse --show-toplevel`


# Default recipe to list all recipes.
[private]
default:
    just --list --no-aliases

alias fmt := format
# Format manifests.
format *args:
    @cd "{{root_dir}}" && \
    yamlfmt **/*.y{a,}ml

# Render helm templates
render dir=".":
    @cd "{{root_dir}}" && \
    helm dependency build {{dir}}/helm-chart
    helm template {{dir}}-catplus {{dir}}/helm-chart --output-dir {{dir}}

alias apply := deploy
# Apply manifests to the cluster.
deploy dir=".":
    @cd "{{root_dir}}" && \
    kubectl apply --kustomize {{dir}}

alias dev := nix-develop
# Enter a Nix development shell.
nix-develop *args:
    @echo "Starting nix developer shell in './tools/nix/flake.nix'."
    @cd "{{root_dir}}" && \
    cmd=("$@") && \
    { [ -n "${cmd:-}" ] || cmd=("zsh"); } && \
    nix develop ./tools/nix#default --accept-flake-config --command "${cmd[@]}"

# Manage secrets. Run `just secrets` for more info
mod secrets 'tools/just/secrets.just'

