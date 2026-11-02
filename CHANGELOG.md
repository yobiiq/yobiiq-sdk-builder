# Changelog

All notable changes to the YOBIIQ SDK Builder will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- The toolchain version and the image tags both come from `NRF_CONNECT_SDK_VERSION` in `VERSION.txt`
- The manual build takes the version to build, so previews, release candidates and older versions can be built
- Images are verified before they are published, including the version of the installed toolchain
- `verify-image.sh` checks what the image holds and is the check used by the workflows
- A published exact version tag is not replaced, unless the manual build asks for it with `rebuild`
- The monthly build publishes only its dated tag

### Removed
- `ZEPHYR_SDK_VERSION` and `IMAGE_BUILD_DATE` from `VERSION.txt`: nothing read them, and the Zephyr SDK version comes with the toolchain bundle

## [v3.2.1] - 2026-01-22

### Added
- Initial release of YOBIIQ SDK Builder
- nRF Connect SDK v3.2.1 support
- Zephyr SDK 0.16.5 with ARM toolchain
- Ubuntu 22.04 LTS base image
- Automated monthly rebuild workflow
- GitHub Actions CI/CD pipeline
- Image verification scripts
- Local build helper scripts
- Comprehensive documentation
- Multi-tag support (version, major.minor, latest, sha)
- Non-root user (builder) for enhanced security
- GitHub Container Registry publishing

### Included Tools
- West meta-tool
- CMake 3.x
- Ninja build system
- Python 3 with required packages
- ARM GCC cross-compiler
- Git
- Device Tree Compiler
- Build essentials

### Infrastructure
- GitHub Actions workflows for build and push
- Scheduled monthly builds (1st of each month)
- Docker layer caching for faster builds
- Automated verification tests

[v3.2.1]: https://github.com/yobiiq/yobiiq-sdk-builder/releases/tag/v3.2.1
