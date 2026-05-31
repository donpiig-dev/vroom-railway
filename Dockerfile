# 1. Usamos una imagen ligera de Node de nivel de producción
FROM node:18-alpine

# 2. Instalar únicamente las herramientas básicas de descarga del sistema
RUN apk add --no-cache git

# 3. Clonar el repositorio oficial de la interfaz de VROOM Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app

WORKDIR /app

# 4. Instalar las dependencias de JavaScript
RUN npm install

# Exponer el puerto dinámico asignado por Railway
EXPOSE 3000

CMD ["npm", "start"]
