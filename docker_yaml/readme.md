
git clone https://github.com/doccano/doccano



# OpenDiscourse

Documentation https://open-discourse.github.io/open-discourse-documentation/1.1.0/run-the-database-locally.html


# Github Personal tokens: See: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry

New Token read:packages

dann im server token in .credentials speichern
ghp_...

und dann vor pull, bei github container repository einloggen:
cat .credentials | docker login ghcr.io -u USERNAME --password-stdin

sudo systemctl status docker

docker pull ghcr.io/open-discourse/open-discourse/database:latest

    docker run --env POSTGRES_USER=postgres --env POSTGRES_DB=postgres --env POSTGRES_PASSWORD=postgres  -p 5432:5432 -d ghcr.io/open-discourse/open-discourse/database

# Doccano

https://doccano.github.io/doccano/install_and_upgrade_doccano/
Deploy via Docker , but include Opendiscourse PostgresDB in docker-compose
start docker via tmux https://www.makeuseof.com/install-tmux-linux/

tmux new -s sessionname
sudo docker-compose -f docker/docker-compose.prod_s7.yml --env-file docker/.env up

when running, detach tmux session ctrl+B d