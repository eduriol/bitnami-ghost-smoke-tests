# Bitnami Ghost Smoke Tests
Deployment script and smoke test suite for ensuring the Bitnami Ghost application is working properly.
## Requirements
- Docker Engine 20.10.8+
- Docker Compose 1.29.2+
- Java 11+
- Google Chrome 95+
## Run the smoke tests
As usual, first step is cloning the repo :)
```
git clone https://github.com/eduriol/bitnami-ghost-smoke-tests.git
cd  bitnami-ghost-smoke-tests
```
### Docker Compose tests
To test the deployment of Bitnami Ghost using Docker Compose, you need to run the `test_deployment.sh` script, followed by the name of the compose yaml file you want to test. This compose yaml file contains a specific configuration for the Bitnami Ghost application, so the same script can be used to test different configurations:
```
./test_deployment.sh <docker compose file name> 
```
Examples:
```
./test_deployment.sh compose-scenario1.yml
./test_deployment.sh compose-scenario2.yml 
```
Two compose configuration files have been attached to the repository as an example. These are the differences with respect to the [original docker-compose.yml file](https://github.com/bitnami/bitnami-docker-ghost/blob/master/docker-compose.yml):

**compose-scenario1.yml**  
The followings config parameters have been changed:
- MARIADB_ROOT_PASSWORD=vmw@r3
- MARIADB_PASSWORD=vmw@r3
- GHOST_USERNAME=vmware
- GHOST_PASSWORD=vmw@r3p455w0rd
- GHOST_EMAIL=vmware@vmware.com
- GHOST_DATABASE_PASSWORD=vmw@r3
- GHOST_BLOG_TITLE=VMware Blog
- GHOST_PORT_NUMBER=5454
- GHOST_EXTERNAL_HTTP_PORT_NUMBER=8080

**compose-scenario2.yml**  
The followings config parameters have been changed:
- MARIADB_USER=vmw_ghost
- MARIADB_DATABASE=vmware_ghost
- MARIADB_PASSWORD=dbpassword
- MARIADB_ROOT_PASSWORD=dbpassword
- GHOST_DATABASE_USER=vmw_ghost
- GHOST_DATABASE_NAME=vmware_ghost
- GHOST_DATABASE_PASSWORD=dbpassword

### Reports
The report showing the result of the smoke tests execution can be seen in the standard output.

### Contribution
If you'd like to contribute to the project, please send a [Pull Request](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) or contact eduriol [at] gmail.com.
