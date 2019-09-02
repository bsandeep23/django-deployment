#!/bin/bash

# enable servic enetworking
gcloud services enable servicenetworking.googleapis.com 

db_instance_name="mysitedb"
network_name="default"

# configure private access
gcloud compute addresses create $db_instance_name \
    --global \
    --purpose=VPC_PEERING \
    --addresses=192.168.0.0 \
    --prefix-length=16 \
    --description=$db_instance_name \
    --network=$network_name
	
# Create private access
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=$db_instance_name \
    --network=$network_name 

# Create postgres
gcloud beta sql instances create $db_instance_name --cpu=2 --memory=3840MiB \
        --database-version=POSTGRES_9_6 --no-assign-ip --network=$network_name

# Update adminuser
gcloud sql users set-password postgres \
    --instance=$db_instance_name --prompt-for-password
	
# Create user for django
gcloud sql users create mysite \
   --instance=$db_instance_name --password=temp

# Alter password
gcloud sql users set-password mysite \
   --instance=$db_instance_name --prompt-for-password
   
# Create database
gcloud sql databases create mysite --instance=$db_instance_name \
--charset=UTF8 --collation=en_US.UTF8
	
# Create kubernetes cluster
gcloud container clusters create mysite-k8s-cluster \
	--enable-autoscaling --max-nodes=4 --min-nodes=2 \
	--network=$network_name

