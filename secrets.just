SECRETS_ENC := "./secrets/secrets.enc.yaml"
SECRETS_DEC := "./secrets/secrets.dec.yaml"
SOPS_AGEKEY := "./.sops.agekey"

# Default recipe to list all recipes.
default:
    just --list secrets

# Create key file to use with sops.
generate-key:
  @echo "Generating key..."
  @age-keygen -o {{SOPS_AGEKEY}}

# create decrypted secrets file.
decrypt:
  @echo "Decrypting secrets..."
  # see here for usage of sops+age: https://github.com/getsops/sops?tab=readme-ov-file#encrypting-using-age
  @sops --age <(grep -oP 'public key: \K(.*)' {{SOPS_AGEKEY}}) -d "{{SECRETS_ENC}}" > "{{SECRETS_DEC}}"

# Create encrypted secrets file.
encrypt:
  @echo "Encrypting secrets..."
  @sops --age <(grep -oP 'public key: \K(.*)' {{SOPS_AGEKEY}}) -e "{{SECRETS_DEC}}" > "{{SECRETS_ENC}}"

# Deploy secrets to cluster
deploy:
  @kubectl apply --kustomize secrets
  @rm {{SECRETS_DEC}}
