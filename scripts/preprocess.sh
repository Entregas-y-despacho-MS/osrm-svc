#!/bin/sh
set -e

# osrm-customize es el último paso y escribe map.osrm.mldgr al final; con MLD no existe un archivo
# map.osrm a secas, así que se usa ese para saber si el preprocesado terminó completo.
if [ -f /data/map.osrm.mldgr ]; then
    echo "map.osrm.mldgr ya existe (preprocesado completo) — se salta el preprocesamiento."
    exit 0
fi

osrm-extract -p /opt/car.lua /data/map.osm.pbf
osrm-partition /data/map.osrm
osrm-customize /data/map.osrm
