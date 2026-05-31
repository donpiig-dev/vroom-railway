# 1. Usamos la imagen oficial de VROOM Express como base limpia de Node
FROM node:18-alpine

# 2. Instalar dependencias del sistema necesarias para compilar VROOM (C++)
RUN apk add --no-cache git make g++ bsdtf-dev libosrm-dev geojson-glib-dev boost-dev

# 3. Clonar el repositorio oficial de la API Express de VROOM
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app

WORKDIR /app

# 4. Instalar las dependencias de Node.js e inyectar el puerto dinámico de Railway
RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
