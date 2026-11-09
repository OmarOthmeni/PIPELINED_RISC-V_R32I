#!/usr/bin/env bash
# Build every program in sw/tests/, load it into the CPU and simulate it with GHDL.
# Usage: scripts/run_tests.sh            (needs ghdl and a riscv-*-elf-gcc on PATH)
#        RISCV_PREFIX=riscv64-unknown-elf- scripts/run_tests.sh
set -u
cd "$(dirname "$0")/.."

GHDL=${GHDL:-ghdl}
RISCV_PREFIX=${RISCV_PREFIX:-riscv-none-elf-}
WORK=build/ghdl
fails=0

for prog in sw/tests/*.S sw/tests/*.c; do
    [ -e "$prog" ] || continue
    rel=${prog#sw/}
    name=$(basename "$prog")
    if ! make -s -C sw PROG="$rel" RISCV_PREFIX="$RISCV_PREFIX" >/dev/null; then
        echo "BUILD FAIL  $name"; fails=$((fails + 1)); continue
    fi
    rm -rf "$WORK"; mkdir -p "$WORK"
    $GHDL -i --std=08 --workdir="$WORK" src/*.vhd tb/tb_cpu_selfcheck.vhd
    $GHDL -m --std=08 --workdir="$WORK" tb_cpu_selfcheck >/dev/null
    out=$($GHDL -r --std=08 --workdir="$WORK" tb_cpu_selfcheck --ieee-asserts=disable 2>&1)
    status=$?
    result=$(echo "$out" | grep -oE "(PASS|FAIL)[^\"]*" | tail -1)
    printf "%-12s %s\n" "$name" "${result:-no result (exit $status)}"
    [ $status -eq 0 ] || fails=$((fails + 1))
done

# leave the demo program loaded, as in the original repository
make -s -C sw PROG=examples/main.c RISCV_PREFIX="$RISCV_PREFIX" >/dev/null || true

if [ $fails -eq 0 ]; then echo "All tests passed."; else echo "$fails test program(s) failed."; fi
exit $fails
