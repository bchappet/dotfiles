# Apptainer help:

apptainer shell --contain ubuntu-22.04.sif  # contain to avoid mounting home

# Docker help:

sudo apt install docker.io
sudo service docker start
docker info

docker run --rm -it dotfiles-test:ubuntu-22.04 bash  # run docker in shell mode



