# Console Banner Chart

This chart creates an OpenShift ConsoleNotification banner to identify which cluster is being used.

## Quick Start (Script Method)

For a quick way to create the banner with automatic color selection:

```bash
# On the cluster where you want the banner
./charts/all/infrastructure/console-banner/create-banner.sh gcp0
```

This will:

- Create a banner showing "Cluster: gcp0"
- Automatically select a color based on the cluster name
- Each cluster gets a different color (deterministic - same cluster = same color)

## Usage

The cluster name is automatically derived from `global.localClusterName` + `clusterPlatform` (e.g., "gcp0" + "gcp" = "gcp0gcp"). You don't need to set `clusterName` manually.

### Basic Usage (Automatic Color Selection)

```yaml
consoleBanner:
  enabled: true
```

This will:

- Create a banner showing: "Cluster: {localClusterName}{clusterPlatform}" (e.g., "Cluster: gcp0gcp")
- Automatically select a color based on the combined cluster name (deterministic - same cluster always gets same color)
- Each cluster in the same clusterGroup will get a different color

### Manual Color Selection

```yaml
consoleBanner:
  enabled: true
  backgroundColor: "#CC0000"  # Override automatic selection
```

### Custom Text

```yaml
consoleBanner:
  enabled: true
  text: "⚠️ Development Cluster - Do not use for production workloads"
```

### Custom Colors

```yaml
consoleBanner:
  enabled: true
  text: "Production Cluster"
  backgroundColor: "#CC0000"  # Red for production
  color: "#FFFFFF"  # White text
```

### With Link

```yaml
consoleBanner:
  enabled: true
  link:
    href: "https://docs.example.com/clusters/gcp0"
    text: "View Documentation"
```

## Values

| Parameter | Description | Default |
| --- | --- | --- |
| `consoleBanner.enabled` | Enable the console banner | `true` |
| `consoleBanner.name` | Name of the ConsoleNotification resource | `cluster-banner` |
| `global.localClusterName` | Local cluster name (used for banner) | Set in global values |
| `clusterPlatform` | Cluster platform (used for banner) | Set in cluster values |
| `consoleBanner.text` | Custom banner text (overrides default) | `"Cluster: {localClusterName}{clusterPlatform}"` |
| `consoleBanner.location` | Banner location | `BannerTop` |
| `consoleBanner.color` | Text color (hex) | `#FFFFFF` |
| `consoleBanner.backgroundColor` | Background color (hex) | Auto-selected based on combined cluster name if empty |
| `consoleBanner.link.href` | Optional link URL | `""` |
| `consoleBanner.link.text` | Optional link text | `""` |

## Banner Locations

- `BannerTop` - Top of console
- `BannerBottom` - Bottom of console  
- `BannerTopBottom` - Both top and bottom

## Examples

### Automatic Color (Recommended for Multiple Clusters)

Each cluster gets a unique color automatically based on `global.localClusterName` + `clusterPlatform`:

```yaml
# Cluster 1 (gcp0 + gcp) - will get one color
consoleBanner:
  enabled: true

# Cluster 2 (aws0 + aws) - will get a different color
consoleBanner:
  enabled: true

# Cluster 3 (azure0 + azure) - will get yet another color
consoleBanner:
  enabled: true
```

### Custom Text with Auto Color

```yaml
consoleBanner:
  enabled: true
  text: "🔧 Development Cluster"
  # backgroundColor will be auto-selected based on global.localClusterName + clusterPlatform
```

### Manual Color Override

```yaml
consoleBanner:
  enabled: true
  text: "⚠️ PRODUCTION - Handle with Care"
  backgroundColor: "#CC0000"  # Red - overrides auto-selection
```

## How Random Color Selection Works

The chart uses a deterministic hash-based approach:

1. Combines `global.localClusterName` + `clusterPlatform` to form the cluster identifier
2. Creates a hash from the combined name
3. Uses the hash to select from a palette of 10 colors
4. Same cluster identifier always gets the same color
5. Different clusters get different colors (with high probability)

This ensures:

- **Consistency**: Same cluster always has the same color
- **Uniqueness**: Different clusters get different colors
- **No configuration needed**: Uses global values automatically
