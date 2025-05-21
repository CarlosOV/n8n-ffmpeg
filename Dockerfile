FROM n8nio/n8n:latest

USER root

# Instalar dependencias básicas + las necesarias para Puppeteer
RUN apk update && apk add --no-cache \
    ffmpeg \
    nginx \
    certbot \
    certbot-nginx \
    openssl \
    chromium \
    nss \
    glib \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    nodejs \
    npm \
    udev \
    dumb-init \
    ttf-liberation \
    font-noto-emoji \
    bash

# Establecer variables de entorno para Chromium (Puppeteer)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install n8n-nodes-puppeteer in a permanent location
RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

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
EXPOSE 5678

ENTRYPOINT ["/start.sh"]