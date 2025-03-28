#!/bin/sh

# Verificar si ya existe el certificado
if [ ! -f /etc/letsencrypt/live/n8n-test.nmviajes-it.com/fullchain.pem ]; then
    # Si no existe, obtener nuevo certificado
    certbot --nginx -d n8n-test.nmviajes-it.com --non-interactive --agree-tos --email carlosov@gmail.com
else
    # Si existe, asegurarse de que Nginx use la configuración SSL
    if [ ! -f /etc/nginx/conf.d/n8n-ssl.conf ]; then
        # Copiar configuración SSL si no existe
        cat > /etc/nginx/conf.d/n8n-ssl.conf <<EOF
server {
    listen 443 ssl;
    server_name n8n-test.nmviajes-it.com;
    
    ssl_certificate /etc/letsencrypt/live/n8n-test.nmviajes-it.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/n8n-test.nmviajes-it.com/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

# Redirigir HTTP a HTTPS
server {
    listen 80;
    server_name n8n-test.nmviajes-it.com;
    return 301 https://\$server_name\$request_uri;
}
EOF
    fi
fi

# Verificar configuración de Nginx
nginx -t

# Iniciar Nginx
nginx

# Iniciar n8n
n8n start