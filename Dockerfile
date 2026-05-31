# 1. Usamos el registro oficial actualizado
FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# 2. Corregimos IP, puerto y el nombre del perfil (OSRM público usa 'driving', no 'car')
RUN sed -i "s/0.0.0.0/router.project-osrm.org/g" /vroom-express/config.yml || true && \
    sed -i "s/5000/80/g" /vroom-express/config.yml || true && \
    sed -i "s/car/driving/g" /vroom-express/config.yml || true

RUN sed -i "s/0.0.0.0/router.project-osrm.org/g" /conf/config.yml || true && \
    sed -i "s/5000/80/g" /conf/config.yml || true && \
    sed -i "s/car/driving/g" /conf/config.yml || true

# 3. Exponemos el puerto que espera Railway
ENV PORT=3000
EXPOSE 3000
