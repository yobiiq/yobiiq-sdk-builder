# YOBIIQ KiBi SDK Builder

Docker images providing the build environment of the YOBIIQ KiBi SDK. There is one image per nRF Connect SDK (NCS) version, and the CI workflows of the SDK run in it.

## Overview

Each image holds:

- **NCS toolchain** - The toolchain bundle of one NCS version, installed with nrfutil toolchain-manager: Zephyr SDK, West, CMake, Ninja, Python and their dependencies
- **nrfutil** and the **nRF Command Line Tools**
- **Build tools** - GCC, ccache, lcov, Device Tree Compiler and Git

The image does not hold the NCS sources. They come from the west manifest of the SDK, with `west update`.

## Release Cycle

The images follow the NCS releases, in step with the SDK releases. The image comes first, because the SDK workflows cannot run on an NCS version until its image exists:

1. NCS publishes a version
2. This repository publishes the image of that version
3. The SDK moves its `west.yml` and workflows to that version and image
4. The SDK releases on that version

| Image | NCS | SDK release | Status |
|-------|-----|-------------|--------|
| `v3.2.1` | v3.2.1 | v1.0.0 | Published |
| `v3.2.6` | v3.2.6 | v1.0.6 | Published |
| `v3.5.x` | v3.5.x | v3.5.x | Planned |

From NCS 3.5.x on, the SDK version is the same as the NCS version, so the image, NCS and SDK versions all match.

### Publishing a New Image

Change `NRF_CONNECT_SDK_VERSION` in `VERSION.txt` and merge it to `main`. It is the only place to change: the workflows take the toolchain version and the image tags from it. The workflow builds the image, verifies it holds the toolchain of that version, and only then publishes it.

Then point the SDK workflows at the new exact tag.

### Previews, Release Candidates and Older Versions

To build a version other than the one in `VERSION.txt`, run the workflow by hand and leave `VERSION.txt` unchanged:

1. Go to Actions, then "Build and Push Docker Image", then "Run workflow"
2. Set the version, for example `v3.5.0-preview4` or `v3.5.0-rc1`

These builds publish their exact tag only.

## Available Tags

| Tag | Description | Use Case |
|-----|-------------|----------|
| `v3.2.6` | Exact NCS version. Stays unchanged once published | CI and production builds, always pin this one |
| `v3.5.0-preview4` | Exact NCS preview or release candidate | Trying the next NCS version |
| `v3.2.6-2026-12` | Monthly rebuild of a version, with current base packages | Security updates for a specific version |
| `v3.2` | Latest published version of that NCS minor | Development only, it moves |
| `latest` | Latest published version | Development only, it moves |
| `sha-abc123` | Git commit of this repository | Tracing an image to its sources |

## Updating the Image

- **New version** - A push to `main` that changes `VERSION.txt` publishes the new version
- **Monthly** - On the 1st of each month, the version in `VERSION.txt` is rebuilt under a dated tag only, so the exact tag does not change. GitHub turns scheduled workflows off after 60 days without repository activity. Turn it back on with `gh workflow enable "Monthly Scheduled Build"`
- **Replacing a published image** - A version that is already published is skipped, so editing the Dockerfile or a workflow leaves it alone. To replace it on purpose, for example after a Dockerfile fix, run "Build and Push Docker Image" by hand with `rebuild` enabled, knowing the SDK CI pinned to that tag changes with it

## Quick Start

### Pull the Pre-built Image

```bash
docker pull ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.6
```

### Run the Container

```bash
docker run -it --rm ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.6
```

### Build Your Project

```bash
# Inside the container, the environment is automatically loaded
cd /workspace
git clone https://github.com/yobiiq/yobiiq-sdk.git
west init -l yobiiq-sdk
west update
cd yobiiq-sdk
west build -b lpwm10lrw/nrf54l15/cpuapp samples/iq_lrw/generic
```

