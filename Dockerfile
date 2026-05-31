# Usa una imagen base compatible
FROM ubuntu:22.04

# Instalar dependencias necesarias para compilar y ejecutar
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libasio-dev \
    libboost-all-dev \
    libglpk-dev \
    nodejs \
    npm \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clonar y compilar VROOM desde el código fuente oficial
RUN git clone https://github.com/VROOM-Project/vroom.git /vroom-source \
    && cd /vroom-source \
    && mkdir build && cd build \
    && cmake .. \
    && make \
    && cp bin/vroom /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom \
    && rm -rf /vroom-source

# Instalar vroom-express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# Variables de entorno y configuración
ENV VROOM_PATH=/usr/local/bin/vroom
ENV PORT=3000
EXPOSE 3000

# Parchear configuración de host para Railway
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js

CMD ["node", "src/index.js"]
