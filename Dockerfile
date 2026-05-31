# Usamos el contenedor oficial de producción empaquetado públicamente por la comunidad de VROOM
FROM ghcr.io/vroom-project/vroom-express:latest

# Railway inyecta el puerto dinámicamente en la variable PORT, VROOM lo necesita en la configuración
EXPOSE 3000

CMD ["npm", "start"]
