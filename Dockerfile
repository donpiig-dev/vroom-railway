# 1. Usamos la imagen oficial de VROOM
FROM vroomproject/vroom:v1.14.0

# 2. Instalamos Node.js para que Express pueda correr
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    sed \
    && rm -rf /var/lib/apt/lists/*

# 3. Clonar la interfaz Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. PARCHES DE RED Y ENRUTAMIENTO
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

# 5. Instalación
RUN npm install --omit=dev --ignore-scripts

ENV PORT=3000
EXPOSE 3000

# El comando de inicio debe lanzar Express, que a su vez llama al binario 'vroom' que ya está en el PATH
CMD ["node", "src/index.js"]
