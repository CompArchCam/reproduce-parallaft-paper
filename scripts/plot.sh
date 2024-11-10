#!/bin/bash

set -e

cd "$(dirname "$0")/.."
BASE="$PWD"

RUN_DIR="$BASE/spec06/releval/run"
PLOTS_DIR="$BASE/plots"

COLLECT_STATS_ARGS=(
    --base "$RUN_DIR/base"
    --parallaft "$RUN_DIR/parallaft_5000000000-ipc_all-big_parallaft-unknown"
    --raft "$RUN_DIR/parallaft_raft_all-big_parallaft-unknown"
    --no-bench-number
    --no-header
    --sep " "
    --scale 100.0
    --geomean
)

function plot_graph() {
    ./tools/collect_stats.py "$1" --output "$PLOTS_DIR/$2.dat" "${COLLECT_STATS_ARGS[@]}"
    make -C "$PLOTS_DIR" $2.pdf
}

plot_graph parallaft_performance_overhead_breakdown performance_overhead_breakdown
