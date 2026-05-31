# 1. Base ligera
FROM node:18-bookworm-slim

# 2. INSTALACIÓN TOTAL DE DEPENDENCIAS
# Instalamos TODO lo necesario para compilar y descargar en un solo paso
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libasio-dev \
    libboost-all-dev \
    libglpk-dev \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 3. Compilación de VROOM (Ruta explícita y descarga robusta)
RUN curl -L https://github.com/VROOM-Project/vroom/archive/refs/tags/v1.14.0.tar.gz -o vroom.tar.gz \
    && tar -xzf vroom.tar.gz \
    && ls -R /vroom-1.14.0* # Debug: esto nos dirá en el log dónde está el CMakeLists.txt \
    && cd $(ls -d /vroom-1.14.0*) \
    && mkdir build && cd build \
    && cmake .. \
    && make \
    && cp bin/vroom /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom \
    && cd / && rm -rf vroom-1.14.0* vroom.tar.gz

# 4. Clonar y configurar vroom-express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 5. Parches de configuración
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
