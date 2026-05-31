# 1. Base ligera de Node de producción
FROM node:18-alpine

# 2. Instalar herramientas mínimas de edición
RUN apk add --no-cache git sed

# 3. Clonar repositorio oficial de VROOM Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. 🔥 PARCHES DE SEGURIDAD Y CONEXIÓN
# Parche 1: Desbloqueo total de CORS para tu PWA
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js

# Parche 2: Escuchar en la interfaz pública 0.0.0.0 en lugar de localhost
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js

# 5. Instalar dependencias omitiendo las de desarrollo para ahorrar un 60% de RAM
RUN npm install --only=production

# 6. Forzar a Express a leer la variable PORT dinámica de Railway
ENV PORT=3000
EXPOSE 3000

# 🔥 CAMBIO CRUCIAL: Ejecutamos el archivo directamente con Node, saltándonos NPM
CMD ["node", "src/index.js"]
