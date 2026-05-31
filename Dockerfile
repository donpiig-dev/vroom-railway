# Usamos una imagen de Debian estable
FROM debian:bookworm-slim

# Instalamos todo lo necesario para compilar
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libasio-dev \
    libboost-all-dev \
    libglpk-dev \
    curl \
    ca-certificates \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Descargamos el código fuente comprimido (más estable que un binario directo)
# y lo compilamos internamente
# 3. Compilación de VROOM (Ruta absoluta forzada)
RUN curl -L https://github.com/VROOM-Project/vroom/archive/refs/tags/v1.14.0.tar.gz -o vroom.tar.gz \
    && tar -xzf vroom.tar.gz \
    && cd $(find . -maxdepth 1 -type d -name "vroom-*") \
    && mkdir build && cd build \
    && cmake .. \
    && make \
    && cp bin/vroom /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom \
    && cd / && rm -rf vroom-* vroom.tar.gz
# Clonar app y configurar
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# Parches
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'router.project-osrm.org'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
