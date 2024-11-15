# Artefact Evaluation for Parallaft

The repository contains the source code of Parallaft and scripts to reproduce the experiments from the paper "Parallaft: Runtime-based CPU Fault Tolerance via Heterogeneous Parallelism" submitted to CGO 2025.

## Repository links

- Latest version of this repository: [reproduce-parallaft-paper](https://github.com/CompArchCam/reproduce-parallaft-paper)
- Latest version of Parallaft: [parallaft](https://github.com/CompArchCam/parallaft)

## Prerequisites

- **Hardware**:
    - **CPU**:
        - Apple M2 (strongly recommended, works out of the box), or
        - Apple M1 (recommended, but untested), or
        - other Linux-capable Apple Silicon processors (less recommended, needs manual big/little configuration and manual kernel patching, see `docs/hardware_support.md`), or
        - heterogeneous Intel x86_64 processors (not recommended, lacking energy overhead measurements, and might need manual big/little configuration, see `docs/hardware_support.md`)
    - **RAM**: 16GB or more
- **Software**:
    - **OS**: Ubuntu 24.04 (on x86_64) or Ubuntu Asahi 24.04 (on Apple Silicon aarch64)
    - **Benchmark**: SPEC CPU 2006 (obtained separately)
    - **Runtime environment**: Available RAM and swap combined should be at least 24GB

## Installation

To clone the repository and install dependencies, run:

```sh
$ git clone https://github.com/CompArchCam/reproduce-parallaft-paper --recursive
$ ./scripts/deps.sh
```

Log out and log back in to enable Docker access without sudo.

To build Parallaft binary, run:

```sh
$ ./scripts/build_app.sh
```

To install SPEC CPU 2006, first obtain a copy of SPEC CPU 2006 ISO and place `cpu2006-1.2.iso` at the root of the artefact package. Then execute:

```sh
$ ./install_spec06.sh
```

### Additional steps for Apple Silicon aarch64

On Apple Silicon aarch64, we need a patched Linux kernel to access power sensor readings (for measuring energy consumption in our experiments) and for Parallaft to monitor dirty pages. To do that, run

```sh
$ ./build_kernel.sh
$ sudo reboot
$ ./check_kernel.sh
```

If everything is okay, you should see the following.

```
Checking kernel version...
Kernel version is OK
Checking power sensor...
Power sensor is OK
```

Our patch only supports reading power sensors from Apple M1 and M2 processors (non-Pro/Max/Ultra models). If you are not using one of these, check `docs/hardware_support.md` for guide to add support for your processor.

## Running experiments

## Run all experiments and plot results

```sh
$ ./run.sh
$ ./plot.sh
```

Plots will be available under `plots` directory. We do not plot energy overhead on x86_64 processors due to their lack of separate voltage domains for big and little cores (hence giving little energy savings).

### Customization

- **Running a subset of benchmarks or experiments**: Modify `BENCHMARKS` and `EXPERIMENTS` in `scripts/run.sh`.
- **Tuning parameters**: Adjust `PARALLAFT_CHECKPOINT_PERIOD` in `scripts/run.sh`.

## Running an arbitrary program under Parallaft

```sh
$ ./bin/parallaft --config ./app/parallaft/configs/apple_m2_fixed_interval.yml -- path/to/your/program arg1 arg2
```
