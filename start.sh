#!/bin/bash
# 1. Iniciar Nginx en segundo plano
nginx

# 2. Ejecutar el entrypoint original de la imagen de VROOM
# (Esto asegura que VROOM arranque exactamente como sus creadores lo diseñaron)
exec /docker-entrypoint.sh "$@"
