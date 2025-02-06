# We assume all encrypted secrets follow the naming pattern {{SECRET_DIR}}/*{{ENC_SUFFIX}}
SECRETS_DIR := "./secrets"
ENC_SUFFIX := ".enc.yaml"
DEC_SUFFIX := ".dec.yaml"
root_dir := `git rev-parse --show-toplevel`
export SOPS_AGE_KEY_FILE := "./.sops.agekey"
set shell := ["bash", "-cue"]

# Default recipe to list all recipes.
[private]
default:
    just --list secrets --no-aliases

# Edit an encrypted secrets file in place
edit secret_file:
  @cd {{root_dir}} && \
    sops {{secret_file}}

alias keygen := generate-key
# Create key file to use with sops.
generate-key:
  @echo "Generating key..."
  @cd {{root_dir}} && \
  age-keygen -o {{SOPS_AGE_KEY_FILE}}

# Update key configs based on .sops.yaml.
update-keys:
  @echo "Updating keys in secret files"
  @cd {{root_dir}} && \
  @fd {{ENC_SUFFIX}} {{SECRETS_DIR}} --exec "sops updatekeys {}"

# see here for usage of sops+age: https://github.com/getsops/sops?tab=readme-ov-file#encrypting-using-age
# Decrypts all secrets files.
decrypt:
  @echo "Decrypting secrets..."
  @cd {{root_dir}} && \
    for enc in {{SECRETS_DIR}}/*{{ENC_SUFFIX}}; do \
      sops --age $(grep -oP 'public key: \K(.*)' {{SOPS_AGE_KEY_FILE}}) \
        -d ${enc} \
        > ${enc%{{ENC_SUFFIX}}}{{DEC_SUFFIX}}; \
    done

# Create encrypted secrets file.
encrypt:
  @echo "Encrypting secrets..."
  @cd {{root_dir}} && \
    for dec in {{SECRETS_DIR}}/*{{DEC_SUFFIX}}; do \
      sops -e ${dec} > ${dec%{{DEC_SUFFIX}}}{{ENC_SUFFIX}} && \
      rm ${dec}; \
    done

alias apply := deploy
# Deploy decrypted secrets to cluster.
deploy:
  @cd "{{root_dir}}" && \
  for enc in {{SECRETS_DIR}}/*{{ENC_SUFFIX}}; do \
    sops exec-file ${enc} 'kubectl apply -f {}'; \
  done

