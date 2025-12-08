# install-idm

An Ansible role for installing and configuring Red Hat Identity Management (IDM) / FreeIPA server.

## Requirements

- Ansible 2.9+
- Collections:
  - `redhat.ipa`
  - `ansible.posix`
- RHEL 9 system
- Root or sudo access
- System must be registered with Red Hat (for IPA server package)

## Role Variables

### Required Variables

None - all variables have defaults, but you'll typically want to override:

- `ipaserver_hostname` - Hostname for the IPA server (defaults to `fqdn_nodot` or `ansible_fqdn`)
- `ipa_zone` - IPA domain/zone (default: "aws.validatedpatterns.io")
- `ipa_pw` - Password for IPA admin and Directory Manager (default: "R3dH4t1!")

### Optional Variables

See `defaults/main.yml` for all available variables.

Key variables:
- `idm_packages` - List of packages to install (default: vim, git, ipa-server, firewalld)
- `idm_firewalld_rules` - List of firewalld port rules to add
- `idm_users` - List of users to create in IDM

## Dependencies

- `freeipa.ansible_freeipa` collection (or `redhat.ipa` if you have Red Hat subscription)
- `ansible.posix` collection

### Installation Options

**Option 1: Install from Galaxy (Recommended for Fedora)**
```bash
# Install from requirements file
ansible-galaxy collection install -r requirements.yml

# Or install individually
ansible-galaxy collection install freeipa.ansible_freeipa ansible.posix
```

**Option 2: Install via Fedora package (Alternative)**
```bash
# On Fedora control node
sudo dnf install ansible-freeipa
```

**Option 3: Use Red Hat Automation Hub (If you have Red Hat subscription)**
```bash
# Configure ansible.cfg to use Automation Hub, then:
ansible-galaxy collection install redhat.ipa ansible.posix
```

**Important:** Collections must be installed on the Ansible control node (where you run `ansible-playbook`), not on the target hosts.

## Example Playbook

```yaml
---
- name: Install IDM on provisioned instances
  hosts: idm_servers
  become: true
  vars:
    ipa_zone: "aws.validatedpatterns.io"
    ipa_pw: "R3dH4t1!"
    ipaserver_hostname: "idm01.aws.validatedpatterns.io"
    
    idm_users:
      - name: jonny
        first: jonny
        last: rickard
      - name: bandini
        first: alejandro
        last: bandini

  roles:
    - install-idm
```

## Example with provision-ec2 role

```yaml
---
- name: Provision EC2 and Install IDM
  hosts: localhost
  gather_facts: false
  collections:
    - amazon.aws
    - community.aws
  vars:
    aws_region: "us-west-1"
    hosted_zone: "aws.validatedpatterns.io."
    
    ec2_instances_idm:
      - name: "idm-server-01"
        instance_name: "idm-server-01"
        fqdn: "idm01.aws.validatedpatterns.io."
        fqdn_nodot: "idm01.aws.validatedpatterns.io"
        groups: ["idm_servers", "ipaservers"]

  roles:
    - provision-ec2

- name: Install IDM on provisioned instances
  hosts: idm_servers
  become: true
  vars:
    ipa_zone: "aws.validatedpatterns.io"
    ipa_pw: "R3dH4t1!"
    
    idm_users:
      - name: jonny
        first: jonny
        last: rickard
      - name: bandini
        first: alejandro
        last: bandini

  roles:
    - install-idm
```

## IDM Configuration Variables

The role uses the following IPA server variables (all configurable):

- `ipaserver_hostname` - Hostname for the IPA server
- `ipaserver_no_host_dns` - Don't use host DNS (default: true)
- `ipaserver_setup_dns` - Setup DNS (default: false)
- `ipaserver_setup_adtrust` - Setup AD trust (default: false)
- `ipaserver_setup_kra` - Setup KRA (default: false)
- `ipaserver_netbios_name` - NetBIOS name (default: "VPLAB")
- `ipaserver_domain` - IPA domain (default: value of `ipa_zone`)
- `ipaserver_realm` - IPA realm (default: uppercase of `ipa_zone`)
- `ipaadmin_password` - IPA admin password
- `ipadm_password` - Directory Manager password

## Firewalld Rules

The role automatically adds the following firewalld rules:
- 22/tcp (SSH)
- 80/tcp (HTTP)
- 443/tcp (HTTPS)
- 464/tcp (Kerberos password change)
- 389/tcp (LDAP)
- 636/tcp (LDAPS)
- 88/tcp (Kerberos)
- 88/udp (Kerberos)

You can customize the rules by overriding `idm_firewalld_rules`.

## License

BSD

## Author Information

Created for omnicloud-as-a-service project

