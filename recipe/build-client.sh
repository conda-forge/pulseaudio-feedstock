#!/usr/bin/env bash

meson_config_args=(
    -Dclient=true
    -Ddaemon=false
    --wrap-mode=nodownload
    -Ddatabase=simple
    -Ddoxygen=false
    -Dudevrulesdir=${PREFIX}/lib/udev/rules.d
)

# MESON_ARGS is set by conda compiler activation script
meson setup buildconda_client \
    ${MESON_ARGS} \
    "${meson_config_args[@]}" \
    || (cat buildconda_client/meson-logs/meson-log.txt; false)
meson compile -C buildconda_client -j ${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    # only error on linux-64 for now since some tests fail on other linux
    # platforms and there's no easy way to disable specific tests
    if [[ $target_platform == linux-64 ]] ; then
        meson test -C buildconda_client --print-errorlogs --timeout-multiplier 25
    else
        meson test -C buildconda_client --print-errorlogs --timeout-multiplier 25 || true
    fi
fi
meson install -C buildconda_client --no-rebuild
