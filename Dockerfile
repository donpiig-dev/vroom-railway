# 1. Base Debian con herramientas de compilación
FROM debian:bullseye-slim

# Instalar dependencias necesarias para compilar VROOM
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libasio-dev \
    libboost-all-dev \
    libglpk-dev \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# 2. Compilar VROOM desde el código fuente oficial
RUN git clone https://github.com/VROOM-Project/vroom.git /vroom-source \
    && cd /vroom-source \
    && mkdir build && cd build \
    && cmake .. && make -j$(nproc) \
    && cp /vroom-source/bin/vroom /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom

# 3. Instalar vroom-express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 4. Parchear configuración (usa tu dominio de Railway)
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
