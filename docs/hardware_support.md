# Hardware support

## Status matrix

| Hardware                                     | Exec point R/R | Big/little configuration | CPU power reading | Tested |
| -------------------------------------------- | -------------- | ------------------------ | ----------------- | ------ |
| Apple M2 (non-Pro/Max/Ultra)                 | Y              | Y                        | Y                 | Y      |
| Apple M1 (non-Pro/Max/Ultra)                 | Y              | Y                        | Y                 | N      |
| Other Apple Silicon                          | Y              | N                        | N                 | N      |
| Intel Core i7-12700 or i7-14700              | Y              | Y                        | -                 | Y      |
| Other 12th/13th/14th-gen heterogeneous Intel | Y              | N                        | -                 | N      |

## Enabling exec point R/R for a new processor

See `app/docs/hardware_support.md`.

## Adding big/little configuration for a new processor

In `support_files/spec06/spec_submit.sh`, add your processor to the CPU detection logic in function `parallaft_set_cpu_sets` and set `BIG_CORES_SET_1`, `BIG_CORES_SET_2`, `BIG_CORES_SET_ALL`, and `SMALL_CORES` based on the big/little core configuration of your processor.

## Implementing CPU power reading (Apple Silicon only)

See [arm64: dts: apple: t8112-j473: Add power, voltage, and current hwmon … · mbyzhang/linux-asahi@58a1322 · GitHub](https://github.com/mbyzhang/linux-asahi/commit/58a13220f4f08aedae903ae4f815f691fe7a158c) as an example on how to implement CPU power reading. Only power sensors are necessary for the experiments. You will need some reverse engineering work to work out the SMC key IDs.

You then need to rebuild and install the modified device tree blobs (DTBs) (by running `make dtbs` under `kernel/linux-asahi` and replicating the DTB installation steps in `scripts/build_kernel.sh`). You don't need to rebuild the entire kernel.

To validate that the sensors are working, install `lm-sensors` package and run `sensors` command to check if the sensors appear with the correct values.

Before starting the experiments, if you use different sensor labels, modify the labels in function `parallaft_enable_hwmon` of `support_files/spec06/spec_submit.sh` and in constant `FIELD_LIST` of `tools/collect_stats.py`.
