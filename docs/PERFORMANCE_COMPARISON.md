# FFmpeg Performance Comparison Guide

This guide explains how to use the performance comparison tools included in this repository to evaluate different FFmpeg variants and choose the optimal configuration for your specific use case.

## Overview

The FFmpeg-Builds repository provides multiple performance comparison tools:

1. **`benchmark.sh`** - Quick benchmarking tool for basic comparisons
2. **`performance_comparison.sh`** - Comprehensive performance analysis tool
3. **`performance_test.sh`** - Advanced testing with custom parameters

## Quick Start

### Basic Performance Comparison

```bash
# Test default configurations (linux64 with main variants)
./performance_comparison.sh

# Test with dry run (simulation mode)
DRY_RUN=true ./performance_comparison.sh

# Quick test mode (faster execution)
QUICK_TEST=true ./performance_comparison.sh
```

### Custom Target/Variant Testing

```bash
# Test specific targets and variants
TARGETS="linux64 linuxarm64" VARIANTS="gpl lgpl" ./performance_comparison.sh

# Test all available variants
VARIANTS="gpl lgpl gpl-shared lgpl-shared nonfree nonfree-shared" ./performance_comparison.sh

# Test with custom output directory
OUTPUT_DIR="./my_performance_results" ./performance_comparison.sh
```

## Available Targets

| Target | Platform | Architecture | Notes |
|--------|----------|--------------|-------|
| `win64` | Windows | x86_64 | Windows 10+ recommended |
| `winarm64` | Windows | ARM64 | Windows on ARM |
| `linux64` | Linux | x86_64 | glibc>=2.28, linux>=4.18 |
| `linuxarm64` | Linux | ARM64 | glibc>=2.28, linux>=4.18 |

## Available Variants

| Variant | License | Features | Use Case |
|---------|---------|----------|----------|
| `gpl` | GPL | Full codec set (x264, x265) | High performance |
| `lgpl` | LGPL | Limited codecs | Distribution |
| `gpl-shared` | GPL | Full codecs + shared libs | Balanced |
| `lgpl-shared` | LGPL | Limited codecs + shared libs | Minimal size |
| `nonfree` | GPL+Nonfree | Includes fdk-aac | Professional |
| `nonfree-shared` | GPL+Nonfree | Nonfree + shared libs | Professional minimal |

## Performance Metrics

The tools measure and compare:

### Encoding Performance
- **H.264 encoding time** - Most common video codec
- **H.265/HEVC encoding time** - High-efficiency codec
- **Audio encoding time** - Various audio formats (AAC, MP3, Opus)

### Resource Usage
- **CPU utilization** - Peak CPU usage during encoding
- **Memory consumption** - Peak memory usage
- **Output file size** - Compression efficiency

### Build Characteristics
- **Binary size** - Disk space requirements
- **Shared library dependencies** - Runtime requirements
- **Feature availability** - Codec and filter support

## Interpreting Results

### Performance Rankings

Typical performance ranking (fastest to slowest):
1. **GPL (static)** - Best performance, full features
2. **GPL-shared** - Very good performance, smaller size
3. **LGPL (static)** - Good performance, limited features
4. **LGPL-shared** - Good performance, smallest size

### Use Case Recommendations

#### 🎬 Video Production
- **Recommended:** `gpl` or `nonfree`
- **Why:** Best encoding performance and quality
- **Codecs:** x264, x265, fdk-aac

#### 🏢 Enterprise Deployment
- **Recommended:** `lgpl-shared`
- **Why:** Compatible licensing, smaller footprint
- **Codecs:** Built-in codecs, libvpx, aom

#### 🚀 High-Volume Processing
- **Recommended:** `gpl` (static)
- **Why:** Maximum performance, no dependencies
- **Codecs:** All available optimized codecs

#### 📱 Mobile/Embedded
- **Recommended:** `lgpl-shared`
- **Why:** Minimal size, shared libraries
- **Codecs:** Essential codecs only

## Example Results

### Sample Performance Comparison

```
| Configuration    | H.264 (s) | H.265 (s) | Memory (MB) | Features  |
|------------------|-----------|-----------|-------------|-----------|
| linux64-gpl     | 8.5       | 15.8      | 350         | x264,x265 |
| linux64-lgpl    | 9.8       | 18.2      | 320         | basic     |
| linux64-gpl-shared | 9.1    | 16.4      | 280         | x264,x265 |
| linux64-lgpl-shared | 10.2   | 19.1      | 250         | basic     |
```

