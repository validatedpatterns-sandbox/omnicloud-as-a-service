#!/bin/bash

# Script to run the site.yaml Ansible playbook
# Supports group_vars structure with provider selection

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default inventory
INVENTORY="${INVENTORY:-inventory.yml}"

# Check if provider is specified via environment variable or argument
PROVIDER="${PROVIDER:-}"
LIMIT_FLAG=""
SHOW_HELP=false

# Parse arguments to check for --limit, --provider, or --help
ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --limit)
            LIMIT_FLAG="--limit"
            PROVIDER="$2"
            shift 2
            ;;
        --provider)
            PROVIDER="$2"
            shift 2
            ;;
        --help|-h)
            SHOW_HELP=true
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

# Function to show required variables
show_required_vars() {
    local provider=$1
    echo ""
    echo "=========================================="
    echo "Required Variables for $provider"
    echo "=========================================="
    echo ""
    echo "Common Variables (all providers):"
    echo "  -e cluster_name=<cluster-name>"
    echo "  -e cluster_base_domain=<base-domain>"
    echo "  -e cloud_provider=<Amazon|Azure|Google|BareMetal>"
    echo "  -e cloud_region=<region>"
    echo "  -e control_plane_replicas=<number>"
    echo "  -e control_plane_machine_type=<machine-type>"
    echo "  -e worker_replicas=<number>"
    echo "  -e worker_machine_type=<machine-type>"
    echo "  -e create_cluster=true  (or destroy_cluster=true)"
    echo ""
    
    case $provider in
        aws)
            echo "AWS-specific Variables:"
            echo "  (No additional variables required)"
            echo ""
            echo "Example AWS machine types:"
            echo "  Control Plane: m5.xlarge, m5.2xlarge"
            echo "  Workers: m5.large, m5.xlarge"
            ;;
        azure)
            echo "Azure-specific Variables:"
            echo "  -e azure_resource_group=<resource-group-name>"
            echo "  -e azure_cloud_name=<AzurePublicCloud|AzureUSGovernmentCloud>  (optional, defaults to AzurePublicCloud)"
            echo ""
            echo "Example Azure machine types:"
            echo "  Control Plane: Standard_D4s_v3, Standard_D8s_v3"
            echo "  Workers: Standard_D4s_v3, Standard_D8s_v3"
            ;;
        gcp)
            echo "GCP-specific Variables:"
            echo "  -e gcp_project_id=<project-id>"
            echo ""
            echo "Example GCP machine types:"
            echo "  Control Plane: n1-standard-4, n1-standard-8"
            echo "  Workers: n1-standard-4, n1-standard-8"
            ;;
        baremetal)
            echo "Baremetal-specific Variables:"
            echo "  (Additional variables may be required - see group_vars/baremetal/main.yml)"
            ;;
        *)
            echo "Provider-specific Variables:"
            echo "  AWS: No additional variables"
            echo "  Azure: -e azure_resource_group=<name>"
            echo "  GCP: -e gcp_project_id=<id>"
            echo "  Baremetal: See group_vars/baremetal/main.yml"
            ;;
    esac
    echo ""
    echo "Example Usage:"
    if [ -n "$provider" ] && [ "$provider" != "all" ]; then
        case $provider in
            aws)
                echo "  ./run-playbook.sh --limit aws -e cluster_name=my-cluster \\"
                echo "    -e cluster_base_domain=example.com -e cloud_provider=Amazon \\"
                echo "    -e cloud_region=us-east-1 -e control_plane_replicas=3 \\"
                echo "    -e control_plane_machine_type=m5.xlarge -e worker_replicas=3 \\"
                echo "    -e worker_machine_type=m5.large -e create_cluster=true"
                ;;
            azure)
                echo "  ./run-playbook.sh --limit azure -e cluster_name=my-cluster \\"
                echo "    -e cluster_base_domain=example.com -e cloud_provider=Azure \\"
                echo "    -e cloud_region=eastus -e control_plane_replicas=3 \\"
                echo "    -e control_plane_machine_type=Standard_D4s_v3 -e worker_replicas=3 \\"
                echo "    -e worker_machine_type=Standard_D4s_v3 -e azure_resource_group=my-rg \\"
                echo "    -e create_cluster=true"
                ;;
            gcp)
                echo "  ./run-playbook.sh --limit gcp -e cluster_name=my-cluster \\"
                echo "    -e cluster_base_domain=example.com -e cloud_provider=Google \\"
                echo "    -e cloud_region=us-central1 -e control_plane_replicas=3 \\"
                echo "    -e control_plane_machine_type=n1-standard-4 -e worker_replicas=3 \\"
                echo "    -e worker_machine_type=n1-standard-4 -e gcp_project_id=my-project \\"
                echo "    -e create_cluster=true"
                ;;
        esac
    else
        echo "  ./run-playbook.sh --limit <provider> -e cluster_name=<name> \\"
        echo "    -e cluster_base_domain=<domain> -e cloud_provider=<provider> \\"
        echo "    -e cloud_region=<region> -e create_cluster=true"
        echo ""
        echo "  Or use vars.yml:"
        echo "  ./run-playbook.sh --limit <provider> -e @vars.yml -e create_cluster=true"
    fi
    echo ""
    echo "=========================================="
    echo ""
}

# Show help if requested
if [ "$SHOW_HELP" = true ]; then
    show_required_vars "${PROVIDER:-all}"
    exit 0
fi

# Check if required variables are missing (basic check)
# We'll show a warning if key variables aren't found in args
HAS_VARS=false
for arg in "${ARGS[@]}"; do
    if [[ "$arg" == *"-e"* ]] || [[ "$arg" == *"vars.yml"* ]] || [[ "$arg" == *"@vars.yml"* ]]; then
        HAS_VARS=true
        break
    fi
done

# Show required variables if no vars file or -e flags detected
if [ "$HAS_VARS" = false ] && [ ${#ARGS[@]} -eq 0 ]; then
    echo "⚠️  Warning: No variables specified!"
    show_required_vars "${PROVIDER:-all}"
    echo "Run with --help to see this information again."
    echo ""
fi

# Build command
CMD="ansible-playbook site.yaml -i $INVENTORY"

# Add limit if provider is specified
if [ -n "$PROVIDER" ]; then
    CMD="$CMD --limit $PROVIDER"
fi

# Add remaining arguments
CMD="$CMD ${ARGS[@]}"

# Run the playbook
eval $CMD
