# 1. Usamos una imagen de Debian estable (más completa que slim)
FROM debian:bookworm

# 2. Instalamos las dependencias de ejecución de VROOM
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    libboost-program-options1.81.0 \
    libboost-thread1.81.0 \
    libglpk40 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Instalamos vroom-express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 4. En lugar de compilar, bajamos el binario DE LA RELEASE OFICIAL
# Esta vez bajamos la versión que es estáticamente vinculada
RUN curl -L https://github.com/VROOM-Project/vroom/releases/download/v1.14.0/vroom-linux-x86_64 -o /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom

# 5. Configuración
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'router.project-osrm.org'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV VROOM_PATH=/usr/local/bin/vroom
ENV PORT=3000
EXPOSE 3000

# CMD ["node", "src/index.js"]
# CMD temporal para diagnosticar el binario
CMD ["sh", "-c", "/usr/local/bin/vroom --version && echo 'Binario OK' || echo 'Binario FALLA' && sleep 3600"]
