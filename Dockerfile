# 1. Usamos Debian Bookworm (versión estable que sí incluye el paquete vroom oficial)
FROM node:18-bookworm

# 2. Instalamos vroom de forma nativa desde el gestor de paquetes de Debian
# Esto evita tener que descargar binarios a mano o compilar
RUN apt-get update && apt-get install -y --no-install-recommends \
    vroom \
    git \
    sed \
    && rm -rf /var/lib/apt/lists/*

# 3. Clonar y configurar la app Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 4. Parches de red (Asegúrate de cambiar tu dominio aquí)
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
