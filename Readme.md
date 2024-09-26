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