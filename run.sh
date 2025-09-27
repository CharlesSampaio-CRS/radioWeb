# Para e remove todos os containers
docker stop $(docker ps -aq) && docker rm -f $(docker ps -aq)

# Remove a imagem antiga (opcional, se quiser rebuild limpo)
docker images -q my-radio | xargs -r docker rmi -f

# Constrói novamente a imagem
docker build -t my-radio .

# Roda o container
docker run -p 8000:8000 -it my-radio

