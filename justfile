set positional-arguments
set shell := ["bash", "-cue"]

root_dir := `git rev-parse --show-toplevel`
SECRETS_ENC := "./k8s/base/secrets.enc.yaml"
SECRETS_DEC := "./k8s/base/secrets.dec.yaml"
SOPS_AGEKEY := "./.sops.agekey"


# Default recipe to list all recipes.
default:
    just --list

# Format manifests
fmt *args:
    yamlfmt **/*.y{a,}ml

# create decrypted secrets file
# see here for usage of sops+age: https://github.com/getsops/sops?tab=readme-ov-file#encrypting-using-age
decrypt-secrets:
  @echo "Decrypting secrets..."
  @sops --age <(grep -oP 'public key: \K(.*)' {{SOPS_AGEKEY}}) -d "{{SECRETS_ENC}}" > "{{SECRETS_DEC}}"

# create encrypted secrets file
encrypt-secrets:
  @echo "Encrypting secrets..."
  @sops --age <(grep -oP 'public key: \K(.*)' {{SOPS_AGEKEY}}) -e "{{SECRETS_DEC}}" > "{{SECRETS_ENC}}"

# apply manifests to the cluster
apply *args: decrypt-secrets
    cd "{{root_dir}}" && \
    kubectl apply --kustomize argo-workflows
    rm {{SECRETS_DEC}}

# Enter a Nix development shell.
nix-develop *args:
    echo "Starting nix developer shell in './tools/nix/flake.nix'."
    cd "{{root_dir}}" && \
    cmd=("$@") && \
    { [ -n "${cmd:-}" ] || cmd=("zsh"); } && \
    nix develop ./tools/nix#default --accept-flake-config --command "${cmd[@]}"