### Analysis
- **GPL variants** show ~15% better encoding performance
- **Shared variants** use ~20% less memory
- **LGPL variants** have licensing advantages but performance trade-offs

## Advanced Usage

### Custom Test Files

```bash
# Use custom input file
./performance_test.sh -i /path/to/your/video.mp4

# Multiple test files
./performance_test.sh -i /path/to/video1.mp4,/path/to/video2.mp4
```

### Specific Codec Testing

```bash
# Test specific codecs/formats
./performance_test.sh --codecs h264,h265,vp9,av1
./performance_test.sh --formats mp4,mkv,webm
```

### Automated Testing

```bash
#!/bin/bash
# Automated nightly performance testing

for target in linux64 linuxarm64; do
    for variant in gpl lgpl; do
        TARGETS="$target" VARIANTS="$variant" \
        OUTPUT_DIR="./nightly_results_$(date +%Y%m%d)" \
        ./performance_comparison.sh
    done
done
```

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Check if variant exists
ls variants/ | grep linux64

# Verify Docker is running
docker info

# Use dry run to test script
DRY_RUN=true ./performance_comparison.sh
```

#### Performance Issues
```bash
# Use quick test mode
QUICK_TEST=true ./performance_comparison.sh

# Test single configuration
TARGETS="linux64" VARIANTS="gpl" ./performance_comparison.sh
```

### Dependencies

Required tools:
- `bash` - Shell execution
- `docker` - For building FFmpeg variants (unless DRY_RUN=true)
- `bc` - Mathematical calculations (optional)
- `time` - Performance measurement

## Report Formats

The tools generate multiple output formats:

### Markdown Reports
- **File:** `performance_comparison_report.md`
- **Content:** Comprehensive analysis with recommendations
- **Use:** Human-readable results and documentation

### JSON Data
- **File:** `performance_results.json`
- **Content:** Raw performance metrics
- **Use:** Automated processing and integration

### CSV Export
```bash
# Convert results to CSV
./scripts/export_csv.sh performance_results.json > results.csv
```

## Best Practices

### Testing Guidelines

1. **Consistent Environment**
   - Use the same hardware for all tests
   - Minimize system load during testing
   - Use standardized test files

2. **Multiple Runs**
   - Run tests multiple times for accuracy
   - Average results to reduce noise
   - Note any outliers or anomalies

3. **Real-World Testing**
   - Test with your actual content types
   - Use representative file sizes and formats
   - Consider your typical encoding parameters

### Choosing Variants

1. **Evaluate Your Requirements**
   - Performance vs. licensing needs
   - Binary size vs. feature requirements
   - Distribution vs. development needs

2. **Test Your Workload**
   - Use your actual media files
   - Test your typical encoding scenarios
   - Measure what matters to your use case

3. **Consider Trade-offs**
   - GPL: Better performance, licensing restrictions
   - LGPL: Compatible licensing, limited features
   - Shared: Smaller size, dependency requirements
   - Static: Best performance, larger size

## Integration Examples

### CI/CD Pipeline

```yaml
# .github/workflows/performance.yml
name: Performance Testing
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Performance Comparison
        run: |
          DRY_RUN=true ./performance_comparison.sh
          # Upload results as artifacts
```

### Monitoring Dashboard

```bash
#!/bin/bash
# Monitor performance trends over time

DATE=$(date +%Y%m%d)
OUTPUT_DIR="./monitoring/results_$DATE"

./performance_comparison.sh
./scripts/update_dashboard.sh "$OUTPUT_DIR"
```

## Contributing

To improve the performance comparison tools:

1. **Add New Metrics**
   - Modify `run_performance_test()` function
   - Update report generation templates
   - Add documentation for new metrics

2. **Support New Platforms**
   - Add target detection logic
   - Implement platform-specific testing
   - Update compatibility documentation

3. **Enhance Reports**
   - Add visualization options
   - Implement additional export formats
   - Create interactive dashboards

---

For questions or issues, please open an issue in the repository or check the main [README.md](../README.md) for general information about the FFmpeg-Builds project.