# Nginx Static Auto-Builds

Static Windows (x86_64) Builds of nginx stable release.

Windows builds are targetting Windows 7 and newer, provided UCRT is installed.
The minimum supported version is Windows 10 22H2, no guarantees on anything older.

## Auto-Builds

Builds run daily at 12:00 UTC (or GitHubs idea of that time) and are automatically released on success.

**Auto-Builds run ONLY for win64. This is a simplified build system for nginx on Windows x64.**

### Release Retention Policy

- The last build of each month is kept for two years.
- The last 14 daily builds are kept.
- The special "latest" build floats and provides consistent URLs always pointing to the latest build.

## Package List

Nginx is built with minimal dependencies: OpenSSL for SSL/TLS support.

## How to make a build

### Prerequisites

* bash
* docker

### Build Image

* `./makeimage.sh target variant`

### Build Nginx

* `./build.sh target variant`

On success, the resulting zip file will be in the `artifacts` subdir.

### Targets and Variants

Available targets:
* `win64` (x86_64 Windows)

Available variants:
* `gpl` Default build with standard nginx features.
