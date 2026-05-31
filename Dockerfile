# 1. Base estable
FROM node:18-bookworm

# 2. 🔥 INSTALACIÓN SEGURA Y VERIFICADA
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    sed \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Descarga el binario oficial de vroom v1.14.0 directamente de GitHub
# Usamos un nombre de archivo temporal para verificar que sea un ejecutable
RUN curl -L https://github.com/VROOM-Project/vroom/releases/download/v1.14.0/vroom-linux-x86_64 -o /usr/local/bin/vroom \
    && chmod +x /usr/local/bin/vroom \
    && /usr/local/bin/vroom --version

# (El resto de tu Dockerfile sigue igual...)

# 3. Clonar la interfaz Express (Node.js)
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. PARCHES DE RED, CORS Y ENRUTAMIENTO INTERNO (OSRM PRIVADO)
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js

# 🔥 CAMBIO AQUÍ: Apuntamos directamente a la red interna privada de Railway
RUN sed -i "s/host: 'localhost'/host: 'map.railway.internal'/g" config.yml
RUN sed -i "s/port: 5000/port: 5000/g" config.yml

# 5. Instalar dependencias limpias de producción de Node
RUN npm install --omit=dev --ignore-scripts

# 6. Configuración de puertos para Railway
ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
