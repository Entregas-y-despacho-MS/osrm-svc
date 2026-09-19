#!/bin/sh
set -e

if [ -f /data/map.osrm ]; then
    echo "map.osrm ya existe — se salta el preprocesamiento."
    exit 0
fi

osrm-extract -p /opt/car.lua /data/map.osm.pbf
osrm-partition /data/map.osrm
osrm-customize /data/map.osrm
