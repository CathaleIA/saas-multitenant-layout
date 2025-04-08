sam build -t shared-template.yaml
sam deploy --config-file shared-samconfig.toml


sam build -t tenant-template.yaml
sam deploy --config-file tenant-samconfig.toml