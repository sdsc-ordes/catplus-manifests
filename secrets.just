SECRETS_ENC := "./secrets/secrets.enc.yaml"
SECRETS_DEC := "./secrets/secrets.dec.yaml"
export SOPS_AGE_KEY_FILE := "./.sops.agekey"
set shell := ["bash", "-cue"]

# Default recipe to list all recipes.
default:
    just --list secrets

# Create key file to use with sops.
generate-key:
  @echo "Generating key..."
  @age-keygen -o {{SOPS_AGE_KEY_FILE}}

# see here for usage of sops+age: https://github.com/getsops/sops?tab=readme-ov-file#encrypting-using-age
# create decrypted secrets file.
decrypt:
  @echo "Decrypting secrets..."
  @sops --age $(grep -oP 'public key: \K(.*)' {{SOPS_AGE_KEY_FILE}}) -d "{{SECRETS_ENC}}" > "{{SECRETS_DEC}}"

# Create encrypted secrets file.
encrypt:
  @echo "Encrypting secrets..."
  @sops --age $(grep -oP 'public key: \K(.*)' {{SOPS_AGE_KEY_FILE}}) -e "{{SECRETS_DEC}}" > "{{SECRETS_ENC}}"

# Deploy decrypted secrets to cluster.
deploy:
  @sops exec-file {{SECRETS_ENC}} kubectl apply --kustomize tmp-file
