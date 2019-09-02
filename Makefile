include .makerc

run_local:
	pip3 install --user -r requirements.txt
	python3 src/manage.py makemigrations
	python3 src/manage.py migrate
	python3 src/manage.py runserver  0.0.0.0:8000

clean_local: 
	rm -rf src/static

build_image:
	rm -rf src/static
	docker build -t myapp_django:${TAG} .
	python3 src/manage.py collectstatic
	docker build -f Dockerfile_nginx -t myapp_nginx:${TAG} .

push_image:
	docker tag myapp_django:${TAG} gcr.io/$(GCP_PROJECT_NAME)/django:${TAG}
	docker tag myapp_nginx:${TAG} gcr.io/$(GCP_PROJECT_NAME)/nginx:${TAG}
	docker push gcr.io/$(GCP_PROJECT_NAME)/django:${TAG}
	docker push gcr.io/$(GCP_PROJECT_NAME)/nginx:${TAG}

deploy:
	python3 src/manage.py makemigrations --settings=mysite.prd_settings
	python3 src/manage.py migrate --settings=mysite.prd_settings
	kubectl -n $(KUBE_NAMESPACE) --record deployment.apps/${APP_NAME}-deployment set image deployment.v1.apps/${APP_NAME}-deployment django=gcr.io/$(GCP_PROJECT_NAME)/django:${TAG} nginx=gcr.io/$(GCP_PROJECT_NAME)/nginx:${TAG}
	kubectl -n $(KUBE_NAMESPACE) rollout status deployment.v1.apps/${APP_NAME}-deployment

createdeployment:
	envsubst < deployment.yml.template > deployment.yml
	kubectl apply -f deployment.yml

createinfra:
	echo "Creating infra"
	chmod +x create_infra.sh
	./create_infra.sh	

setup_local:
	echo "setting up local"
	chmod +x setup_local.sh
	./setup_local.sh
