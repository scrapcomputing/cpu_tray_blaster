#!/bin/bash

if [ "${openscad}" == "" ]; then
    echo "ERROR: Please set 'openscad' env variable!"
    exit 1
fi

dir=stl/
rm -rf ${dir}

from_sz=1
to_sz=4
make clean
for (( x=${from_sz}; x<=${to_sz}; x++ )); do
    for (( y=${from_sz}; y<=${to_sz}; y++ )); do
        grid="${x}x${y}" out_dir=${dir}/${grid} make all -j
    done
done
zip -r cpu_tray_blaster_stl_${from_sz}x${from_sz}_to_${to_sz}x${to_sz}.zip ${dir}
