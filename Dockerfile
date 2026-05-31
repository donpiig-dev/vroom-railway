# 1. Usar Ubuntu 22.04 (más compatible con binarios de VROOM)
FROM ubuntu:22.04

# 2. Instalar dependencias esenciales
RUN apt-get update && apt-get install -y \
    curl \
    git \
    nodejs \
    npm \
    libboost-all-dev \
    libglpk-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Descargar y asegurar permisos
RUN curl -L https://github.com/VROOM-Project/vroom/releases/download/v1.14.0/vroom-linux-x86_64 -o /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom

# 4. App
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 5. Parches (usar OSRM público)
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'router.project-osrm.org'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

# 6. MANTENER VIVO: Si node muere, el contenedor no se detiene, permitiendo ver logs
ENV PORT=3000
EXPOSE 3000

CMD ["sh", "-c", "node src/index.js || (echo 'Node murió, manteniendo contenedor...' && sleep 3600)"]
# CMD ["sh", "-c", "/usr/local/bin/vroom --version && echo 'Binario OK' || echo 'Binario FALLA' && sleep 3600"]
