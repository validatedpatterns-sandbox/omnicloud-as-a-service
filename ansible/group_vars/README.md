# Group Variables Structure

This directory contains organized variable files using Ansible's `group_vars` pattern. Variables are organized by cloud provider to improve maintainability and scalability.

## Directory Structure

```text
group_vars/
├── all/
│   └── main.yml          # Common variables for all providers
├── aws/
│   └── main.yml          # AWS-specific variables
├── azure/
│   └── main.yml          # Azure-specific variables
├── gcp/
│   └── main.yml          # GCP-specific variables
└── baremetal/
    └── main.yml          # Baremetal-specific variables
```

## How It Works

Ansible automatically loads variables from `group_vars` based on inventory groups. When you use the inventory file with `--limit`, Ansible loads:

1. `group_vars/all/main.yml` - Always loaded (common variables)
2. `group_vars/<provider>/main.yml` - Loaded when using `--limit <provider>`

## Usage

### Using Makefile (Recommended)

```bash
# Deploy to AWS
make install PROVIDER=aws

# Deploy to Azure
make install PROVIDER=azure

# Deploy to GCP
make install PROVIDER=gcp

# Destroy AWS cluster
make destroy PROVIDER=aws
```

### Using ansible-playbook directly

```bash
# Deploy to AWS
ansible-playbook site.yaml -i inventory.yml -e "@vars.yml" -e create=true --limit aws

# Deploy to Azure
ansible-playbook site.yaml -i inventory.yml -e "@vars.yml" -e create=true --limit azure

# Deploy to GCP
ansible-playbook site.yaml -i inventory.yml -e "@vars.yml" -e create=true --limit gcp
```

## Variable Precedence

Variables are loaded in this order (later overrides earlier):

1. `group_vars/all/main.yml` (lowest precedence)
2. `group_vars/<provider>/main.yml`
3. `vars.yml` (if specified with `-e "@vars.yml"`)
4. Command-line variables `-e "var=value"` (highest precedence)

## Adding Provider-Specific Variables

To add variables for a specific provider, edit the corresponding file:

- AWS: `group_vars/aws/main.yml`
- Azure: `group_vars/azure/main.yml`
- GCP: `group_vars/gcp/main.yml`
- Baremetal: `group_vars/baremetal/main.yml`

## Common Variables

Common variables that apply to all providers are in `group_vars/all/main.yml`:

- `cluster.*` - Cluster configuration
- `machinePools.*` - Machine pool defaults
- `cloud.*` - Cloud provider and region (can be overridden)

## Provider-Specific Variables

Each provider has its own configuration:

- **AWS**: `cloudConfig.aws` (minimal, region is in `cloud.region`)
- **Azure**: `cloudConfig.azure.cloudName`, `cloudConfig.azure.baseDomainResourceGroupName`
- **GCP**: `cloudConfig.gcp.projectID`
- **Baremetal**: `cloudConfig.baremetal.*` (to be configured)

## Migration from vars.yml

The `vars.yml` file can still be used for input variables (like `cluster_name`, `cloud_provider`, etc.), but provider-specific defaults and configurations are now organized in `group_vars`.
