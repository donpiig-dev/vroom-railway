# 1. Usamos el registro oficial actualizado de GitHub (ghcr.io)
FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# 2. La imagen oficial ya trae el servidor y la configuración.
# Solo necesitamos indicarle que use el OSRM público en lugar de buscarlo localmente.
# (Aplicamos el parche en las rutas donde la imagen oficial suele guardar la config)
RUN sed -i "s/host: 'localhost'/host: 'router.project-osrm.org'/g" /vroom-express/config.yml || true && \
    sed -i "s/port: 5000/port: 80/g" /vroom-express/config.yml || true

RUN sed -i "s/host: 'localhost'/host: 'router.project-osrm.org'/g" /conf/config.yml || true && \
    sed -i "s/port: 5000/port: 80/g" /conf/config.yml || true

# 3. Exponemos el puerto que espera Railway
ENV PORT=3000
EXPOSE 3000

# No necesitamos un CMD porque la imagen base ya arranca el servidor automáticamente
