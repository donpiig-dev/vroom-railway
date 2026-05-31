FROM vroomproject/vroom-express:latest

# Railway inyecta el puerto dinámicamente en la variable PORT, VROOM lo necesita en la configuración
EXPOSE 3000

CMD ["npm", "start"]
