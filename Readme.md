# Docker image n8n-ffmpeg

Build image

```bash

docker build -t n8n-ffmpeg:<version> .

```

Run container


```bash
# create volume
docker volume create n8n_data

# run container
docker run -it --rm --name n8n-ffmpeg -p 5678:5678 -v n8n_data:/home/node/.n8n n8n-ffmpeg:<version>

```


# 1. Eliminar la IP actual
gcloud compute instances delete-access-config vm-n8n-ffmpeg --zone=us-central1-f --network-interface=nic0 --access-config-name="External NAT"

# 2. Crear una IP estática
gcloud compute addresses create n8n-static-ip --region us-central1

# 3. Asignar la IP estática a la VM
gcloud compute instances add-access-config vm-n8n-ffmpeg --zone=us-central1-f --network-interface=nic0 --access-config-name="External NAT" --address=$(gcloud compute addresses describe n8n-static-ip --region us-central1 --format='get(address)')


Ejecutar el contenedor

```bash

docker run -d \
  --name n8n \
  -p 80:80 \
  -p 443:443 \
  -p 5678:5678 \
  -v n8n_letsencrypt:/etc/letsencrypt \
  -v n8n_certbot:/var/lib/certbot \
  -v n8n_data:/home/node/.n8n \
  carlosov/n8n-ffmpeg:0.0.5

``` 
docker run -d --name n8n -p 80:80 -p 443:443 -p 5678:5678 -v n8n_letsencrypt:/etc/letsencrypt -v n8n_certbot:/var/lib/certbot -v n8n_data:/home/node/.n8n carlosov/n8n-ffmpeg:0.0.5


## N8n test command

### Crear carpeta para el volume

``` 
mkdir -p ~/.n8n
``` 

### Crear archivo env
Reemplázalo con tus propios valores

``` 
cp .env.example .env
``` 

