# 1. Usamos la imagen oficial que contiene el binario compilado de VROOM
FROM vroomproject/vroom:latest

# 2. Instalamos Node.js para que pueda correr el vroom-express
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    sed \
    && rm -rf /var/lib/apt/lists/*

# 3. Clonar la interfaz Express
RUN git clone https://github.com/VROOM-Project/vroom-express.git /app
WORKDIR /app
RUN npm install --omit=dev --ignore-scripts

# 4. Parches de red
RUN sed -i "s/const host = '127.0.0.1';/const host = '0.0.0.0';/g" src/index.js
RUN sed -i "s/host: 'localhost'/host: 'map-production-c2c6.up.railway.app'/g" config.yml
RUN sed -i "s/port: 5000/port: 80/g" config.yml

ENV PORT=3000
EXPOSE 3000

# 5. Lanzar Express
CMD ["node", "src/index.js"]
