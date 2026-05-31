# 1. Base Debian ligera y compatible
FROM debian:bullseye-slim

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# 2. INSTALACIÓN DE HERRAMIENTAS Y NODE.JS
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    sed \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3. DESCARGA DIRECTA DEL BINARIO VROOM (Verificado)
# Descargamos el binario, le damos permisos y lo movemos a /usr/local/bin
RUN curl -L https://github.com/VROOM-Project/vroom/releases/download/v1.14.0/vroom-linux-x86_64 -o /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom

# 4. INSTALAR VROOM-EXPRESS
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 5. PARCHES DE CONFIGURACIÓN
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
# Configuramos el host y puerto de OSRM (Asegúrate de que OSRM esté activo en Railway)
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
