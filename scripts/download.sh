#!/bin/sh
set -e

if [ -f /data/map.osrm ] || [ -f /data/map.osm.pbf ]; then
    echo "map.osm.pbf o map.osrm ya existen — se salta la descarga."
    exit 0
fi

echo "Descargando extracto de Bolivia (Geofabrik, ~170 MB)..."
curl -fL --retry 3 --retry-delay 5 -o /data/map.osm.pbf \
    https://download.geofabrik.de/south-america/bolivia-latest.osm.pbf
