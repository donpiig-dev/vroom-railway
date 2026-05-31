FROM vroomproject/vroom-express:v1.14.0

# Railway inyecta el puerto dinámicamente en la variable PORT, VROOM lo necesita en la configuración
EXPOSE 3000

CMD ["npm", "start"]
