# Sowi Stuttgart CSS Lab Annotation Pipeline 

This repository contains files and documentation to set up an annotation pipeline for machine learning on the bwcloud OpenStack server.

Access information, credentials, and private key-file are stored on the S7 network storage `/Projekte/BWCloudServer/`

The annotation server hosts the **doccano** annotation tool (https://github.com/doccano/doccano) and a **PostgreSQL** database. 
Doccano can be accessed via web browser under the known IP-adress. Database access is described in the `readme.md` in this repository in the folder `./scripts/`.

To set up the annotation server from scratch, follow the subsequent steps...
The basic useage of the bwCloud is described https://www.bw-cloud.org/de/erste_schritte and here https://uweremer.github.io/css_server_setup/. 

Be aware: “With great power comes great responsibility”! You have root rights for your own instances. Everybody is responsible (and liable) for his/her own instance. The insatance is exposed in the internet, so take appropriate measures to **secure your server!**


## Initial server configuration

Build an OpenStack instance, e.g., with the *OpenSUSE Leap 15.3 JeOS* image and login with ssh.

First, automate updates to receive security updates when necessary. Select at least weekly security updates.

```
sudo zypper install yast2-online-update-configuration
sudo yast2 online_update_configuration
```

As the *JeOS* (Just enough operating system) version of OpenSUSE is a minimal installation, we need to add some basic packages:

- nano
- tmux
- git 
- docker
- docker-compose

```
sudo zypper install [package]
```
Start docker service:
```
sudo systemctl status docker
sudo systemctl start docker
```

Make docker service start on startup:

```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```


# Get doccano running

For the comprehensive doccano documentation see https://doccano.github.io/doccano/

We use a docker container to deploy doccano on the server. First, clone the doccano repository from github with git. 

```
git clone https://github.com/doccano/doccano.git
```

Next, we store our own configuration parameters in the `.env` file under path `./doccano/docker/` (by copying and customizing the `.env.example`)

```
cd doccano/docker/
cp .env.example .env
nano .env
```

The actual configuration of the productive environment is stored on the S7 network storage `./Projekte/BWCloudServer/`.

Now, we can initialise the doccano container:

```
sudo docker-compose -f docker-compose.prod.yml --env-file .env up
```

Alternatively, if we use `tmux`, we can start the process in background shell session:

```
tmux new -s SESSIONNAME # starts new shell session
sudo docker-compose -f docker-compose.prod.yml --env-file .env up
```
Then press <kbd>Ctrl</kbd> + <kbd>B</kbd> <kbd>d</kbd> to leave session.

Now we can access the doccano annotation tools via web browser.


## Get doccano running simultaneaously with the Open Discourse database

To be able to use the [Open Discourse](https://opendiscourse.de/) database on parliamentary speeches of the German Bundestag together with the doccano server, we need to adapt the deployment process.

The Open Discourse database is available as prefilled PostgreSQL database docker container.

As doccano and the Open Discourse docker container both start postges as a service, we need to adapt the docker-compose yaml files. The goal is to arrive at a single PostgreSQL instance, which contains the OpenDiscourse database but also the doccano database.  

### Get the Open Discourse database

The documentation on how to setup the Open Discourse database locally can be found [here](https://open-discourse.github.io/open-discourse-documentation/1.1.0/run-the-database-locally.html).

The docker image is provided via *ghcr.io* (github container registry). To access containers from ghcr.io, we need a github account and a personal github token with permisison to `read:packages` (see [github documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)).

After generating this token, we store it in a `.credentials` file and use it to login to ghcr.io (don't forget to provide *your* USERNAME):

```
cd ~
nano .credentials # insert token ghp_... 
cat .credentials | docker login ghcr.io -u USERNAME --password-stdin
```

Then we are able to pull the docker image:

```
docker pull ghcr.io/open-discourse/open-discourse/database:latest
```

If we were only interested in the database (without having a doccano environment), we could just follow the Open Discourse documentation and start the container: 

```
docker run --env POSTGRES_USER=postgres --env POSTGRES_DB=postgres --env POSTGRES_PASSWORD=postgres  -p 5432:5432 -d ghcr.io/open-discourse/open-discourse/database
```

Now we can explore the data (e.g. via [pgAdmin](https://www.pgadmin.org/) or in R with the package [RPostgreSQL](https://cran.r-project.org/web/packages/RPostgreSQL/index.html):


### Adapt the docker-compose yaml

But if we want to have doccano and Open Discourse on the same postgres instance, we need to adapt the deployment procedure as follows:

First, make sure, no containers are running and all ... 
