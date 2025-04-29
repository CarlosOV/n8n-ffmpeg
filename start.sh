#!/bin/sh

print_banner() {
    echo "----------------------------------------"
    echo "n8n Puppeteer Node - Environment Details"
    echo "----------------------------------------"
    echo "Node.js version: $(node -v)"
    echo "n8n version: $(n8n --version)"

    # Get Chromium version specifically from the path we're using for Puppeteer
    CHROME_VERSION=$("$PUPPETEER_EXECUTABLE_PATH" --version 2>/dev/null || echo "Chromium not found")
    echo "Chromium version: $CHROME_VERSION"

    # Get Puppeteer version if installed
    PUPPETEER_PATH="/opt/n8n-custom-nodes/node_modules/n8n-nodes-puppeteer"
    if [ -f "$PUPPETEER_PATH/package.json" ]; then
        PUPPETEER_VERSION=$(node -p "require('$PUPPETEER_PATH/package.json').version")
        echo "n8n-nodes-puppeteer version: $PUPPETEER_VERSION"

        # Try to resolve puppeteer package from the n8n-nodes-puppeteer directory
        CORE_PUPPETEER_VERSION=$(cd "$PUPPETEER_PATH" && node -e "try { const version = require('puppeteer/package.json').version; console.log(version); } catch(e) { console.log('not found'); }")
        echo "Puppeteer core version: $CORE_PUPPETEER_VERSION"
    else
        echo "n8n-nodes-puppeteer: not installed"
    fi

    echo "Puppeteer executable path: $PUPPETEER_EXECUTABLE_PATH"
    echo "----------------------------------------"
}

# Add custom nodes to the NODE_PATH
if [ -n "$N8N_CUSTOM_EXTENSIONS" ]; then
    export N8N_CUSTOM_EXTENSIONS="/opt/n8n-custom-nodes:${N8N_CUSTOM_EXTENSIONS}"
else
    export N8N_CUSTOM_EXTENSIONS="/opt/n8n-custom-nodes"
fi

print_banner


# Verificar si ya existe el certificado
if [ ! -f /etc/letsencrypt/live/n8n-test.nmviajes-it.com/fullchain.pem ]; then
    # Si no existe, obtener nuevo certificado
    certbot --nginx -d n8n-test.nmviajes-it.com --non-interactive --agree-tos --email carlosovdev@gmail.com
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
    
    # SSE para /mcp y /mcp-test
    location ~ ^/(mcp|mcp-test) {
        proxy_pass http://127.0.0.1:5678;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_set_header Connection '';

        # Evitar buffering para SSE
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 3600;
        chunked_transfer_encoding off;
    }

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