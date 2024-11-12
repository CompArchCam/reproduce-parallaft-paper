#!/bin/bash

set -e -x

cd "$(dirname "$0")/.."
BASE="$PWD"

RUN_DIR="$BASE/spec06/releval/run"
PLOTS_DIR="$BASE/plots"

COLLECT_STATS_ARGS=(
    --base "$RUN_DIR/base"
    --parallaft "$RUN_DIR"/parallaft_*-ipc_heterogeneous_parallaft-unknown
    --raft "$RUN_DIR/parallaft_raft_all-big_parallaft-unknown"
    --no-bench-number
    --no-header
    --sep " "
    --scale 100.0
)

if [ `uname -m` = "aarch64" ]; then
    COLLECT_STATS_ARGS+=(
        --base_perf_counters "$RUN_DIR/parallaft_perfcounters_all-big_parallaft-unknown"
    )
fi

function plot_graph() {
    ./tools/collect_stats.py "$1" --output "$PLOTS_DIR/$2.dat" "${COLLECT_STATS_ARGS[@]}" "${@:3}"
    make -C "$PLOTS_DIR" $2.pdf
}

plot_graph performance_overhead_parallaft_vs_raft performance_overhead --geomean
plot_graph parallaft_performance_overhead_breakdown performance_overhead_breakdown

if [ `uname -m` = "aarch64" ]; then
    plot_graph energy_overhead_parallaft_vs_raft energy_overhead --geomean
fi
