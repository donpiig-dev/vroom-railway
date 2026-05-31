# 1. Base ligera de Node de producción
FROM node:18-alpine

# 2. Instalar herramientas mínimas de edición
RUN apk add --no-cache git sed

# 3. Clonar repositorio oficial de VROOM Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app

# 4. 🔥 PARCHES CRUCIALES DE SEGURIDAD, RUTAS Y CONEXIÓN
# Parche 1: Desbloqueo total de CORS para tu PWA
RUN sed -i "s/app.use(express.json({/app.use((req, res, next) => { res.header('Access-Control-Allow-Origin', '*'); res.header('Access-Control-Allow-Headers', 'Authorization, X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Allow-Request-Method'); res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'); res.header('Allow', 'GET, POST, OPTIONS, PUT, DELETE'); if (req.method === 'OPTIONS') { return res.sendStatus(200); } next(); }); app.use(express.json({/g" src/index.js

# Parche 2: Forzar a escuchar en la interfaz pública 0.0.0.0
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js

# Parche 3: Asegurar que la ruta base del servidor Express sea la raíz exacta sin prefijos ocultos
RUN sed -i "s/baseurl: .*/baseurl: '\/'/g" config.yml

# 5. Instalación limpia omitiendo herramientas de desarrollo
RUN npm install --omit=dev --ignore-scripts

# 6. Variables de entorno para Railway
ENV PORT=3000
EXPOSE 3000

# Ejecutamos de forma nativa para ahorrar el máximo de memoria RAM
CMD ["node", "src/index.js"]
