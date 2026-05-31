# Usamos la imagen oficial de VROOM que ya incluye el binario compilado
FROM vroomproject/vroom:v1.14.0

# Instalamos Node.js para ejecutar el vroom-express
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clonar y configurar vroom-express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# Configuración
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'router.project-osrm.org'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

# La imagen oficial ya tiene el binario en /usr/local/bin/vroom
ENV VROOM_PATH=/usr/local/bin/vroom
ENV PORT=3000
EXPOSE 3000

CMD ["node", "src/index.js"]
