# 1. Usamos la imagen oficial de Node basada en Debian (mucho más compatible con herramientas C++)
FROM node:18-bullseye-slim

# 2. 🔥 INSTALACIÓN DIRECTA DEL MOTOR NATIVO VROOM
# Actualizamos los repositorios e instalamos el binario oficial de vroom listo para usar
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    sed \
    vroom \
    && rm -rf /var/lib/apt/lists/*

# 3. Clonar el repositorio oficial de la interfaz Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. 🔥 PARCHES DE RED, CORS Y ENRUTAMIENTO (OSRM)
# Parche 1: Desbloqueo total de CORS para tu PWA
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js

# Parche 2: Escuchar en la interfaz pública 0.0.0.0 en lugar de localhost
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js

# Parche 3: Configurar tu OSRM en el config.yml de VROOM
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 443/g" config.yml

# 5. Instalar dependencias de producción limpias omitiendo scripts de desarrollo
RUN npm install --omit=dev --ignore-scripts

# 6. Variables de entorno básicas para Railway
ENV PORT=3000
EXPOSE 3000

# Ejecución nativa directa con Node para cuidar la RAM
CMD ["node", "src/index.js"]
