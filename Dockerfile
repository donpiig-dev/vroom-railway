# 1. Usamos Ubuntu LTS como base
FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# 2. 🔥 REPARACIÓN DE REPOSITORIOS E INSTALACIÓN DE VROOM Y NODE
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    ca-certificates \
    git \
    sed \
    && add-apt-repository universe \
    && apt-get update \
    && apt-get install -y --no-install-recommends vroom \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Clonar la interfaz Express (Node.js)
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. PARCHES DE RED, CORS Y ENRUTAMIENTO (OSRM)
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 443/g" config.yml

# 5. Instalar dependencias limpias de producción de Node
RUN npm install --omit=dev --ignore-scripts

# 6. Configuración de puertos para Railway
ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
