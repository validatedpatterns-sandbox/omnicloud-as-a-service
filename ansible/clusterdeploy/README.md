Role Name
=========

clusterdeploy - Ansible role for deploying OpenShift clusters using ACM (Advanced Cluster Management) and Hive.

Requirements
------------

- Kubernetes cluster with ACM and Hive installed
- Provider credentials secrets (aws-creds, gcp-creds, or azure-creds) in the `hive` namespace
- global-pullsecret in the `hive` namespace
- Ansible collections: kubernetes.core

Role Variables
--------------

Key variables:

- `cluster.name`: Name of the cluster to deploy
- `cluster.namespace`: Namespace where ClusterDeployment will be created (defaults to 'hive')
- `cloud.provider`: Cloud provider ('Amazon', 'Google', or 'Azure')
- `cloud.region`: Cloud region
- `user_provided_credentials`: Set to true to create cluster-specific credentials (default: false)

Provider Secrets Workflow
--------------------------

The role supports two workflows for managing provider credentials:

1. Shared Provider Secrets (Recommended - ACM Console Style)

Keep provider secrets (`aws-creds`, `gcp-creds`, `azure-creds`, `global-pullsecret`) in the `hive` namespace and reuse them across multiple clusters in different namespaces.

**How it works:**

- Provider secrets are stored once in the `hive` namespace
- When creating a cluster in a different namespace (e.g., `democluster`), the role automatically copies the secrets from `hive` to the target namespace
- This allows multiple clusters to share the same provider credentials

**Example:**

```yaml
- hosts: localhost
  vars:
    cluster_name: my-cluster
    cluster_base_domain: example.com
    cloud_provider: Amazon
    cloud_region: us-east-1
  vars_files:
    - vars.yml
  roles:
    - role: clusterdeploy
      vars:
        cluster:
          namespace: democluster  # Different namespace
        user_provided_credentials: false  # Use shared secrets
```

**Prerequisites:**

- Secrets must exist in the `hive` namespace:
  - `aws-creds` (for AWS)
  - `gcp-creds` (for GCP)
  - `azure-creds` (for Azure)
  - `global-pullsecret` (for all providers)

1. Cluster-Specific Credentials

Create cluster-specific credentials in the target namespace.

**Example:**

```yaml
- hosts: localhost
  vars:
    cluster_name: my-cluster
    cluster_base_domain: example.com
    cloud_provider: Amazon
    cloud_region: us-east-1
  vars_files:
    - vars.yml
  roles:
    - role: clusterdeploy
      vars:
        user_provided_credentials: true  # Create cluster-specific secrets
```

**Note:** When `user_provided_credentials: true`, credential files must exist:

- `~/.pullsecret.json`
- `~/.gcp/osServiceAccount.json` (for GCP)
- `~/.azure/osServicePrincipal.json` (for Azure)
- AWS credentials template (for AWS)

Dependencies
------------

None

Example Playbook
----------------

Create a cluster using shared provider secrets:

```yaml
- hosts: localhost
  gather_facts: false
  vars:
    cluster_name: my-cluster
    cluster_base_domain: example.com
    cloud_provider: Amazon
    cloud_region: us-east-1
  vars_files:
    - vars.yml
  roles:
    - role: clusterdeploy
      vars:
        cluster:
          namespace: democluster
        create: true
```

Destroy a cluster:

```yaml
- hosts: localhost
  gather_facts: false
  vars:
    cluster_name: my-cluster
  roles:
    - role: clusterdeploy
      vars:
        destroy: true
```

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a site (HTML is not allowed).
