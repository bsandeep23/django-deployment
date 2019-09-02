# Django Deployment

This repo consists of resources required for deploying a django application to Google kubernetes. 
* Makefile: For easy execution of build, deploy and setup tasks
* Kubernetes deployment template: Consists of deployment config, secret and configmap, service, pod auoscaler
* Dockerfile for nginx and django
* Sample django app

## Local setup
```
# This command installs all required tools on work machine. Assumption ubuntu 16.04
make setup_local
# Add current user to docker group
sudo usermod -aG docker <<user>>
# reslogin shell
# Run django on local
make run_local
```
## Create Infra and configure
```
# Run gcloud init 
gcloud init
# Create infra. Make any configuration changes required in the script
make createinfra
# Configure kubectl and docker cred providers for gcr
gcloud container clusters get-credentials <cluster_name> --zone <zone> --project <project_name>
gcloud auth configure-docker
# Make sure that appropriate firewall whitelisting has been done
# source all env variables
chmod +x setenv.sh
source setenv.sh
# Create deployment resources on kubernetes
make createdeployment
# Make sure that database firewall is open for dev machine and k8s cluster
```

## Configure the environment
* Set the following values in setenv.sh file
   * DB_NAME    database name
   * DB_USER    database user name
   * DB_PASS    database password
   * DB_HOST    database host
   * DB_PORT   database port
   * DJANGO_SECRET     django secret
   * GCP_PROJECT_NAME   gcp project name
   * KUBE_NAMESPACE     namespace
   * APP_NAME   app_name

## Build and Deploy
```
chmod +x setenv.sh
source setenv.sh
# Build image with an appropriate tag
make TAG="latest" build_image
# Push the image
make TAG="latest" push_image
# deploy
make TAG="latest" deploy
```

## Summary 
Writeup can be found [here](https://github.com/bsandeep23/django-deployment/blob/master/WIKI.md "Wiki link")
