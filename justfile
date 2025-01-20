set positional-arguments
set shell := ["bash", "-cue"]

root_dir := `git rev-parse --show-toplevel`

# Default recipe to list all recipes.
default:
    just --list

# Format the synth-converter.
fmt *args:
    yamlfmt **/*.y{a,}ml

# Run the synth-converter.
apply input_file output_file *args:
    cd "{{root_dir}}/synth-converter" && \
    kubectl apply --kustomize argo-workflows

# Enter a Nix development shell.
nix-develop *args:
    echo "Starting nix developer shell in './tools/nix/flake.nix'."
    cd "{{root_dir}}" && \
    cmd=("$@") && \
    { [ -n "${cmd:-}" ] || cmd=("zsh"); } && \
    nix develop ./tools/nix#default --accept-flake-config --command "${cmd[@]}"
