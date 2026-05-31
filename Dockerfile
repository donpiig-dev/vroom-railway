# 1. Volvemos a la imagen ultra estable de Node sobre Debian
FROM node:18-bullseye

# 2. 🔥 DESCARGA DIRECTA DEL BINARIO PRECOMPILADO (CERO COMPILACIÓN, CERO AP-GET ROTOR)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    sed \
    && rm -rf /var/lib/apt/lists/*

# Descargamos el binario de VROOM v1.14.0 compilado para Linux x86_64, lo movemos y le damos permisos
RUN curl -L -o /usr/local/bin/vroom https://github.com/VROOM-Project/vroom/releases/download/v1.14.0/vroom-linux-x86_64 \
    && chmod +x /usr/local/bin/vroom

# 3. Clonar la interfaz Express (Node.js)
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. PARCHES DE RED, CORS Y ENRUTAMIENTO (OSRM)
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
# Parchear el archivo de configuración para usar el OSRM privado o público correctamente
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

# 5. Instalar dependencias limpias de producción de Node
RUN npm install --omit=dev --ignore-scripts

# 6. Configuración de puertos para Railway
ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
