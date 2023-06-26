#!/bin/bash
# set sh strict mode
set -o errexit
set -o nounset
IFS=$(printf '\n\t')

cd /home/scu/k_wave

echo "starting service as"
echo   User    : "$(id "$(whoami)")"
echo   Workdir : "$(pwd)"
echo "..."
echo
# ----------------------------------------------------------------
# This script shall be modified according to the needs in order to run the service

# From isolve: checking for resources limit env vars injected by osparc
SIMCORE_NANO_CPUS_LIMIT="${SIMCORE_NANO_CPUS_LIMIT:-0}"
echo "Setting/getting CPU limit gives this: ${SIMCORE_NANO_CPUS_LIMIT}"
if [ "${SIMCORE_NANO_CPUS_LIMIT}" -ne "0" ]
then
    echo "Found NANO_CPU limits: ${SIMCORE_NANO_CPUS_LIMIT}"
    NANO_CPU_DIVISOR=1000000000
    MAX_CPUS=$((${SIMCORE_NANO_CPUS_LIMIT} / ${NANO_CPU_DIVISOR}))
    # use 1 if this is 0 otherwise floor is probably fine
    if [ "${MAX_CPUS}" -eq "0" ]
    then
        MAX_CPUS=1
    fi
    echo "Setting Z43_MAX_CPU_RESOURCES to " "${MAX_CPUS}"
    export Z43_MAX_CPU_RESOURCES="${MAX_CPUS}"
else
    MAX_CPUS=1
fi

# Create an array of arguments, mandatory ones are -i and -o, the others comes from the input ports, except CPU threads
# For the list of arguments see http://www.k-wave.org/manual/k-wave_user_manual_1.1.pdf, page 54
args=(
-i ${INPUT_FOLDER}/input.h5
-o ${OUTPUT_FOLDER}/output.h5
-c ${INPUT_2}
-t ${MAX_CPUS}
-s ${INPUT_17}
--verbose 2
)
echo "Parsing input ports..."
# Optional output flags: if checked in the UI -> input is true -> add flag
if [ $INPUT_3 = true ]; then
    args+=(--p_rms)
fi
if [ $INPUT_4 = true ]; then
    args+=(--p_max)
fi
if [ $INPUT_5 = true ]; then
    args+=(--p_min)
fi
if [ $INPUT_6 = true ]; then
    args+=(--p_max_all)
fi
if [ $INPUT_7 = true ]; then
    args+=(--p_min_all)
fi
if [ $INPUT_8 = true ]; then
    args+=(--p_final)
fi
if [ $INPUT_9 == true ]; then
    args+=(-u)
fi
if [ $INPUT_10 = true ]; then
    args+=(--u_non_staggered_raw)
fi
if [ $INPUT_11 = true ]; then
    args+=(--u_rms)
fi
if [ $INPUT_12 = true ]; then
    args+=(--u_max)
fi
if [ $INPUT_13 = true ]; then
    args+=(--u_min)
fi
if [ $INPUT_14 = true ]; then
    args+=(--u_max_all)
fi
if [ $INPUT_15 = true ]; then
    args+=(--u_min_all)
fi
if [ $INPUT_16 = true ]; then
    args+=(--u_final)
fi
if [ $INPUT_18 = true ]; then
    args+=(--copy_sensor_mask)
fi

echo "Launching kspaceFirstOrder-CUDA with args ${args[@]}"
./kspaceFirstOrder-CUDA "${args[@]}"

# then retrieve the output and move it to the $OUTPUT_FOLDER
# as defined in the output labels
# Output file is already in ${OUTPUT_FOLDER}/ (see -o argument)

