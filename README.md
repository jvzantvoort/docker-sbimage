# docker-sbimage

A containerized Sphinx documentation builder optimized for Python 3.13, featuring comprehensive Sphinx extensions, themes, and build automation tools.

## Features

- **Python 3.13**: Built on `python:3.13-slim` for modern Python features and security
- **Sphinx 9.1.0**: Latest stable Sphinx documentation generator
- **Comprehensive Extensions**: 20+ Sphinx extensions including:
  - Multiple themes (bootstrap, celery, readable, typlog, and more)
  - Git integration (sphinx-git, sphinx-last-updated-by-git)
  - Enhanced features (copybutton, tabs, sitemap)
  - Markdown support via myst-parser
- **Additional Tools**:
  - Ansible 12.2.0 for automation
  - Django 5.2.9 for web projects
  - Image processing (Pillow, sigal)
  - Code quality tools (pylint, isort)
- **Build Optimization**: Docker BuildKit cache mounts for faster rebuilds
- **Health Checks**: Built-in container health monitoring

## Quick Start

### Using Pre-built Image

```bash
# Pull from GitHub Container Registry
docker pull ghcr.io/jvzantvoort/sbimage:latest

# Run interactively
docker run -it --rm \
  -v $(pwd):/code \
  -v $(pwd)/output:/webroot \
  ghcr.io/jvzantvoort/sbimage:latest
```

### Building Locally

```bash
# Using Docker
docker build -t sbimage .

# Using Buildah
buildah build -t sbimage .

# Using Podman
podman build -t sbimage .
```

## Usage

### Interactive Shell

```bash
docker run -it --rm \
  -v /path/to/docs:/code \
  -v /path/to/output:/webroot \
  sbimage:latest
```

### Build Documentation

```bash
# Inside container
sphinx-build -b html -d /tmp/doctrees sphinxdoc /webroot
```

### Using Helper Scripts

The `bin/` directory contains helper scripts for common tasks:

- **sbbuild**: Build container images with version management
- **sblist**: List available container images
- **sbupdate**: Update container dependencies
- **sbname**: Get container name
- **sbversion**: Get container version

Example:
```bash
./bin/sbbuild Dockerfile myimage v1.0.0
```

## Volumes

- `/code`: Source code directory (typically your documentation source)
- `/webroot`: Output directory for built documentation
- `/output`: Alternative output directory

## Environment

- **WORKDIR**: `/code`
- **Default CMD**: `/bin/bash`
- **Base Image**: `python:3.13-slim` (Debian Trixie)

## GitHub Actions

Automated builds are configured in `.github/workflows/build.yml` with:

- Multi-platform support (amd64, arm64)
- GitHub Container Registry publishing
- Smart tagging (semver, branch, SHA, latest)
- Build caching for faster CI/CD
- Pull request validation (build-only)

Images are published to: `ghcr.io/jvzantvoort/sbimage`

## Development

### Requirements

The image includes 170+ Python packages optimized for Python 3.13:

- Removed built-in packages (`typing`, `importlib_metadata`, etc.)
- Modern alternatives (`myst-parser` instead of deprecated `recommonmark`)
- No duplicate/superseded packages
- Latest security updates

See [requirements.txt](requirements.txt) for the complete list.

### System Dependencies

- libldap2-dev
- libsasl2-dev
- rsync
- git

## Health Check

The container includes a health check that verifies Sphinx is functioning:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python3 -c "import sphinx; print('OK')" || exit 1
```

## License

See [LICENSE](LICENSE) file for details.

## Maintainer

John van Zantvoort <john@vanzantvoort.org>

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build: `buildah build .`
5. Submit a pull request

## Version History

- **Latest**: Python 3.13-slim, Sphinx 9.1.0, optimized dependencies
- See [releases](../../releases) for full version history

## Notes

- This image is designed for building Sphinx documentation sites
- The `entrypoint.sh` script provides automated build workflows
- Compatible with Docker, Podman, and Buildah
- Multi-architecture support via GitHub Actions
