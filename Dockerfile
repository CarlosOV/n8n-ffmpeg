# ─────────────────────────────────────────────────────────────
# Imagen base n8n
# ─────────────────────────────────────────────────────────────
FROM surnet/alpine-wkhtmltopdf:3.16.2-0.12.6-full as wkhtmltopdf
FROM n8nio/n8n:latest as app

# Trabajaremos brevemente como root para instalar paquetes
USER root

# ─────────────────────────────────────────────────────────────
# Variables de entorno
# ─────────────────────────────────────────────────────────────
ENV \
PIP_BREAK_SYSTEM_PACKAGES=1 \      
  PIP_NO_CACHE_DIR=1 \         
  PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
  PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

ENV NODE_OPTIONS="--dns-result-order=ipv4first"  
# ─────────────────────────────────────────────────────────────
# Paquetes del sistema
#  - python3 + pip             → ejecutar scripts/CLI auxiliares
#  - chromium / nss / udev     → Puppeteer
#  - certbot + nginx           → TLS/Reverse proxy
#  - pandoc + texlive-full     → Markdown → PDF
# ─────────────────────────────────────────────────────────────
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    build-base \
    git \
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
    bash \
    pandoc 
    
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/libwkhtmltox.so /bin/

# ─────────────────────────────────────────────────────────────
# Dependencias Python (gitingest)
# ─────────────────────────────────────────────────────────────
RUN pip3 install --upgrade pip && \
    pip3 install gitingest

# ─────────────────────────────────────────────────────────────
# Instalación del paquete n8n-nodes-puppeteer
# ─────────────────────────────────────────────────────────────
RUN mkdir -p /opt/n8n-custom-nodes && \
    cd /opt/n8n-custom-nodes && \
    npm install n8n-nodes-puppeteer && \
    chown -R node:node /opt/n8n-custom-nodes

# ─────────────────────────────────────────────────────────────
# Nginx + Certbot
# ─────────────────────────────────────────────────────────────
RUN mkdir -p /etc/nginx/conf.d /run/nginx /var/lib/certbot

COPY nginx.conf /etc/nginx/nginx.conf
COPY n8n.conf   /etc/nginx/conf.d/default.conf

# ─────────────────────────────────────────────────────────────
# Script de inicio
# ─────────────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Puerto expuesto por n8n
EXPOSE 5678

ENTRYPOINT ["/start.sh"]