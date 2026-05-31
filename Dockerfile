# 1. Base ligera
FROM node:18-bookworm

# 2. Instalar herramientas
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    sed \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 3. DESCARGA VERIFICADA CON WGET
# Usamos wget porque es más robusto para saltar redirecciones de GitHub
RUN wget --no-check-certificate -q https://github.com/VROOM-Project/vroom/releases/download/v1.14.0/vroom-linux-x86_64 -O /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom \
    && file /usr/local/bin/vroom | grep -q "ELF" || (echo "ERROR: El archivo descargado no es un binario ejecutable" && exit 1)

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
