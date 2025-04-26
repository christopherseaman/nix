# Optimized Code-Server Dockerfiles

This directory contains multiple Dockerfile options for creating a code-server environment with development tools on ARM64 architecture. Each option offers different trade-offs between convenience, image size, and flexibility.

## Available Options

1. **Original Dockerfile** (`dockerfile`)
   - Uses Nix package manager to install tools
   - Comprehensive but results in a large image size (3-4GB)

2. **Optimized Dockerfile** (`dockerfile-optimized`)
   - Uses standard installation methods (apt, pip, direct downloads)
   - Significantly smaller image size (1.5-1.7GB)
   - Includes all tools from the original

3. **Advanced Optimized Dockerfile** (`dockerfile-advanced-optimized`)
   - Uses multi-stage builds for even smaller image size
   - Implements on-demand installation for less frequently used tools
   - Estimated image size: 1.2-1.5GB

## Building and Running

### Building the Image

```bash
# Choose one of the Dockerfiles
docker build -t code-server:optimized -f dockerfile-optimized .
# OR
docker build -t code-server:advanced -f dockerfile-advanced-optimized .
```

### Running the Container

```bash
docker run -d \
  --name=code-server \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e PASSWORD=password \
  -e SUDO_PASSWORD=password \
  -p 8443:8443 \
  -v /path/to/config:/config \
  --restart unless-stopped \
  code-server:optimized
```

## Key Features

All Dockerfiles include:

- Python 3 with key development packages
- Go programming language (ARM64 build)
- Git with enhanced configuration (delta for diffs)
- Shell tools (fish, tmux, starship)
- Development tools (neovim, ripgrep, bat - all ARM64 builds)

## Differences Between Versions

### Original vs. Optimized

The optimized version eliminates Nix entirely, which significantly reduces the image size. It installs all the same tools using standard methods like apt, pip, and direct binary downloads.

### Optimized vs. Advanced Optimized

The advanced optimized version:
1. Uses multi-stage builds to reduce layer size
2. Moves less frequently used tools to an on-demand installation script
3. Uses `--no-install-recommends` with apt to reduce unnecessary dependencies
4. Provides a welcome message with instructions for optional tools

## On-Demand Tool Installation

The advanced optimized version includes a script to install optional tools when needed:

```bash
/config/scripts/install-optional-tools.sh
```

This allows you to keep the base image small while still having access to additional tools when required.

## Customization

You can easily customize any of these Dockerfiles:

- To add more packages, add them to the appropriate installation commands
- To remove packages, delete the corresponding installation lines
- To change versions, update the version numbers in the download URLs
- To use on x86_64 architecture, replace "arm64" with "amd64" in binary URLs and filenames

## Size Comparison

| Dockerfile | Approximate Size |
|------------|------------------|
| Original   | 3-4GB            |
| Optimized  | 1.5-1.7GB        |
| Advanced   | 1.2-1.5GB        |

For a detailed comparison, see `dockerfile-comparison.md`.