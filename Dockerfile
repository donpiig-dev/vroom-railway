# 1. Usamos el registro oficial actualizado
FROM ghcr.io/vroom-project/vroom-docker:v1.14.0

# Cambiar a usuario root temporalmente para poder instalar Nginx
# USER root
# RUN apt-get update && apt-get install -y nginx

USER root
# Instalamos nginx y dos2unix
RUN apt-get update && apt-get install -y nginx dos2unix

# Copiar la configuración de Nginx al contenedor
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar el script de inicio y darle permisos de ejecución
COPY start.sh /start.sh
RUN chmod +x /start.sh

RUN dos2unix /start.sh && \
    chmod +x /start.sh && \
    chmod +x /docker-entrypoint.sh

# 2. Corregimos IP, puerto y el nombre del perfil (OSRM público usa 'driving', no 'car')
# RUN sed -i "s/0.0.0.0/router.project-osrm.org/g" /vroom-express/config.yml || true && \
#     sed -i "s/5000/80/g" /vroom-express/config.yml || true && \
#     sed -i "s/car/driving/g" /vroom-express/config.yml || true

# RUN sed -i "s/0.0.0.0/router.project-osrm.org/g" /conf/config.yml || true && \
#     sed -i "s/5000/80/g" /conf/config.yml || true && \
#     sed -i "s/car/driving/g" /conf/config.yml || true

# 3. Exponemos el puerto que espera Railway
ENV PORT=3000
EXPOSE 3000

# Exponer el nuevo puerto de Nginx
EXPOSE 8080

# Usar nuestro script como el nuevo punto de arranque
ENTRYPOINT ["/start.sh"]
