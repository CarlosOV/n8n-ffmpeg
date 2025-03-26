FROM n8nio/n8n:latest

USER root

# Instalar dependencias
RUN apk update && apk add --no-cache \
    ffmpeg \
    nginx \
    certbot \
    certbot-nginx \
    openssl

# Crear directorios necesarios
RUN mkdir -p /etc/nginx/conf.d \
    && mkdir -p /run/nginx \
    && mkdir -p /var/lib/certbot

# Configurar Nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY n8n.conf /etc/nginx/conf.d/default.conf

# Script de inicio
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Exponer puertos
EXPOSE 80 443 5678

ENTRYPOINT ["/start.sh"]