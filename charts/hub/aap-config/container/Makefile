NAME ?= vp-ocaas-config-container
TAG ?= latest
CONTAINER ?= $(NAME):$(TAG)

DISABLE_LINTERS ?= "-e VALIDATE_SHELL_SHFMT=false"

REGISTRY ?= localhost
UPLOADREGISTRY ?= quay.io/validatedpatterns
TESTCOMMAND := "set -e; echo '* Python: '; python --version ; \
		echo '* Ansible: '; ansible --version ; \
		echo '* kubernetes.core: '; ansible-galaxy collection list | grep kubernetes.core ; \
		echo '* ansible.platform: '; ansible-galaxy collection list | grep ansible.platform ; \
		echo '* community.general: '; ansible-galaxy collection list | grep community.general ;"

##@ Help-related tasks
.PHONY: help
help: ## Help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-35s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Build-related tasks
.PHONY: build
build: manifest podman-build test ## Build the container locally (all arches) and print installed test

.PHONY: amd64
amd64: manifest podman-build-amd64 test-amd64 ## Build and test the container on amd64

.PHONY: manifest
manifest: ## creates the buildah manifest for multi-arch images
	# The rm is needed due to bug https://www.github.com/containers/podman/issues/19757
	buildah manifest rm "${REGISTRY}/${CONTAINER}" || /bin/true
	buildah manifest create "${REGISTRY}/${CONTAINER}"

.PHONY: podman-build
podman-build: podman-build-amd64 ## Build amd64

.PHONY: podman-build-amd64
podman-build-amd64: ## build the container in amd64
	@echo "Building the utility container amd64"
	buildah bud --arch=amd64 --build-arg TARGETARCH=amd64 --build-arg ALTTARGETARCH=x86_64 \
		--build-arg OPTTARGETARCH='' --format docker \
		-f Containerfile -t "${CONTAINER}-amd64"
	buildah manifest add --arch=amd64 "${REGISTRY}/${CONTAINER}" "${REGISTRY}/${CONTAINER}-amd64"

.PHONY: test-amd64
test-amd64: ## Prints the test of most tools inside the container amd64
	@echo "** Testing linux/amd64"
	@podman run --arch=amd64 --rm -it --net=host "${REGISTRY}/${CONTAINER}-amd64" bash -c \
		$(TESTCOMMAND)


.PHONY: test
test: test-amd64 ## Tests the container for all the required bits both amd64

##@ Run and upload tasks
.PHONY: versions
versions: ## Print all the versions of software in the locally-built container
	@podman run --rm -it --net=host \
		--security-opt label=disable \
		-v ${HOME}:/pattern \
		-v ${HOME}:${HOME} \
		-w $$(pwd) "${REGISTRY}/${CONTAINER}-amd64" sh -c \
		"set -e; \
		echo -n \"|python3-pip package \"; rpm -q --queryformat '%{VERSION}' python3-pip; echo \" \"; \
		echo -n \"|git-core package \"; rpm -q --qf '%{VERSION}' git-core; echo \" \"; \
		echo -n \"|python package \";  /usr/bin/python3 --version | sed -e s'/Python //' | tr -d '\n';  echo \" \"; \
		echo -n \"|ansible pip \"; ansible --version -o json | grep core | cut -f3 -d\ | tr -d '\n]';  echo \" \"; \
		echo -n \"|kubernetes pip \"; pip show kubernetes |grep ^Version: | cut -f2 -d\ | tr -d '\n';  echo \" \"; \
		echo -n \"|ansible.platform collection \";  ansible-galaxy collection list ansible.platform |grep ^ansible.platform | cut -f2 -d\  |tr -d '\n';  echo \" \"" | sort | column --table -o '|'

.PHONY: run
run: ## Runs the container interactively
	podman run --rm -it --net=host \
		--security-opt label=disable \
		-v ${HOME}:/pattern \
		-v ${HOME}:${HOME} \
		-w $$(pwd) "${REGISTRY}/${CONTAINER}-amd64" sh

.PHONY: upload
upload: ## Uploads the container to quay.io/hybridcloudpatterns/${CONTAINER}
	@echo "Uploading the ${REGISTRY}/${CONTAINER} container to ${UPLOADREGISTRY}/${CONTAINER}"
	buildah manifest push --all "${REGISTRY}/${CONTAINER}" "docker://${UPLOADREGISTRY}/${CONTAINER}"

.PHONY: clean
clean: ## Removes any previously built artifact
	buildah manifest rm "${REGISTRY}/${CONTAINER}"

.PHONY: super-linter
super-linter: ## Runs super linter locally
	rm -rf .mypy_cache
	podman run -e RUN_LOCAL=true -e USE_FIND_ALGORITHM=true	\
					-e VALIDATE_GITHUB_ACTIONS_ZIZMOR=false \
					-e VALIDATE_MARKDOWN_PRETTIER=false \
		      -e VALIDATE_NATURAL_LANGUAGE=false \
					-e VALIDATE_SHELL_SHFMT=false \
					-e VALIDATE_TRIVY=false \
					-e VALIDATE_YAML_PRETTIER=false \
					-v $(PWD):/tmp/lint:rw,z \
					-w /tmp/lint \
					ghcr.io/super-linter/super-linter:slim-v8
