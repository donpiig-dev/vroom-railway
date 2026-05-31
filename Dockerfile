# 1. Base ligera
FROM node:18-bookworm

# 2. Instalar dependencias necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    sed \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 3. DESCARGAR BINARIO VROOM OFICIAL (Evita repositorios inestables)
# Descarga, da permisos de ejecución y verifica la versión
RUN curl -L -o /usr/local/bin/vroom https://github.com/VROOM-Project/vroom/releases/download/v1.14.0/vroom-linux-x86_64 \
    && chmod +x /usr/local/bin/vroom \
    && /usr/local/bin/vroom --version

# 4. Clonar y configurar la app Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 5. Parches de red
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
