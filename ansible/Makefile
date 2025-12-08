.PHONY: default
default: help

.PHONY: help
# No need to add a comment here as help is described in common/
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Multicluster Provisioning
.PHONY: install
install: ## multicluster provisioning
	ansible-playbook site.yaml -e "@vars.yml" -e create=true

.PHONY: destroy
destroy: ## Destroys clusters
	ansible-playbook site.yaml -e "@vars.yml" -e destroy=true

.PHONY: debug
debug: ## Render templates locally
	ansible-playbook site.yaml -e "@vars.yml" -e debug_task=true

##@ IDM Infrastructure
.PHONY: idm-create
idm-create: ## Create IDM infrastructure and install IDM (uses idm-vars.yml)
	ansible-playbook create-idm-infra.yml

.PHONY: idm-destroy
idm-destroy: ## Destroy IDM infrastructure (uses idm-vars.yml)
	ansible-playbook destroy-idm-infra.yml

.PHONY: idm-destroy-all
idm-destroy-all: ## Destroy IDM infrastructure including security group and SSH key
	ansible-playbook destroy-idm-infra.yml -e delete_security_group=true -e delete_ssh_key=true
