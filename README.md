# osrm-svc

Motor de ruteo self-hosted ([OSRM](https://project-osrm.org/)), usado por `delivery-dispatch-svc`
para calcular rutas óptimas y ETA (ver su plugin `src/plugins/osrm/`). No es un microservicio propio
del ERP — es infraestructura de soporte, autocontenida, sin dependencias del resto del proyecto.

Se descarta explícitamente para tracking GPS en tiempo real (eso va directo por REST+Socket.IO
desde el backend) — OSRM se consulta puntualmente al momento de planear una ruta, no en cada
posición del repartidor.

## Estructura

```
osrm-svc/
├── scripts/
│   ├── download.sh      # descarga el extracto de Bolivia (Geofabrik), idempotente
│   └── preprocess.sh    # osrm-extract -> osrm-partition -> osrm-customize, idempotente
└── osrm-data/            # gitignored — el .osm.pbf descargado + los archivos procesados (~cientos de MB)
```

Ambos scripts se saltan solos si ya corrieron antes (chequean si el archivo de salida ya existe) —
seguro reiniciar el stack sin volver a descargar/procesar cada vez.

## Cómo se levanta

No tiene `docker-compose.yml` propio — corre como parte del compose de `delivery-dispatch-ms`
(`../docker-compose.yml`), como 3 servicios encadenados:

```
osrm-download (una vez) -> osrm-preprocess (una vez) -> osrm (queda corriendo)
```

```bash
cd ..   # a delivery-dispatch-ms/
docker compose up -d osrm
```

La primera vez tarda (descarga ~170 MB + preprocesa el extracto completo de Bolivia); las
siguientes veces `osrm-data/` ya tiene todo listo y arranca directo.

## Datos

Extracto de Bolivia desde [Geofabrik](https://download.geofabrik.de/south-america/bolivia-latest.osm.pbf),
perfil de ruteo `car.lua` (vehículo motorizado), algoritmo `mld` (multi-level Dijkstra). Si el
extracto queda desactualizado, basta borrar `osrm-data/` y volver a correr `osrm-download` +
`osrm-preprocess` — no hay estado que migrar, se regenera todo desde cero.

## Cómo se conecta el backend

`delivery-dispatch-svc` le pega vía `OSRM_URL` (env var):
- Desde el host: `http://localhost:5001` (puerto publicado).
- Desde otro contenedor en la misma red (`delivery-dispatch-net`): `http://osrm:5000` (nombre del
  servicio, puerto interno del contenedor — no confundir con el `5001` de arriba).