Add your ECDSA P-256 signing key as `samples/iq_lrw/generic/keys/signing_key.pem` first: the SDK ships no signing keys. Use the image of the NCS version in the `west.yml` of the SDK.

> **Note**: An interactive shell loads the environment by itself. A non-interactive shell, such as a CI step, has to run `source /opt/ncs_env.sh` first.

## Using in CI/CD

### GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.6
    steps:
      - uses: actions/checkout@v4
      - name: Build SDK
        shell: bash
        run: |
          source /opt/ncs_env.sh
          west --version
```

## Local Development

### Using Docker Compose

Create `docker-compose.yml`:

```yaml
services:
  builder:
    image: ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.6
    volumes:
      - ./:/workspace
    working_dir: /workspace
    command: /bin/bash
```

Run:
```bash
docker compose run --rm builder
```

### VS Code Dev Container

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "YOBIIQ SDK Development",
  "image": "ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.6",
  "workspaceFolder": "/workspace",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind"
}
```

## Building Locally

### Prerequisites

- Docker installed and running
- At least 20 GB of free disk space
- Good internet connection

### Build Command

```bash
# The version in VERSION.txt
./scripts/build-local.sh

# Another version
./scripts/build-local.sh v3.2.1
```

The script builds the image with `--build-arg NCS_VERSION=<version>`, which the Dockerfile requires, and verifies it. It does not publish anything: the workflows do.

## Verification

```bash
# Against the version in VERSION.txt
./scripts/verify-image.sh ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.6

# Against another version
./scripts/verify-image.sh ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.1 v3.2.1
```

This checks that the required tools run, that the environment variables are set, and that the installed toolchain is the one of the expected NCS version. The workflows run the same script before publishing.

## What's Inside

| Path | Content |
|------|---------|
| `/opt/ncs/toolchains/<bundle>/` | Toolchain bundle, with the Zephyr SDK in `opt/zephyr-sdk` |
| `/opt/ncs/toolchains/toolchains.json` | NCS version of the installed toolchain |
| `/opt/ncs_env.sh` | Script that loads the toolchain environment |
| `/workspace` | Working directory |

Environment variables set by `/opt/ncs_env.sh` include `ZEPHYR_SDK_INSTALL_DIR` and `ZEPHYR_TOOLCHAIN_VARIANT`. `NCS_INSTALL_DIR` is `/opt/ncs`.

The container runs as `root`.

## Troubleshooting

### Image is too large

The image is about 7.5 GB because of the full toolchain. This is normal for embedded development environments.

### Build fails with "No space left on device"

Ensure you have at least 20 GB free disk space. Clean up Docker:
```bash
docker system prune -a
```

### `nrfutil toolchain-manager` is not found

The command is not available once the toolchain environment is loaded, because the environment puts the nrfutil of the bundle first on `PATH`. To read the installed version, use `/opt/ncs/toolchains/toolchains.json`.

## Version History

| Version | NCS | Zephyr SDK | Release Date |
|---------|-----|------------|--------------|
| v3.2.1  | v3.2.1 | 0.17.0 | 2026-01-22 |
| v3.2.6  | v3.2.6 | 0.17.0 | 2026-11-02 |

See [CHANGELOG.md](CHANGELOG.md) for the changes.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [YOBIIQ KiBi SDK](https://github.com/yobiiq/yobiiq-sdk) - The SDK that uses this builder
- [nRF Connect SDK](https://github.com/nrfconnect/sdk-nrf) - Nordic's SDK
- [Zephyr Project](https://github.com/zephyrproject-rtos/zephyr) - Zephyr RTOS

## Support

For issues related to:
- **Docker image** - Open an issue in this repository
- **YOBIIQ SDK** - See the [SDK repository](https://github.com/yobiiq/yobiiq-sdk)
- **nRF Connect SDK** - See [Nordic's documentation](https://docs.nordicsemi.com/)
