.PHONY: help deploy setup_minikube setup_aws setup_gcp

clean:
	sudo rm -rf solr/mycores/ckan/data/

init:
	./src/bin/manage.sh init

start-prod:
	# sudo chown -R 8983:8983 solr
	docker-compose up -d --build

gen-dev-compose-file:
	@sed "s/      context: .\/ckan/      context: ./" docker-compose.yml | \
	sed "s/      dockerfile: Dockerfile/      dockerfile: .\/src\/Dockerfile/" | \
	sed "s/      \# placeholder: dev-mappings/      - .\/src\/extensions\/:\/srv\/app\/src\/extensions #i1/" | \
	sed "s/ #i1/|      - .\/src\/core\/ckan\/:\/srv\/app\/src\/ckan/" | \
	tr '|' '\n' \
		> docker-compose.dev.yml

build: gen-dev-compose-file
	docker-compose -f ./docker-compose.dev.yml -p biskit build

up-core: gen-dev-compose-file
	# sudo chown -R 8983:8983 solr
	docker-compose -f ./docker-compose.dev.yml -p biskit up postgres redis solr

up-ckan: gen-dev-compose-file
	docker-compose -f ./docker-compose.dev.yml -p biskit up datapusher ckan

test:
	pycodestyle --count --ignore=E501,E731 ./src/extensions/ckanext-biskit/ckanext/biskit
