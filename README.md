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
$ ./scripts/install_spec06.sh
```

### Additional steps for Apple Silicon aarch64

On Apple Silicon aarch64, we need a patched Linux kernel to access power sensor readings (for measuring energy consumption in our experiments) and for Parallaft to monitor dirty pages. To do that, run

```sh
$ ./scripts/build_kernel.sh
$ sudo reboot
$ ./scripts/check_kernel.sh
```

If everything is okay, you should see the following.

```
Checking kernel version...
Kernel version is OK
Checking power sensor...
Power sensor is OK
```

Our patch only supports reading power sensors from Apple M1 and M2 processors (non-Pro/Max/Ultra models). If you are not using one of these, check `docs/hardware_support.md` for guide to add support for your processor.

## Workflow

### Running all experiments

In our experiments, the following runs are performed on all SPEC CPU 2006 int and fp benchmarks.

* A baseline run, to get execution time and CPU time without Parallaft or RAFT.
* (aarch64 only) A baseline energy-consumption profiling run, to get baseline energy consumption without Parallaft or RAFT.
* A Parallaft run.
* A RAFT run.

To run all experiments, run:

```sh
$ ./scripts/run.sh
```

Raw results (`*.stats.txt`) will be available under `spec06/releval/run/*/result`.

### Plotting results

Our experiments reproduce the following plots.

* Performance overhead of Parallaft and RAFT (Figure 5).
* Performance-overhead breakdown of Parallaft (Figure 6).
* Energy overhead of Parallaft and RAFT (Figure 7). This result will only be available on Apple Silicon aarch64 platforms.

To plot them, run:

```sh
$ ./scripts/plot.sh
```

Plots will be available under `plots` directory. On an Apple M2, they should look broadly similar to the figures in our paper.

### Customization

- **Running a subset of benchmarks or experiments**: Modify `BENCHMARKS` and `EXPERIMENTS` in `scripts/run.sh`.
- **Tuning parameters**: Adjust `PARALLAFT_CHECKPOINT_PERIOD` in `scripts/run.sh`.

### Running an arbitrary program under Parallaft

```sh
$ ./bin/parallaft --config ./app/parallaft/configs/apple_m2_fixed_interval.yml -- path/to/your/program arg1 arg2
```

When the execution finishes, Parallaft dumps some statistics. The key ones are:

- `timing.all_wall_time`: Wall time elapsed to finish the program execution, including the waiting time for outstanding checkers to finish after the main finishes.
- `timing.main_wall_time`: Wall time elapsed to finish the main program execution, excluding the waiting time for checkers.
- `timing.main_{user,sys}_time`: User/system time used by the main program execution.
- `hwmon.macsmc_hwmon/*`: *(Apple Silicon only)* Energy used for different components of the SoC during the program execution.
- `counter.checkpoint_count`: Number of checkpoints taken, including checkpoints taken to handle certain `mmap` syscalls and to slice the program execution for checker parallelism.
- `fixed_interval_slicer.nr_slices`: Number of checkpoints taken to slice the program execution after reaching a specified checkpoint period.

Use another config to run on a Intel processor, e.g. for Intel Core i7-12700, use `intel_12700_fixed_interval.yml`.
