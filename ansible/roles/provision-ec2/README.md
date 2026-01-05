# provision-ec2

An Ansible role for provisioning EC2 instances with public IPs. This role is idempotent and supports provisioning multiple instances across different machine types (IDM, AAP, Satellite, etc.).

## Requirements

- Ansible 2.9+
- Collections:
  - `amazon.aws`
  - `community.aws`
- Python boto3 library
- AWS credentials configured

## Role Variables

### Required Variables

None - all variables have defaults, but you'll typically want to override:

- `ec2_instances_idm` - List of IDM instances to provision
- `ec2_instances_aap` - List of AAP instances to provision  
- `ec2_instances_satellite` - List of Satellite instances to provision

### Optional Variables

See `defaults/main.yml` for all available variables.

Key optional variables:

- `hosted_zone` - Route53 hosted zone name (e.g., "example.com.") for DNS record creation
- `create_dns_records` - Set to `false` to skip DNS record creation (default: `true`)

## Instance Configuration

Each instance in the lists should be a dictionary with the following keys:

```yaml
ec2_instances_idm:
  - name: "idm-server-01"
    instance_name: "idm-server-01"  # Optional, defaults to 'name'
    instance_type: "t3.medium"      # Optional, uses default
    instance_ebs_size: 20           # Optional, uses default
    key_name: "my-key"              # Optional, uses default
    ec2_tags: "omnicloud"           # Optional, uses default
    ec2_role: "idm"                 # Optional, uses default
    fqdn: "idm01.example.com."     # Optional, for DNS (fully qualified)
    fqdn_nodot: "idm01.example.com" # Optional, for inventory (without trailing dot)
    hosted_zone: "example.com."     # Optional, per-instance hosted zone override
    dns_ttl: 60                     # Optional, DNS TTL (default: 60)
    groups: ["idm_servers"]         # Optional, inventory groups
    ansible_user: "ec2-user"        # Optional, defaults to ec2-user
    wait_for_ssh_timeout: 600       # Optional, uses default
```

## Dependencies

None

## Example Playbook

```yaml
---
- name: Provision EC2 Instances
  hosts: localhost
  gather_facts: false
  collections:
    - amazon.aws
    - community.aws
  vars:
    aws_region: "us-east-1"
    key_name: "my-ssh-key"
    ssh_public_key_path: "~/.ssh/id_rsa.pub"
    hosted_zone: "example.com."  # Route53 hosted zone for DNS records
    create_dns_records: true     # Enable DNS record creation
    
    ec2_instances_idm:
      - name: "idm-server-01"
        instance_name: "idm-server-01"
        instance_type: "t3.large"
        ec2_role: "idm"
        fqdn_nodot: "idm01.example.com"
        groups: ["idm_servers"]
    
    ec2_instances_aap:
      - name: "aap-controller-01"
        instance_name: "aap-controller-01"
        instance_type: "t3.xlarge"
        ec2_role: "aap"
        fqdn_nodot: "aap01.example.com"
        groups: ["aap_servers"]
    
    ec2_instances_satellite:
      - name: "satellite-server-01"
        instance_name: "satellite-server-01"
        instance_type: "t3.xlarge"
        ec2_role: "satellite"
        fqdn_nodot: "sat01.example.com"
        groups: ["satellite_servers"]

  roles:
    - provision-ec2
```

## Example with group_vars

Create `group_vars/all.yml` or `group_vars/ec2_instances.yml`:

```yaml
ec2_instances_idm:
  - name: "idm-server-01"
    instance_name: "idm-server-01"
    instance_type: "t3.large"
    ec2_role: "idm"
    groups: ["idm_servers"]

ec2_instances_aap:
  - name: "aap-controller-01"
    instance_name: "aap-controller-01"
    instance_type: "t3.xlarge"
    ec2_role: "aap"
    groups: ["aap_servers"]
```

## Route53 DNS Records

The role can automatically create/update Route53 A records for provisioned instances. To enable DNS record creation:

1. Set `hosted_zone` to your Route53 hosted zone name (e.g., "example.com.")
2. Set `create_dns_records: true` (default)
3. Provide `fqdn` or `fqdn_nodot` for each instance that needs a DNS record

The DNS records will be created/updated with the instance's public IP address. The task is idempotent and will update existing records if the IP changes.

Example:

```yaml
hosted_zone: "example.com."
ec2_instances_idm:
  - name: "idm-server-01"
    fqdn: "idm01.example.com."  # Fully qualified domain name
    # OR
    fqdn_nodot: "idm01.example.com"  # Without trailing dot
```

## Destroy/Delete Functionality

The role supports destroying all provisioned resources. To delete all instances and associated resources:

```yaml
---
- name: Destroy EC2 Instances
  hosts: localhost
  gather_facts: false
  collections:
    - amazon.aws
    - community.aws
  vars:
    aws_region: "us-east-1"
    destroy: true
    delete_security_group: false  # Set to true to also delete security group
    delete_ssh_key: false         # Set to true to also delete SSH key
    
    # Provide the same instance lists used for provisioning
    ec2_instances_idm:
      - name: "idm-server-01"
        instance_name: "idm-server-01"
        fqdn: "idm01.example.com."  # Required if DNS records were created
    
    ec2_instances_aap:
      - name: "aap-controller-01"
        instance_name: "aap-controller-01"
        fqdn: "aap01.example.com."

  roles:
    - provision-ec2
```

The destroy operation will:

- Find all instances matching the provided instance names
- Delete Route53 DNS records (if `fqdn` or `fqdn_nodot` is provided)
- Terminate EC2 instances
- Optionally delete security group (if `delete_security_group: true`)
- Optionally delete SSH key (if `delete_ssh_key: true`)

**Note:** The same instance configuration used for provisioning should be provided when destroying, especially the `fqdn`/`fqdn_nodot` values if DNS records need to be deleted.

## Idempotency

This role is idempotent. It will:

- Check for existing instances by name before creating
- Skip instance creation if an instance with the same name already exists
- Still add existing instances to the inventory
- Only create new instances that don't exist
- Update Route53 DNS records if they already exist (using `overwrite: true`)
- Safely handle destroy operations when instances don't exist

## License

BSD

## Author Information

Created for omnicloud-as-a-service project
