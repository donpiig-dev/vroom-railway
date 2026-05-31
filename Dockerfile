# 1. Base ligera de Node
FROM node:18-alpine

# 2. Herramientas básicas de edición
RUN apk add --no-cache git sed

# 3. Clonar repositorio oficial de VROOM Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. 🔥 PARCHE EXCLUSIVO: Desbloqueo de CORS y apertura de interfaz de red pública
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js

# 🔥 CAMBIO CLAVE: Cambiamos '127.0.0.1' por '0.0.0.0' para aceptar tráfico de internet en Railway
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js

# 5. Instalar dependencias normales
RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
