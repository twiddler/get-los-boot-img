docker build . -t getlos
docker run -v "$HOME"/Downloads:/root/Downloads getlos
